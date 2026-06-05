terraform {
  backend "s3" {
    bucket         = "gokul-three-tier-tfstate-2026"
    key = "infra/terraform.tfstate"
    region         = "ap-southeast-1"
    use_lockfile = true
    encrypt        = true
  }
}