policy "enforce-tags" {
  description = "Enforce that resources have required tags"
  
  # This evaluates AWS resources to ensure they have required tags
  import "tfplan"
  
  # Get all resources
  resources = find_resources({
    "aws_eks_cluster": "*",
    "aws_eks_node_group": "*",
    "aws_vpc": "*",
    "aws_subnet": "*",
    "aws_security_group": "*"
  })
  
  # Check if resources have required tags
  deny_if = func() {
    for resources as resource {
      if resource.change.after.tags is empty {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "EKS resources must have tags defined"
  }
}

policy "enforce-encryption" {
  description = "Enforce encryption is enabled on resources"
  
  import "tfplan"
  
  # Check EKS cluster encryption
  resources = find_resources({
    "aws_eks_cluster": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      encryption = resource.change.after.encryption_config
      if encryption is empty or length(encryption) == 0 {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "EKS cluster must have encryption configured"
  }
}

policy "restrict-public-access" {
  description = "Restrict public access to EKS API"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_eks_cluster": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      endpoint_config = resource.change.after.vpc_config
      if endpoint_config is not empty {
        if endpoint_config[0].endpoint_public_access is true and endpoint_config[0].endpoint_private_access is false {
          return true
        }
      }
    }
    return false
  }
  
  violation {
    message = "EKS API must have private access enabled or public access must be restricted"
  }
}
