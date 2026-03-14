# Sentinel Policy for EKS Terraform Configuration

# Policy: Require encryption at rest
policy "require_encryption_at_rest" {
  description = "Ensure all databases and storage have encryption enabled"
  
  enforcement_level = "advisory"
}

# Policy: Require backup retention
policy "require_backup_retention" {
  description = "Ensure databases have backup retention configured"
  
  enforcement_level = "hard-mandatory"
}

# Policy: Disallow public access
policy "disallow_public_access" {
  description = "Ensure databases are not publicly accessible"
  
  enforcement_level = "hard-mandatory"
}

# Policy: Require security groups
policy "require_security_groups" {
  description = "Ensure resources are protected by security groups"
  
  enforcement_level = "hard-mandatory"
}

# Policy: Require tags
policy "require_tags" {
  description = "Ensure all resources have tags"
  
  enforcement_level = "advisory"
}

# Policy: Limit instance types for cost
policy "limit_instance_types" {
  description = "Ensure instance types comply with cost optimization"
  
  enforcement_level = "advisory"
}
