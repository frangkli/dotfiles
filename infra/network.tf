resource "google_compute_network" "devbox" {
  name                    = "devbox"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "devbox" {
  name                     = "devbox-${var.region}"
  network                  = google_compute_network.devbox.id
  region                   = var.region
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}

# Break-glass SSH through Google's IAP tunnel; day-to-day access is Tailscale.
resource "google_compute_firewall" "iap_ssh" {
  name          = "devbox-allow-iap-ssh"
  network       = google_compute_network.devbox.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["devbox"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Direct Tailscale connections instead of relays; WireGuard drops anything unauthenticated.
resource "google_compute_firewall" "tailscale_udp" {
  name          = "devbox-allow-tailscale-udp"
  network       = google_compute_network.devbox.id
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["devbox"]

  allow {
    protocol = "udp"
    ports    = ["41641"]
  }
}
