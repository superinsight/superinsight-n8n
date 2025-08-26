# SuperInsight n8n Infrastructure

🔧 **HIPAA Compliance Automation Infrastructure**

This repository contains the Infrastructure as Code (IaC) for deploying n8n on AWS to automate HIPAA compliance monitoring and evidence collection for SuperInsight's infrastructure.

## 🏗️ Architecture Overview

- **n8n**: Workflow automation platform running on ECS Fargate
- **Database**: RDS PostgreSQL with encryption at rest and in transit
- **Load Balancer**: Application Load Balancer with SSL support
- **Storage**: S3 buckets with versioning and encryption
- **Monitoring**: CloudWatch dashboards and alarms
- **Security**: AWS Secrets Manager, VPC isolation, Security Groups

## 🚀 Quick Start

### 1. Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- GitHub account with repository admin access

### 2. Setup Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/superinsight-n8n.git
   cd superinsight-n8n
   ```

2. **Set up Terraform backend** (one-time setup)
   ```bash
   ./scripts/setup-backend.sh
   ```

3. **Configure GitHub Secrets** (see [setup guide](docs/setup-credentials.md))
   - `PROD_AWS_ACCESS_KEY_ID`
   - `PROD_AWS_SECRET_ACCESS_KEY` 
   - `TRUSTCLOUD_API_KEY`
   - `N8N_ENCRYPTION_KEY`
   - And others as documented

4. **Deploy via GitHub Actions**
   - Create a Pull Request to trigger infrastructure planning
   - Review the plan in PR comments
   - Merge to `main` branch to deploy infrastructure

5. **Access n8n and set up workflows**
   - Access n8n at the provided URL
   - Complete initial setup wizard
   - Import workflows from `n8n-workflows/` directory

## 📁 Repository Structure

```
├── .github/workflows/        # CI/CD pipelines
│   ├── terraform-plan.yml    # PR-triggered planning
│   ├── terraform-apply.yml   # Main branch deployment
│   └── terraform-destroy.yml # Manual infrastructure teardown
├── terraform/               # Infrastructure as Code
│   ├── main.tf             # Main configuration
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   └── modules/            # Terraform modules
│       ├── networking/     # VPC, subnets, security groups
│       ├── database/       # RDS PostgreSQL
│       ├── ecs/           # ECS cluster and services
│       ├── iam/           # IAM roles and policies
│       ├── secrets/       # AWS Secrets Manager
│       ├── storage/       # S3 buckets
│       └── monitoring/    # CloudWatch dashboards
├── terraform-backend/      # Backend infrastructure
├── n8n-workflows/         # n8n workflow templates
├── docs/                  # Documentation
│   └── setup-credentials.md
├── scripts/               # Utility scripts
└── README.md
```

## 🔄 CI/CD Pipeline

### Terraform Plan (Pull Requests)
- Validates Terraform code
- Runs security scanning with tfsec
- Provides cost estimation
- Comments plan results on PR

### Terraform Apply (Main Branch)
- Requires manual approval for production
- Deploys infrastructure changes
- Runs health checks
- Sends notifications

### Terraform Destroy (Manual Only)
- Multi-level approval required
- Creates pre-destruction backup
- Completely removes all infrastructure
- Safety checks and confirmations

## 💰 Cost Breakdown

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| ECS Fargate | 2 tasks (2vCPU, 4GB each) | ~$120-200 |
| RDS PostgreSQL | db.t3.medium, Multi-AZ | ~$60-90 |
| Application Load Balancer | Standard ALB | ~$20 |
| S3 Storage | Workflows + backups | ~$10-30 |
| CloudWatch | Logs + monitoring | ~$10-20 |
| Secrets Manager | 3 secrets | ~$2 |
| Data Transfer | Regional + internet | ~$20-50 |
| **Total Estimated** | | **~$240-410/month** |

## 🔐 Security Features

- **HIPAA-compliant infrastructure** with encryption everywhere
- **VPC network isolation** with private subnets
- **AWS Secrets Manager** integration for sensitive data
- **IAM roles with least-privilege access**
- **Security group restrictions** for network access
- **Comprehensive audit logging** via CloudTrail
- **Automated security scanning** in CI/CD pipeline

## 🔧 n8n Integration

### AWS Services Access
n8n has been configured with IAM roles to access:
- EC2 instances and security groups (compliance monitoring)
- RDS databases (backup and encryption status)
- S3 buckets (access policies and encryption)
- CloudTrail (audit logging)
- IAM (user and policy management)
- Lambda functions (security configuration)

### TrustCloud Integration
- Automated evidence collection from AWS services
- Compliance status updates
- Risk assessment automation
- Audit report generation

## 📊 Monitoring & Alerting

### CloudWatch Dashboards
- ECS service performance metrics
- RDS database performance
- Application Load Balancer metrics
- Cost and billing alerts

### Alarms & Notifications
- High CPU/Memory usage alerts
- Database connection failures
- Application health check failures
- Discord/Slack notification integration

## 🆘 Troubleshooting

### Common Issues

1. **Deployment Fails**
   - Check GitHub Actions logs
   - Verify all GitHub Secrets are set
   - Confirm AWS credentials have necessary permissions

2. **n8n Not Accessible**
   - Allow 5-10 minutes for ECS tasks to start
   - Check ECS service status in AWS Console
   - Verify security groups allow traffic

3. **Database Connection Issues**
   - Check RDS instance status
   - Verify security group rules
   - Confirm secrets are properly configured

### Support Resources
- [AWS ECS Troubleshooting Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/troubleshooting.html)
- [n8n Documentation](https://docs.n8n.io/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🔄 Maintenance

### Regular Tasks
- **Monthly**: Review AWS costs and optimize if needed
- **Quarterly**: Update Terraform providers and modules
- **Annually**: Rotate AWS access keys and TrustCloud tokens

### Backup Strategy
- **Terraform State**: Versioned in S3 with 90-day retention
- **Database**: Automated daily backups with 7-day retention
- **Workflows**: Stored in S3 with versioning enabled

## 🤝 Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Test locally with `terraform plan`
4. Create a Pull Request
5. Review the automated plan results
6. Merge after approval

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Powered by SuperInsight | Built with ❤️ and ☁️**

✅ **Status**: Backend infrastructure successfully deployed and configured!

*For support, please contact the SuperInsight DevOps team or create an issue in this repository.*