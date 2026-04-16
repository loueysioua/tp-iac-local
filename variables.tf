# ==============================================================
# variables.tf — Paramètres configurables de l'infrastructure
# TP IaC Local — Partie I
# ==============================================================

# ---------------------------------------------------------------
# Variables de Base de Données (PostgreSQL)
# ---------------------------------------------------------------

variable "db_name" {
  description = "Nom de la base de données PostgreSQL à créer au démarrage."
  type        = string
  default     = "devops_db"
}

variable "db_user" {
  description = "Nom d'utilisateur administrateur PostgreSQL."
  type        = string
  default     = "devops_user"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL. ATTENTION : en production, utiliser un secret manager !"
  type        = string
  default     = "strongpassword123"
  sensitive   = true # Masqué dans les logs Terraform
}

variable "db_port_external" {
  description = "Port externe exposé pour PostgreSQL (mappé au 5432 interne)."
  type        = number
  default     = 5433
}

# ---------------------------------------------------------------
# Variables d'Application Web (Nginx)
# ---------------------------------------------------------------

variable "app_port_external" {
  description = "Port externe pour accéder à l'application web (mappé au port 80 interne)."
  type        = number
  default     = 8080
}

variable "app_container_name" {
  description = "Nom du conteneur Docker de l'application web."
  type        = string
  default     = "tp-app-web"
}

variable "db_container_name" {
  description = "Nom du conteneur Docker de la base de données."
  type        = string
  default     = "tp-db-postgres"
}
