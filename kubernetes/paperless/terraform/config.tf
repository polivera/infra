resource "kubernetes_config_map" "postgres" {
  metadata {
    name      = "postgres-config"
    namespace = var.namespace
  }
  data = {
    POSTGRES_DB_HOST = "postgres" // Could this be on service name?
    POSTGRES_DB      = "paperless"
    POSTGRES_USER    = "upaperless"
  }
}

resource "kubernetes_config_map" "redis" {
  metadata {
    name = "redis-config"
    namespace = var.namespace
  }
  data = {
    REDIS_HOST = "redis://redis:6379"
  }
}

resource "kubernetes_config_map" "paperless" {
  metadata {
    name = "paperless-config"
    namespace = var.namespace
  }
  data = {
    PAPERLESS_URL = "https://paper.vicugna.party"
    PAPERLESS_TIME_ZONE = "Europe/Madrid"
    PAPERLESS_OCR_LANGUAGE = "spa"
    PAPERLESS_OCR_LANGUAGES = "eng spa"
    PAPERLESS_CONSUMER_DISABLE= "true"
    PAPERLESS_ALLOWED_HOSTS = "*"
    PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.vicugna.party"
    PAPERLESS_FORCE_SCRIPT_NAME = ""
    PAPERLESS_STATIC_URL = "/static/"
    PAPERLESS_USE_X_FORWARDED_HOST = "true"
    PAPERLESS_USE_X_FORWARDED_PORT = "true"
  }
}