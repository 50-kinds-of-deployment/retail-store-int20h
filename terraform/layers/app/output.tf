output "retail_app_url" {
  description = "URL to access the retail store application"
  value = var.resolve_ui_service_url ? try(
    "http://${data.kubernetes_service.ui_service[0].status[0].load_balancer[0].ingress[0].hostname}",
    "LoadBalancer provisioning - run: kubectl get svc -n ui ui"
  ) : "UI URL resolution disabled"
}
