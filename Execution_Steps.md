## Prerequisites:

Before executing this project, ensure you have the following:
* **AWS CLI:** Installed and configured.
* **Terraform:** Installed
* **S3** A precreated S3 bucket for state storage and state locking.
* **ECR Repositories:** Two ECR repositories (frontend/backend) to store your Docker images.
* **SSH Key Pair:** An AWS EC2 Key Pair to access the Bastion host.

## 🏁 Execution Steps

### 1. Initialize & Select Environment
Initialize the backend by replacing your s3 bucket name in providers.tf file and create/select your workspace:

```bash
terraform init # Initialize Terraform and configure backend
terraform workspace new dev  # Create dev workspace
terraform workspace select dev # Switch to dev
```
### 2. Configure Variables

Update the terraform.tfvars file with below variables.

| Variable                 | Description                          |
| ------------------------ | ------------------------------------ |
| vpc_cidr                 | CIDR block for VPC                   |
| region                   | AWS region                           |
| availability_zones       | List of AZs                          |
| instance_type            | EC2 instance type                    |
| key_name                 | SSH key pair                         |
| db_port                  | Database port                        |
| min/max/desired frontend | Frontend ASG scaling                 |
| min/max/desired backend  | Backend ASG scaling                  |
| ecr_registry_url         | ECR registry used for pulling images |


### 3. Plan & Validate

Generate an execution plan to verify the 44 resources being created:

```bash
terraform plan
```

### 4. Deploy

Apply the configuration. Note: RDS and NAT Gateways may take 10-15 minutes.

```bash
terraform apply -auto-approve
```
5. Access & Verify

Retrieve the Load Balancer DNS from the outputs:

```bash
terraform output external_alb_dns_name
```

Open the URL in your browser to see the frontend application. You can also SSH into the bastion host to verify backend connectivity and database access.

### 6. Clean Up
To avoid unnecessary costs, destroy the infrastructure when done:

```bash
terraform destroy -auto-approve
```
