
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.20"
    }
  }
}
provider "kubernetes" {
  #config_path = "kube-config.yaml"
  # create env variable KUBE_CONFIG_PATH and point it to the location of your config file
}

provider "volterra" {
    #api_p12_file = "api-creds.p12"
    #Create env variables
    #url          = "https://xc-tenant.console.ves.volterra.io/api"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.appName
    namespace = var.xcNamespace
    annotations = {
      "owner-id" = "${var.xcNamespace}"
      "ves.io/sites" = format("ves-io-system/%s", var.xcSiteName)
      "ves.io/workload-flavor" = var.xcWorkloadFlavor 
    }
  }
  spec {
    replicas = var.replicaCount
    selector {
      match_labels = {
        app = var.appName
      }
    }
    template {
      metadata {
        labels = {
          app = var.appName
        }
      }
      spec {
        image_pull_secrets {
          name = var.imagePullSecretName 
        }
        container {
          image = var.imageName
          name  = format ("%s-container", var.appName) 
          port {
            container_port = var.appPort
          }
        }
      }
    }
  }
  timeouts {
    create = "3m"
    update = "2m"
    delete = "3m"
  }
}


resource "kubernetes_service" "app-svc" {
  metadata {
    name      = format("%s-svc", var.appName)
    namespace = var.xcNamespace
    annotations = {
      "owner-id" = "${var.xcNamespace}"
      "ves.io/sites" = format("ves-io-system/%s", var.xcSiteName)
    }
  }
  spec {
    selector = {
      app = var.appName
    }
    port {
      port = var.appPort
    }
  }
  timeouts {
    create = "3m"
  }
}

resource "volterra_healthcheck" "healthcheck" {
    name                    = format("%s-healthcheck", var.appName)
    namespace               = var.xcNamespace
    http_health_check {
      path                  = var.healthcheckPath
      expected_status_codes = [
        "200"
      ]
    }
    healthy_threshold       = var.healthy_threshold
    interval                = var.interval
    timeout                 = var.timeout
    unhealthy_threshold     = var.unhealthy_threshold
}

resource "volterra_origin_pool" "origin_pool" {
    name                    = format("%s-origin-pool", var.appName)
    namespace               = var.xcNamespace
    labels = {
      owner-id = "${var.xcNamespace}"
    }
    endpoint_selection      = "LOCAL_PREFERRED"
    loadbalancer_algorithm  = "LB_OVERRIDE"
    healthcheck {
      name                  = volterra_healthcheck.healthcheck.name
      namespace             = volterra_healthcheck.healthcheck.namespace
      tenant                = var.xcTenant
    }    
    origin_servers {
            k8s_service {
                service_name = format("%s-svc.%s",var.appName, var.xcNamespace)
                site_locator {
                   site {
                     name       = var.xcSiteName
                     namespace  = "system"
                     tenant     = "ves-io"
                   }
                }
                vk8s_networks = true
            }
        }
    port = var.appPort
    no_tls = true
}

resource "volterra_http_loadbalancer" "http_lb" {
    name                    = format("%s-http-lb", var.appName)
    namespace               = var.xcNamespace
    description             = format("HTTP Load balancer for %s.%s", var.appName, var.domainName )
    labels = {
      owner-id = "${var.xcNamespace}"
    }
    domains                 = [format("%s.%s", var.appName, var.domainName)]
    advertise_on_public_default_vip = true
    disable_api_definition = true
    http {
      port = 80
      dns_volterra_managed = true
    }
    default_route_pools {
      pool {
          name = volterra_origin_pool.origin_pool.name
          namespace = volterra_origin_pool.origin_pool.namespace
      }
    }
    dynamic "app_firewall" {
      for_each = var.xcDisableWaf ? [] : [1]
      content {
        name = var.xcDisableWaf ? null : var.xcWafPolicy
        namespace =  var.xcDisableWaf ? null :  "shared"
        tenant = var.xcDisableWaf ? null : var.xcTenant 
      }
    }
    disable_waf = var.xcDisableWaf
    disable_rate_limit              = true
    round_robin                     = true
    no_challenge                    = true
}
