resource "google_compute_instance" "bastion_instance" {
  name         = "my-bastion"
  machine_type = "n1-standard-1"
  zone         = "southamerica-east1"
  tags         = ["bastion"]
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Configure the desired access configuration for the bastion instance
    }
  }
}
