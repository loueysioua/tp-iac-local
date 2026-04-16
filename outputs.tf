# ==============================================================
# outputs.tf — Informations affichées après terraform apply
# ==============================================================

output "db_container_name" {
  description = "Nom du conteneur de la base de données PostgreSQL."
  value       = docker_container.db_container.name
}

output "db_container_id" {
  description = "ID court du conteneur PostgreSQL (12 premiers caractères)."
  value       = substr(docker_container.db_container.id, 0, 12)
}

output "app_container_name" {
  description = "Nom du conteneur de l'application web Nginx."
  value       = docker_container.app_container.name
}

output "app_access_url" {
  description = "URL complète pour accéder à l'application web dans le navigateur."
  value       = "http://localhost:${docker_container.app_container.ports[0].external}"
}

output "db_connection_string" {
  description = "Chaîne de connexion PostgreSQL (sans mot de passe)."
  value       = "postgresql://${var.db_user}@localhost:${var.db_port_external}/${var.db_name}"
  sensitive   = false
}

output "deployment_summary" {
  description = "Résumé du déploiement."
  value = {
    web_app  = "http://localhost:${var.app_port_external}"
    database = "localhost:${var.db_port_external}"
    db_name  = var.db_name
  }
}
