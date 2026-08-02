resource "aws_ecr_repository" "angular_app" {
  name                 = "angular-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "angular-app"
  }
}