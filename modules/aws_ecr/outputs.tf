output "ecr_repo_url" {
    value = aws_ecr_repository.ecr_ha_repo.repository_url
}