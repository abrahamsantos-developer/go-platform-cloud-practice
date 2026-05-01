output "next_steps" {
  value = [
    "Confirm the active identity with aws sts get-caller-identity",
    "Estimate monthly cost before adding a new resource",
    "Run terraform plan before terraform apply",
    "Run terraform destroy before ending the session"
  ]
}
