output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.jenkins_server.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2"
  value       = aws_instance.jenkins_server.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.jenkins_sg.id
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:9000"
}

output "angular_app_url" {
  description = "Angular App URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8081"
}
