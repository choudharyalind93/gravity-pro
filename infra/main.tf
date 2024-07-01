provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

# Create a VPC 

resource "google_compute_network" "vpc_network" {
  name                    = "cicd-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "cicd-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "${var.region}"
  network       = google_compute_network.vpc_network.name
}

# Create firewall rules to allow internal and external traffic

resource "google_compute_firewall" "internal" {
  name    = "internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "external" {
  name    = "external"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_container_cluster" "primary" {
  name     = "cicd-gke-cluster"
  location = "${var.region}"
  remove_default_node_pool = true
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/sqlservice.admin",    
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "node_pool" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 100
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

output "node_pool_name" {
  value = google_container_node_pool.node_pool.name
}

# Create a Google Cloud Storage bucket

resource "google_storage_bucket" "bucket" {
  name          = "${var.project_id}"
  location      = "${var.region}"
  force_destroy = true
}

# Create a Cloud SQL instance for PostgreSQL
resource "google_sql_database_instance" "postgres" {
  name             = "postgres-instance"
  database_version = "POSTGRES_13"
  region           = "${var.region}"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "default" {
  name     = "cicd"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "default" {
  name     = "root"
  instance = google_sql_database_instance.postgres.name
  password = "Pa5ssw0rd"
}

output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "storage_bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "sql_instance_name" {
  value = google_sql_database_instance.postgres.name
}