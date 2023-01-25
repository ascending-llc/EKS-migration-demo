###################################################################
# mysql database setup
###################################################################
# Create storage class for mysql
resource "kubernetes_storage_class_v1" "mysql-sc" {
  metadata {
    name = "mysql-sc"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp2"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  mount_options = ["debug"]
}

# Create wordpress namespace
resource "kubernetes_namespace_v1" "wordpress" {
  metadata {
    labels = {
      app = "wordpress"
    }
    name = "wordpress"
  }
}

# Create pvc for mysql
resource "kubernetes_persistent_volume_claim_v1" "mysql-pvc" {
  metadata {
    name = "mysql-pv-claim"
    labels = {
      app = "wordpress"
      }
    namespace = "wordpress"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = "${kubernetes_storage_class_v1.mysql-sc.metadata.0.name}"
  }
}

# Create service for mysql
resource "kubernetes_service_v1" "wordpress-mysql" {
  metadata {
    name = "wordpress-mysql"
    namespace = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "mysql"
    }
    cluster_ip = "None"
    port {
      port        = 3306
    }
  }
}

# Mysql secret
resource "kubernetes_secret_v1" "mysql-secret" {
  metadata {
    name = "mysql-pass"
    namespace = "wordpress"
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
}

# Mysql deployment
resource "kubernetes_deployment_v1" "wordpress-mysql" {
  metadata {
    name = "wordpress-mysql"
    namespace = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "wordpress"
        tier = "mysql"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "mysql"
        }
      }

      spec {
        container {
          image = "mysql:5.6"
          name  = "mysql"
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-pass"
                key = "password"
              }
            }
          }
          port {
            container_port = 3306
            name = "mysql"
          }
          volume_mount {
            name = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "mysql-pv-claim"

          }
        }
      }
    }
  }
}

###########################################################################
# Wordpress frontend setup
###########################################################################
# Create service for wordpress frontend
resource "kubernetes_service_v1" "wordpress-frontend" {
    metadata {
    name = "wordpress"
    namespace = "wordpress"
    labels = {
      app = "wordpress"
        }
    } 
    spec {
        selector = {
            app = "wordpress"
            tier = "frontend"
        }
        port {
            port        = 80
        }
        type = "LoadBalancer"
    }
  
}

# Create pvc for wordpress frontend
resource "kubernetes_persistent_volume_claim_v1" "wordpress-pvc" {
  metadata {
    name = "wp-pv-claim"
    labels = {
      app = "wordpress"
      }
    namespace = "wordpress"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = "${kubernetes_storage_class_v1.mysql-sc.metadata.0.name}"
  }
}

# Create deployment for wordpress frontend
resource "kubernetes_deployment_v1" "wordpress-frontend" {
  metadata {
    name = "wordpress"
    namespace = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "wordpress"
        tier = "frontend"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "frontend"
        }
      }

      spec {
        container {
          image = "wordpress:4.8-apache"
          name  = "wordpress"
          env {
            name = "WORDPRESS_DB_HOST"
            value = "wordpress-mysql"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-pass"
                key = "password"
              }
            }
          }
          port {
            container_port = 80
            name = "wordpress"
          }
          volume_mount {
            name = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }
        }
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = "wp-pv-claim"

          }
        }
      }
    }
  }
}