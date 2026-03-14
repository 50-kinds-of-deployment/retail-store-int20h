locals {
  istio_labels = {
    istio-injection = "enabled"
  }

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = local.ops_outputs.eks_cluster_id
      cluster = {
        certificate-authority-data = local.ops_outputs.cluster_certificate_authority_data
        server                     = local.ops_outputs.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = local.ops_outputs.eks_cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

module "container_images" {
  source = "../../lib/images"

  container_image_overrides = var.container_image_overrides
}

resource "null_resource" "cluster_blocker" {
  triggers = {
    "blocker" = local.ops_outputs.cluster_blocker_id
  }
}

resource "null_resource" "addons_blocker" {
  triggers = {
    "blocker" = local.ops_outputs.addons_blocker_id
  }
}

resource "time_sleep" "workloads" {
  create_duration  = "30s"
  destroy_duration = "60s"

  depends_on = [
    null_resource.addons_blocker
  ]
}

# Wait for VPC Resource Controller to attach trunk ENIs to nodes
data "kubernetes_nodes" "vpc_ready_nodes" {
  depends_on = [time_sleep.workloads]

  metadata {
    labels = {
      "vpc.amazonaws.com/has-trunk-attached" = "true"
    }
  }
}


# HELM CHARTS AND NAMESPACES

resource "kubernetes_namespace_v1" "catalog" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "catalog"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
}

resource "helm_release" "catalog" {
  name  = "catalog"
  chart = "../../../src/catalog/chart"

  namespace = kubernetes_namespace_v1.catalog.metadata[0].name

  values = [
    templatefile("${path.module}/values/catalog.yaml", {
      image_repository              = module.container_images.result.catalog.repository
      image_tag                     = module.container_images.result.catalog.tag
      opentelemetry_enabled         = var.opentelemetry_enabled
      opentelemetry_instrumentation = local.opentelemetry_instrumentation
      database_endpoint             = "${local.ops_outputs.catalog_db_endpoint}:${local.ops_outputs.catalog_db_port}"
      database_username             = local.ops_outputs.catalog_db_master_username
      database_password             = local.ops_outputs.catalog_db_master_password
      security_group_id             = local.ops_outputs.catalog_sg_id
    })
  ]
}

resource "kubernetes_namespace_v1" "checkout" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "checkout"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
}

resource "helm_release" "checkout" {
  name  = "checkout"
  chart = "../../../src/checkout/chart"

  namespace = kubernetes_namespace_v1.checkout.metadata[0].name

  values = [
    templatefile("${path.module}/values/checkout.yaml", {
      image_repository              = module.container_images.result.checkout.repository
      image_tag                     = module.container_images.result.checkout.tag
      opentelemetry_enabled         = var.opentelemetry_enabled
      opentelemetry_instrumentation = local.opentelemetry_instrumentation
      redis_address                 = local.ops_outputs.checkout_elasticache_primary_endpoint
      redis_port                    = local.ops_outputs.checkout_elasticache_port
      security_group_id             = local.ops_outputs.checkout_sg_id
    })
  ]
}

resource "kubernetes_namespace_v1" "orders" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "orders"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
}

resource "helm_release" "orders" {
  name  = "orders"
  chart = "../../../src/orders/chart"

  namespace = kubernetes_namespace_v1.orders.metadata[0].name

  values = [
    templatefile("${path.module}/values/orders.yaml", {
      image_repository              = module.container_images.result.orders.repository
      image_tag                     = module.container_images.result.orders.tag
      opentelemetry_enabled         = var.opentelemetry_enabled
      opentelemetry_instrumentation = local.opentelemetry_instrumentation
      database_endpoint_host        = local.ops_outputs.orders_db_endpoint
      database_endpoint_port        = local.ops_outputs.orders_db_port
      database_name                 = local.ops_outputs.orders_db_database_name
      database_username             = local.ops_outputs.orders_db_master_username
      database_password             = local.ops_outputs.orders_db_master_password
      rabbitmq_endpoint             = local.ops_outputs.mq_broker_endpoint
      rabbitmq_username             = local.ops_outputs.mq_user
      rabbitmq_password             = local.ops_outputs.mq_password
      security_group_id             = local.ops_outputs.orders_sg_id
    })
  ]
}

resource "kubernetes_namespace_v1" "ui" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "ui"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
}

resource "helm_release" "ui" {
  depends_on = [
    helm_release.catalog,
    helm_release.checkout,
    helm_release.orders
  ]

  name  = "ui"
  chart = "../../../src/ui/chart"

  namespace = kubernetes_namespace_v1.ui.metadata[0].name

  values = [
    templatefile("${path.module}/values/ui.yaml", {
      image_repository              = module.container_images.result.ui.repository
      image_tag                     = module.container_images.result.ui.tag
      opentelemetry_enabled         = var.opentelemetry_enabled
      opentelemetry_instrumentation = local.opentelemetry_instrumentation
      istio_enabled                 = var.istio_enabled
    })
  ]
}

resource "time_sleep" "restart_pods" {
  triggers = {
    opentelemetry_enabled = var.opentelemetry_enabled
  }

  create_duration = "30s"

  depends_on = [
    helm_release.ui
  ]
}

resource "null_resource" "restart_pods" {
  depends_on = [time_sleep.restart_pods]

  triggers = {
    opentelemetry_enabled = var.opentelemetry_enabled
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    command = <<-EOT
      kubectl delete pod -A -l app.kubernetes.io/owner=retail-store-sample --kubeconfig <(echo $KUBECONFIG | base64 -d)
    EOT
  }
}
