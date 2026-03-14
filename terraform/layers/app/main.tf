resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = true
  namespace        = "argocd"

  version = "9.3.7"

  wait            = true
  cleanup_on_fail = true
}

resource "helm_release" "app_of_apps" {
  chart = "../../../argocd/app-of-apps"
  name  = "app-of-apps"

  wait            = true
  cleanup_on_fail = true
  timeout         = 3600
  depends_on      = [helm_release.argocd]
}