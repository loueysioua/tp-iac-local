# ---------------------------------------------------------------
# 1. Configuration Terraform et déclaration du Provider
# ---------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Connexion au démon Docker local (socket par défaut)
provider "docker" {
  # host = "unix:///var/run/docker.sock"  # Décommenter si nécessaire
}

# ---------------------------------------------------------------
# 2. Ressources : Base de Données PostgreSQL
# ---------------------------------------------------------------

# Téléchargement de l'image officielle PostgreSQL depuis Docker Hub
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true # Conserve l'image localement après terraform destroy
}

# Création et configuration du conteneur PostgreSQL
resource "docker_container" "db_container" {
  name  = var.db_container_name
  image = docker_image.postgres_image.image_id

  # Mappage du port PostgreSQL (interne 5432 → externe configurable)
  ports {
    internal = 5432
    external = var.db_port_external
  }

  # Variables d'environnement
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]

  # Redémarrage automatique du conteneur en cas de crash
  restart = "unless-stopped"

  # Healthcheck — vérifie que PostgreSQL accepte les connexions
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.db_user} -d ${var.db_name}"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "10s"
  }
}

# ---------------------------------------------------------------
# 3. Ressources : Application Web Nginx
# ---------------------------------------------------------------

# Construction de l'image Docker à partir du Dockerfile_app local
resource "docker_image" "app_image" {
  name = "tp-web-app:latest"

  build {
    context    = path.module   # Répertoire courant (là où se trouve main.tf)
    dockerfile = "Dockerfile_app"

    # Force la reconstruction si le Dockerfile change (hash du fichier)
    build_args = {}
  }

  # Reconstruction forcée si le Dockerfile est modifié
  triggers = {
    dockerfile_hash = filemd5("${path.module}/Dockerfile_app")
  }
}

# Création du conteneur de l'application web Nginx
resource "docker_container" "app_container" {
  name  = var.app_container_name
  image = docker_image.app_image.image_id

  # Dépendance explicite : la DB doit être démarrée avant l'application
  depends_on = [
    docker_container.db_container
  ]

  # Mappage du port Nginx (interne 80 → externe configurable, défaut 8080)
  ports {
    internal = 80
    external = var.app_port_external
  }

  restart = "unless-stopped"
}
