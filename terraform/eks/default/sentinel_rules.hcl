# Sentinel Rules for Terraform EKS Configuration

import "tfplan/v2" as tfplan
import "tfplan/v1" as tfplan_v1

# Rule 1: Require encryption at rest for RDS
rule_rds_encryption = rule {
  all tfplan.resource_changes.aws_db_instance as _, instances {
    all instances as _, instance {
      instance.change.after.storage_encrypted == true
    }
  }
}

# Rule 2: Disallow public RDS instances
rule_rds_not_public = rule {
  all tfplan.resource_changes.aws_db_instance as _, instances {
    all instances as _, instance {
      instance.change.after.publicly_accessible == false
    }
  }
}

# Rule 3: Require backup retention
rule_rds_backup_retention = rule {
  all tfplan.resource_changes.aws_db_instance as _, instances {
    all instances as _, instance {
      instance.change.after.backup_retention_period >= 1
    }
  }
}

# Rule 4: Security groups must be attached
rule_security_groups_attached = rule {
  all tfplan.resource_changes.aws_db_instance as _, instances {
    all instances as _, instance {
      length(instance.change.after.vpc_security_group_ids) > 0
    }
  }
}

# Rule 5: EKS should have logging enabled
rule_eks_logging = rule {
  all tfplan.resource_changes.aws_eks_cluster as _, clusters {
    all clusters as _, cluster {
      cluster.change.after.enabled_cluster_log_types is not empty
    }
  }
}

# Main policy enforcement
main = rule {
  (rule_rds_encryption and 
   rule_rds_not_public and 
   rule_rds_backup_retention and 
   rule_security_groups_attached and 
   rule_eks_logging) else false
}
