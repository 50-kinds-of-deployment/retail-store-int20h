terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "retail-store-tf-state-eu-central-1"
    key    = "stage/app/terraform.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.ops.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.ops.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubernetes" {
  alias                  = "cluster"
  host                   = data.terraform_remote_state.ops.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.ops.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = data.terraform_remote_state.ops.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.ops.outputs.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.ops.outputs.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.ops.outputs.cluster_certificate_authority_data)
  }
}
