variable "environment" {
  description = "Environnement de deploiement UrbanHub"
  type        = string

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "L'environnement doit etre dev ou test."
  }
}

variable "ssh_port" {
  description = "Port SSH du conteneur UrbanHub"
  type        = number
}

variable "http_port" {
  description = "Port HTTP du conteneur UrbanHub"
  type        = number
}
