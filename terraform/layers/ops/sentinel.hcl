policy "enforce-tags" {
  description = "Enforce that resources have required tags"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_iam_role": "*",
    "aws_iam_policy": "*",
    "aws_cloudwatch_log_group": "*",
    "aws_sqs_queue": "*"
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
    message = "Ops resources must have tags defined"
  }
}

policy "enforce-iam-least-privilege" {
  description = "Enforce least privilege IAM policies"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_iam_policy": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      policy_doc = resource.change.after.policy
      if policy_doc contains "\"Effect\": \"Allow\"" and policy_doc contains "\"Action\": \"*\"" {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "IAM policies must not grant wildcard permissions"
  }
}

policy "enforce-logging" {
  description = "Enforce CloudWatch logging is enabled"
  
  import "tfplan"
  
  resources = find_resources({
    "aws_cloudwatch_log_group": "*"
  })
  
  deny_if = func() {
    for resources as resource {
      if resource.change.after.name is empty {
        return true
      }
    }
    return false
  }
  
  violation {
    message = "CloudWatch log groups must be properly configured"
  }
}
