# Target-group

resource "yandex_alb_target_group" "web-target" {
  name        = "web-target"

  target {
    subnet_id  = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.nginx-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.nginx-2.network_interface.0.ip_address
  }
}

# Backend-group

resource "yandex_alb_backend_group" "web-backend" {
  name                     = "web-backend"

  http_backend {
    name                   = "http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.web-target.id}"]

    healthcheck {
      timeout              = "2s"
      interval             = "5s"
      healthy_threshold    = 5
      unhealthy_threshold  = 5
      http_healthcheck {
        path              = "/"
      }
    }
  }
}

# HTTP router

resource "yandex_alb_http_router" "web-router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id

  route {
    name = "my-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-backend.id
        timeout          = "60s"
      }
    }
  }
}

# ALB

resource "yandex_alb_load_balancer" "web-balancer" {
  name       = "web-balancer"

  network_id = yandex_vpc_network.bastion-network.id

  security_group_ids = [yandex_vpc_security_group.internal.id,
                        yandex_vpc_security_group.sec-balancer.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.private.id
    }
  }


  listener { 
    name = "alb-listener"
    
   endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
 
      }
    }
  }
}
