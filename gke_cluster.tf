resource "google_container_cluster" "cluster" {
  name     = "my-cluster"
  location = "southamerica-east1"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "node_pool" {
  name       = "my-node-pool"
  location   = "southamerica-east1"
  cluster    = google_container_cluster.cluster.name
  node_count = 1
  version    = "1.19"
}

output "kubeconfig" {
  value = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
}
