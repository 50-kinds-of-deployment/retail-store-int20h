# Sentinel Policy Scan Workflow

## Overview
This workflow automatically scans Terraform configurations using HashiCorp Sentinel policy-as-code framework to enforce security, compliance, and best practices.

## What It Does

The workflow:
1. **Triggers** on pull requests that modify Terraform files or manual dispatch
2. **Generates** Terraform plan JSON
3. **Runs** Sentinel CLI scan against defined policies
4. **Reports** results as PR comment
5. **Uploads** results as artifacts for verification
6. **Fails** the workflow if hard-mandatory policies are violated

## Policies Included

### Security Policies
- ✅ **RDS Encryption**: Ensures databases have encryption at rest
- ✅ **No Public Access**: Prevents publicly accessible databases
- ✅ **Backup Retention**: Requires backup configuration
- ✅ **Security Groups**: Enforces network security rules

### Compliance Policies
- ✅ **EKS Logging**: Requires cluster logging enabled
- ✅ **Resource Tags**: Ensures proper tagging

## Files

- `sentinel-scan.yml` - Main workflow definition
- `policy.hcl` - Policy definitions
- `sentinel_rules.hcl` - Detailed policy rules

## How to Use

### Manually Trigger
```bash
# Go to Actions → Sentinel Policy Scan → Run workflow
```

### Automatic on PR
The workflow runs automatically when:
- Any Terraform files change
- Pull request is created/updated

### View Results
1. Check PR comment for quick summary
2. Download artifacts for detailed analysis
3. Review logs in Actions tab

## Policy Enforcement Levels

- **advisory** - Warnings, doesn't fail
- **hard-mandatory** - Failures, blocks merge

## Customizing Policies

Edit `sentinel_rules.hcl` to add/modify rules:

```hcl
rule_example = rule {
  # Your condition here
}
```

## Troubleshooting

**Workflow fails on "Policy violations detected":**
- Check sentinel-scan-results artifact
- Review the specific rule that failed
- Update Terraform config or policy as needed

**Sentinel command not found:**
- Ensure SENTINEL_VERSION matches latest from https://releases.hashicorp.com/sentinel/

## Integration with Terraform Cloud (Optional)

To use with Terraform Cloud:
1. Enable `Enforce policy checks` in workspace settings
2. Add policy set pointing to your sentinel rules
3. Workflow will respect TFCloud policy verdicts

## References
- [Sentinel Documentation](https://www.terraform.io/cloud-docs/policy-enforcement/sentinel)
- [Sentinel Language](https://www.terraform.io/cloud-docs/policy-enforcement/sentinel/intro)
- [Policy Examples](https://github.com/hashicorp/terraform-sentinel-policies)
