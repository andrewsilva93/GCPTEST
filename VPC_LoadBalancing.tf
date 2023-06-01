resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.name
  region        = "southamerica-east1"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc_network.name
  region        = "southamerica-east1"
}


#Load Balancing

resource "google_compute_global_forwarding_rule" "load_balancer" {
  name        = "my-load-balancer"
  target      = google_compute_target_http_proxy.target_proxy.self_link
  port_range  = "80"
  ip_address  = "0.0.0.0"
}

resource "google_compute_http_health_check" "health_check" {
  name               = "my-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  unhealthy_threshold = 2
  healthy_threshold   = 2
  port               = 80
  request_path       = "/"
}

resource "google_compute_target_pool" "target_pool" {
  name        = "my-target-pool"
  health_checks = [google_compute_http_health_check.health_check.self_link]
}

resource "google_compute_http_proxy" "http_proxy" {
  name        = "my-http-proxy"
  url_map     = google_compute_url_map.url_map.self_link
}

resource "google_compute_target_http_proxy" "target_proxy" {
  name        = "my-target-proxy"
  url_map     = google_compute_url_map.url_map.self_link
}

resource "google_compute_url_map" "url_map" {
  name        = "my-url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_backend_service" "backend_service" {
  name        = "my-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_instance_group.instance_group_manager.self_link
  }

  health_checks = [google_compute_http_health_check.health_check.self_link]
}

resource "google_compute_instance_group_manager" "instance_group_manager" {
  name        = "my-instance-group-manager"
  base_instance_name = "my-instance"
  zone        = "southamerica-east1-a"
  target_size = 1
  target_pools = [google_compute_target_pool.target_pool.self_link]
}

resource "google_compute_instance_template" "instance_template" {
  name = "my-instance-template"
  description = "My instance template"
  machine_type = "n1-standard-1"
  tags = ["http-server", "https-server"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
    auto_delete  = true
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.load_balancer_ip.address
    }
  }

  metadata_startup_script = <<EOF
    #!/bin/bash
    echo "Hello, World!" > /var/www/html/index.html
    service apache2 restart
    EOF
}

resource "google_compute_address" "load_balancer_ip" {
  name   = "my-load-balancer-ip"
  region = "southamerica-east1"
}
