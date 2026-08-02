data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "jenkins_ecr_ecs_deploy" {
  name        = "jenkins-ecr-ecs-deploy"
  description = "Permite a Jenkins subir imagenes a ECR y actualizar el servicio de ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.angular_app.arn
      },
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/angular-app-cluster/angular-app-service"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_ecs_deploy" {
  role       = "training-ssm-cw"
  policy_arn = aws_iam_policy.jenkins_ecr_ecs_deploy.arn
}