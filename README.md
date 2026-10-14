# Automated AWS Infrastructure with Terraform & CI/CD

## Project Overview

This project demonstrates Infrastructure as Code (IaC) using Terraform to manage AWS infrastructure for a Java web application connected to Amazon RDS MySQL.

The objective is to build a secure, maintainable, and highly available architecture, with CI/CD automation planned for infrastructure validation and deployment.

## Architecture

The planned architecture includes:

- **Amazon VPC:** Isolated network for application resources.
- **Public and private subnets:** Distributed across two Availability Zones.
- **Internet Gateway:** Internet connectivity for public resources.
- **NAT Gateway:** Outbound internet access for private resources.
- **Application Load Balancer (ALB):** Distributes incoming application traffic.
- **Amazon EC2 and Auto Scaling:** Planned private application tier for resilience and scaling.
- **Amazon RDS MySQL:** Relational database for the Java application.
- **Amazon S3:** Remote Terraform state storage.
- **CI/CD pipeline:** Planned automation for Terraform validation, planning, and deployment.

## Application Details

- **Application:** Java JSP web application
- **Packaging:** WAR
- **Artifact:** `LoginWebApp.war`
- **Database:** MySQL
- **Database name:** `jwt`
- **Application pages:** `login.jsp` and `userRegistration.jsp`

The active login and registration pages use environment variables for database connection settings:

- `DB_HOST`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`

Database credentials should not be committed to Git.

## Terraform Infrastructure

Terraform configuration files are located in the `terraform/` directory.

| File | Purpose |
|---|---|
| `main.tf` | Terraform settings, AWS provider, VPC, subnets, and networking |
| `variables.tf` | Configurable infrastructure variables |
| `security.tf` | Security groups and database subnet group |
| `rds.tf` | RDS database configuration |
| `alb.tf` | Application Load Balancer, target group, and listeners |
| `.terraform.lock.hcl` | Records selected provider versions |

The architecture uses two Availability Zones to support a resilient design. The private application Auto Scaling tier and complete CI/CD workflow remain planned implementation tasks.

## Terraform State Management and Existing Resource Adoption

Terraform state is stored remotely in Amazon S3. State locking is enabled using S3 lock files to help prevent concurrent Terraform operations from modifying the same state.

### Importing Existing AWS Resources

Terraform import associates an existing AWS resource with a Terraform resource address and records it in Terraform state.

Example:

```bash
terraform import aws_db_instance.java_app <existing-rds-instance-identifier>
```

The resource must have a corresponding Terraform configuration block. Importing does not automatically generate the complete configuration.

After importing, review the resource configuration and run `terraform plan` to inspect differences before applying changes. This helps bring existing infrastructure under Terraform management while reducing the risk of unintended changes.

## Validation

The following commands are used to check Terraform configuration:

```bash
terraform fmt -check -recursive
terraform validate
terraform state list
```

- `terraform fmt -check -recursive` checks Terraform formatting.
- `terraform validate` checks configuration consistency and syntax.
- `terraform state list` displays resources recorded in Terraform state.

A successful validation does not, by itself, confirm that all AWS resources are healthy or that the application is working.

## CI/CD

The planned CI/CD workflow will automate Terraform validation and planning, with controlled deployment after review and approval.

## Future Improvements

- Complete the private EC2 Launch Template and Auto Scaling Group.
- Attach application instances to the existing ALB target group.
- Configure and verify Tomcat deployment of the WAR artifact.
- Test application-to-RDS connectivity.
- Implement and test the CI/CD workflow.
- Document deployment verification and resource cleanup.

## Security Considerations

- Keep application servers and the database in private subnets.
- Restrict security-group rules to required communication paths.
- Store credentials securely and never commit passwords or secrets.
- Review Terraform plans before applying infrastructure changes.
- Check AWS costs and clean up resources when they are no longer needed.

