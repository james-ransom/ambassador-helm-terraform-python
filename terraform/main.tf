provider "google" {
  project     = var.project
  credentials = file("../../secret.json")
}

resource "google_container_cluster" "primary" {
  name     = "lab-setup"
  location = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "lab-setup-node-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 3
  autoscaling {
    min_node_count = 3
    max_node_count = 10
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
