locals {
  helm_charts_path        = pathexpand("${path.module}/../../modules/helm")
  dashed_domain_name      = replace(var.domain_name, ".", "-")
  metallb_namespace       = kubernetes_namespace.metallb_system.metadata.0.name
  cert_manager_namespace  = kubernetes_namespace.cert_manager.metadata.0.name
  ingress_nginx_namespace = kubernetes_namespace.ingress_nginx.metadata.0.name

  cert_manager_cluster_issuer_name = "letsencrypt-prod"
}

#############################################################
# MetalLB
# Ref: https://github.com/metallb/metallb
#############################################################
resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"

    labels = {
      app = "metallb"
    }
  }
}

resource "kubernetes_config_map" "metallb_config" {
  metadata {
    namespace = local.metallb_namespace
    name = "config"
  }

  data = {
    config = <<EOF
address-pools:
- name: default
  protocol: layer2
  addresses:
  - ${var.metallb_ip_range}
EOF
  }

}

resource "helm_release" "metallb" {
  chart = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  name = "metallb"
  namespace = local.metallb_namespace

  set {
    name = "existingConfigMap"
    value = kubernetes_config_map.metallb_config.metadata[0].name
  }
}

#############################################################
# Nginx Ingress
# Ref: https://github.com/kubernetes/ingress-nginx
#############################################################
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/name"      = "ingress-nginx"
      "app.kubernetes.io/component" = "ingress-controller"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  namespace   = local.ingress_nginx_namespace
}

#############################################################
# Cert Manager
# Ref: https://github.com/jetstack/cert-manager
#############################################################
locals {
  cert_manager_helm_values = {
    installCRDs = true,
    podLabels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
    extraArgs = [
      "--dns01-recursive-nameservers=1.1.1.1:53\\,8.8.8.8:53"
    ]
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  namespace   = local.cert_manager_namespace

  values = [
    yamlencode(local.cert_manager_helm_values)
  ]
}

# Cloudflare API token
# Used by cert manager for DNS challenges
resource "kubernetes_secret" "cloudflare_key_secret" {
  count = length(var.cloudflare_api_token) > 0 ? 1 : 0

  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = local.cert_manager_namespace
  }

  data = {
    api-token = var.cloudflare_api_token
  }

}

# Cluster issuer resource
resource "helm_release" "cert_manager_cluster_issuer" {
  count = length(var.cloudflare_account_email) > 0 ? 1 : 0

  chart = "${local.helm_charts_path}/cert-manager-resources/cluster-issuer"
  name = "cert-manager-cluster-issuer"

  set {
    name = "name"
    value = local.cert_manager_cluster_issuer_name
  }

  set {
    name = "email"
    value = var.cloudflare_account_email
  }

  set {
    name = "apiTokenSecretRef.enabled"
    value = "true"
  }

  set {
    name = "apiTokenSecretRef.name"
    value = "cloudflare-api-token-secret"
  }

  set {
    name = "apiTokenSecretRef.key"
    value = "api-token"
  }

  set {
    name = "dnsZones"
    value = "{${join(",", [ var.cloudflare_zone_name, "*.${var.cloudflare_zone_name}" ])}}"
  }

  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_key_secret,
  ]

}

//// Wildcard certificate
//resource "helm_release" "cert_manager_wildcard_certificate" {
//  count = length(var.cloudflare_account_email) > 0 ? 1 : 0
//
//  chart = "${local.helm_charts_path}/cert-manager-resources/certificate"
//  name  = "cert-manager-wildcard-certificate"
//
//  set {
//    name = "name"
//    value = "letsencrypt-wildcard"
//  }
//
//  set {
//    name = "namespace"
//    value = local.cert_manager_namespace
//  }
//
//  set {
//    name = "secretName"
//    value = "letsencrypt-wildcard-secret"
//  }
//
//  set {
//    name = "dnsNames"
//    value = "{${join(",", [ "*.${var.cloudflare_zone_name}" ])}}"
//  }
//
//  set {
//    name = "issuerRef.name"
//    value = local.cert_manager_cluster_issuer_name
//  }
//
//  set {
//    name = "issuerRef.kind"
//    value = "ClusterIssuer"
//  }
//
//  depends_on = [
//    helm_release.cert_manager,
//  ]
//
//}
//resource "kubernetes_ingress" "elasticsearch_web_ui_dejavu_ingress" {
//  count = 1
//  metadata {
//    name      = "elasticsearch-ui-dejavu-ingress"
//    namespace = local.db_namespace
//    annotations = {
//      "nginx.ingress.kubernetes.io/rewrites-target" = "/"
//      "nginx.ingress.kunernetes.io/ssl-redirect"    = "false"
//      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
//    }
//  }
//  spec {
//    tls {
//      hosts = [
//        "*.${var.domain_name}",
//      ]
//      secret_name = local.db_namespace_certificate_name
//    }
//
//    backend {
//      service_name = "elasticsearch-ui-service"
//      service_port = 80
//    }
//
//    rule {
//      host = "testo.${var.domain_name}"
//      http {
//        path {
//          path = "/"
//          backend {
//            service_name = "elasticsearch-ui-service"
//            service_port = 80
//          }
//        }
//
//      }
//    }
//
//  }
//
//}

