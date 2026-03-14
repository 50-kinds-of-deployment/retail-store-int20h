terraform {
  backend "s3" {
    bucket         = "retail-store-tf-state-eu-central-1"
    key            = "eks/default/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
