terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "docker" {}
provider "local" {}

resource "docker_image" "smart_city" {
  name = "urbanhub-ansible:${var.environment}"

  build {
    context = "."
  }
}

resource "docker_container" "smart_city" {
  name  = "urbanhub-${var.environment}"
  image = docker_image.smart_city.image_id

  ports {
    internal = 22
    external = var.ssh_port
    ip       = "127.0.0.1"
  }

  ports {
    internal = 80
    external = var.http_port
    ip       = "127.0.0.1"
  }

  must_run = true

  upload {
    file    = "/home/ansible/.ssh/authorized_keys"
    content = file("${path.module}/authorized_keys")
  }

  command = ["/usr/sbin/sshd", "-D"]
}

resource "local_file" "inventory" {
  filename = "${path.module}/inventory-${var.environment}.ini"

  content = <<EOT
[smartcity]
urbanhub-${var.environment} ansible_host=127.0.0.1 ansible_port=${var.ssh_port} ansible_user=ansible ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOT
}
