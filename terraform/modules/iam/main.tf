# ============================================================================
# IAM Roles and Policies Module
# ============================================================================

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.environment}-n8n-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for n8n application permissions)
resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-n8n-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-ecs-task-role"
  })
}

# Policy for n8n to access AWS services
resource "aws_iam_policy" "n8n_aws_access" {
  name        = "${var.environment}-n8n-aws-access-policy"
  description = "Policy for n8n to access AWS services for compliance monitoring"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # S3 access for workflow storage
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-n8n-workflows/*",
          "arn:aws:s3:::${var.environment}-n8n-workflows",
          "arn:aws:s3:::${var.environment}-n8n-backup/*",
          "arn:aws:s3:::${var.environment}-n8n-backup"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Secrets Manager access
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:n8n/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # AWS compliance monitoring permissions
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkAcls",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "s3:ListAllMyBuckets",
          "s3:GetBucketEncryption",
          "s3:GetBucketPolicy",
          "s3:GetBucketVersioning",
          "iam:ListUsers",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "lambda:ListFunctions",
          "lambda:GetFunction",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudwatch:GetMetricStatistics",
          "config:DescribeComplianceByConfigRule",
          "config:DescribeConfigRules"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # CloudWatch Logs
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-aws-access-policy"
  })
}

resource "aws_iam_role_policy_attachment" "n8n_aws_access" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.n8n_aws_access.arn
}

# Additional policy for secrets access
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.environment}-n8n-secrets-access-policy"
  description = "Allow ECS task execution role to access secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:n8n/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-secrets-access-policy"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.secrets_access.arn
}