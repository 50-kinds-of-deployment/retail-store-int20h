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

resource "kubernetes_secret" "argocd_repo" {
  count = var.argocd_github_token != "" ? 1 : 0

  metadata {
    name      = "repo-retail-store-int20h"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/50-Kinds-of-deployment/retail-store-int20h.git"
    password = var.argocd_github_token
    username = "git"
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "app_of_apps" {
  chart = "../../../argocd/app-of-apps"
  name  = "app-of-apps"

  wait            = true
  cleanup_on_fail = true
  timeout         = 3600
  depends_on      = [helm_release.argocd, kubernetes_secret.argocd_repo]
}
