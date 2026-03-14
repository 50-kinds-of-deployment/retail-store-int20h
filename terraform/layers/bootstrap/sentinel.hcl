policy "enforce-tags" {
  description = "Enforce that resources have required tags"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_s3_bucket": "*",
    "aws_dynamodb_table": "*",
    "aws_kms_key": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      if resource.change.after.tags is empty {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "Bootstrap resources must have tags defined"
  }
}

policy "enforce-state-encryption" {
  description = "Enforce S3 backend encryption"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_s3_bucket": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      if resource.change.after.server_side_encryption_configuration is empty {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "S3 buckets must have encryption enabled"
  }
}

policy "enforce-versioning" {
  description = "Enforce versioning on S3 state bucket"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_s3_bucket_versioning": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      if resource.change.after.versioning[0].status is not "Enabled" {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "S3 state buckets must have versioning enabled"
  }
}
