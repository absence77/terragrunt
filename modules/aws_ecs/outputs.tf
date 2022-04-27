output "clustername" {
    value = aws_ecs_cluster.ecs_ha_cluster.name
}

output "servicename1" {
    value = aws_ecs_service.ecs_ha1.name
}

output "servicename2" {
    value = aws_ecs_service.ecs_ha2.name
}