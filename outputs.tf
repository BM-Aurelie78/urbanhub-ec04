output "http_url" {
  value = "http://127.0.0.1:${var.http_port}"
}

output "inventory_file" {
  value = local_file.inventory.filename
}

output "container_name" {
  value = docker_container.smart_city.name
}
