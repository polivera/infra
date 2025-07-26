

# Install kube-prometheus-stack
resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "57.2.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Disable default storage class creation since we're using manual PVs
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.prometheus.storage.class
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus.storage.size
  }

  # Grafana configuration
  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = var.grafana.storage.class
  }

  set {
    name  = "grafana.persistence.size"
    value = var.grafana.storage.size
  }

  # Enable use of secrets. This should tell terraform to use the grafana-admin-password secret
  set_sensitive {
    name  = "grafana.adminUser"  # Note: no .admin. in the middle
    value = local.secrets.grafana_admin_user
  }

  set_sensitive {
    name  = "grafana.adminPassword"  # Note: no .admin. in the middle
    value = local.secrets.grafana_admin_password
  }

  # Enable ServiceMonitor for additional scraping
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # Grafana ingress (we'll handle this manually)
  set {
    name  = "grafana.ingress.enabled"
    value = "false"
  }

  # AlertManager storage
  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName"
    value = var.alertmanager.storage.class
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.alertmanager.storage.size
  }

  # In your main.tf, add these sets:
  set {
    name  = "prometheus.prometheusSpec.securityContext.runAsUser"
    value = "0"  # root user
  }

  set {
    name  = "prometheus.prometheusSpec.securityContext.runAsGroup"
    value = "0"  # root group
  }

  set {
    name  = "prometheus.prometheusSpec.securityContext.fsGroup"
    value = "0"
  }

  set {
    name  = "prometheus.prometheusSpec.securityContext.runAsNonRoot"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    # kubernetes_persistent_volume_claim.prometheus,
    # kubernetes_persistent_volume_claim.grafana,
    # kubernetes_persistent_volume_claim.alertmanager
  ]
}

# Ingress for Grafana (nginx reverse proxy)
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
    }
  }

  spec {
    tls {
      hosts       = [var.grafana.hostname]
      secret_name = "grafana-tls"
    }

    rule {
      host = var.grafana.hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.prometheus_stack]
}