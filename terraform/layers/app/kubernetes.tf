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

resource "kubernetes_namespace_v1" "checkout" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "checkout"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
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

resource "kubernetes_namespace_v1" "ui" {
  depends_on = [
    data.kubernetes_nodes.vpc_ready_nodes
  ]

  metadata {
    name = "ui"

    labels = var.istio_enabled ? local.istio_labels : {}
  }
}

resource "time_sleep" "restart_pods" {
  triggers = {
    opentelemetry_enabled = var.opentelemetry_enabled
  }

  create_duration = "30s"
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

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_external_secrets.iam_role_arn
    }
  }
}