#############################################################
# Kubernetes Dashboard
# Ref: https://github.com/kubernetes/dashboard
#############################################################
// Note: Dashboard is installed by kubespray
// By default kubernetes-dashboard cluster role binding does not have access to cluster resources
// At the moment there is no way to mutate existing resources
// We delete existing binding a create new one with desired permissions
resource "null_resource" "kubernetes_dashboard_remove_role_binding" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.k8s_config_file_path
    }
    command     = "kubectl delete clusterrolebindings.rbac.authorization.k8s.io kubernetes-dashboard"
    on_failure  = continue
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }

  depends_on = [
    null_resource.kubernetes_dashboard_remove_role_binding
  ]

}

# Proxy K8s dashboard through Pomerium
resource "kubernetes_ingress" "k8s_dashboard_ingress" {
  metadata {
    namespace = "default"
    name      = "k8s-dashboard-forwardauth"

    annotations = {
      "kubernetes.io/ingress.class"                   = "nginx"
      "cert-manager.io/cluster-issuer"                = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/backend-protocol"  = "HTTPS"

    }
  }
  spec {
    tls {
      hosts = [
        "k8s-dashboard.${var.domain_name}"
      ]
      secret_name = "k8s-dashboard-${replace(var.domain_name, ".", "-")}"
    }

    rule {
      host = "k8s-dashboard.${var.domain_name}"
      http {
        path {
          path = "/"
          backend {
            service_name = "pomerium-proxy"
            service_port = 443
          }
        }
      }
    }

  }
}

#############################################################
# Pomerium
# Ref:
# https://github.com/pomerium/pomerium-helm
# https://www.pomerium.io/
#############################################################
locals {
  pomerium_config = {
    image = {
      tag = "master"
      pullPolicy = "Always"
    }
    // TODO: Add hosted IDP (Keycloak or Dex)
    authenticate = {
      idp = {
        provider = "github"
        clientID = var.github_oauth_client_id
        clientSecret = var.github_oauth_client_secret
      }
    }

    forwardAuth = {
      enabled = true
    }

    config = {
      rootDomain = var.domain_name
      policy = [
        # K8s Dashboard
        {
          from = "https://k8s-dashboard.${var.domain_name}"
          to = "https://kubernetes-dashboard.kube-system.svc.cluster.local"
          // preserve_host_header = true
          // allow_websockets: true
          // TODO: Remove static list of users, replace it with centralized solution
          allowed_users = [
            var.user_email
          ]
          tls_skip_verify = true
          set_request_headers = {
            Authorization = "Bearer ${var.k8s_dashboard_token}"
          }
        },
        # PiHole
        {
          from = "https://pihole.${var.domain_name}"
          to = "http://pihole-service.default.svc.cluster.local"
          allowed_users = [
            var.user_email
          ]
        },
        # qBittorrent
        {
          from = "https://qbittorrent.${var.domain_name}"
          to = "http://qbittorrent-service.media.svc.cluster.local"
          allowed_users = [
            var.user_email
          ]
        },
      ]
    }

    ingress = {
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
        "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }

      secretName = "pomerium-ingress-tls"
    }
  }

}

resource "helm_release" "pomerium" {
  name  = "pomerium"
  chart = "pomerium"
  repository = "https://helm.pomerium.io"

  values = [
    yamlencode(local.pomerium_config)
  ]
}
