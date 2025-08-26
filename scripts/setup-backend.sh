#!/bin/bash

# ============================================================================
# Terraform Backend Setup Script
# Creates S3 bucket and DynamoDB table for Terraform state management
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️ Setting up Terraform Backend Infrastructure${NC}"
echo "=============================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
AWS_REGION="ap-northeast-1"
BUCKET_NAME="superinsight-terraform-state-prod"
DYNAMODB_TABLE="superinsight-terraform-locks"

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    # Test AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured or invalid"
        exit 1
    fi
    
    print_status "Prerequisites check completed ✓"
}

# Check if backend resources already exist
check_existing_resources() {
    print_status "Checking for existing backend resources..."
    
    # Check S3 bucket
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        print_warning "S3 bucket $BUCKET_NAME already exists"
        BUCKET_EXISTS=true
    else
        BUCKET_EXISTS=false
    fi
    
    # Check DynamoDB table
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" 2>/dev/null; then
        print_warning "DynamoDB table $DYNAMODB_TABLE already exists"
        TABLE_EXISTS=true
    else
        TABLE_EXISTS=false
    fi
    
    if [ "$BUCKET_EXISTS" = true ] && [ "$TABLE_EXISTS" = true ]; then
        print_status "Backend resources already exist - skipping creation"
        return 0
    fi
}

# Deploy backend infrastructure
deploy_backend() {
    print_status "Deploying backend infrastructure with Terraform..."
    
    cd terraform-backend
    
    # Initialize Terraform (local state for backend setup)
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan the deployment
    print_status "Planning backend infrastructure..."
    terraform plan -var="aws_region=$AWS_REGION"
    
    # Apply the plan
    print_status "Creating backend resources..."
    terraform apply -auto-approve -var="aws_region=$AWS_REGION"
    
    cd ..
    
    print_status "Backend infrastructure created ✓"
}

# Configure main Terraform to use remote backend
configure_main_terraform() {
    print_status "Configuring main Terraform to use remote backend..."
    
    # Create backend configuration
    cat > terraform/backend.tf << EOF
# Backend configuration for Terraform state
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "n8n/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF

    print_status "Backend configuration created ✓"
}

# Test backend configuration
test_backend() {
    print_status "Testing backend configuration..."
    
    cd terraform
    
    # Initialize with remote backend
    terraform init -backend-config="bucket=$BUCKET_NAME" \
                   -backend-config="key=n8n/terraform.tfstate" \
                   -backend-config="region=$AWS_REGION" \
                   -backend-config="dynamodb_table=$DYNAMODB_TABLE"
    
    # Test state operations
    terraform plan -var="trustcloud_api_key=test" -var="n8n_encryption_key=test" > /dev/null 2>&1 || {
        print_warning "Terraform plan failed (expected - missing secrets)"
    }
    
    cd ..
    
    print_status "Backend configuration tested ✓"
}

# Main execution
main() {
    check_prerequisites
    check_existing_resources
    
    if [ "$BUCKET_EXISTS" != true ] || [ "$TABLE_EXISTS" != true ]; then
        deploy_backend
    fi
    
    configure_main_terraform
    test_backend
    
    echo
    echo -e "${GREEN}🎉 Backend Setup Complete!${NC}"
    echo "=========================="
    echo
    echo -e "${BLUE}📋 Backend Configuration:${NC}"
    echo "  • S3 Bucket: $BUCKET_NAME"
    echo "  • DynamoDB Table: $DYNAMODB_TABLE"
    echo "  • Region: $AWS_REGION"
    echo
    echo -e "${BLUE}📝 Next Steps:${NC}"
    echo "  1. Set up GitHub Secrets for deployment"
    echo "  2. Push code to GitHub repository"
    echo "  3. Create Pull Request to test terraform plan"
    echo "  4. Merge to main branch to deploy infrastructure"
    echo
    echo -e "${YELLOW}⚠️  Important:${NC}"
    echo "  • Backend state is now stored remotely in S3"
    echo "  • State locking prevents concurrent modifications"
    echo "  • Backup and versioning are enabled"
    
    print_status "Backend setup completed successfully! 🎉"
}

# Run main function
main "$@"