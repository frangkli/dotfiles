output "vm" {
  value = {
    name         = google_compute_instance.devbox.name
    zone         = google_compute_instance.devbox.zone
    machine_type = google_compute_instance.devbox.machine_type
    internal_ip  = google_compute_instance.devbox.network_interface[0].network_ip
  }
}

output "ssh_break_glass" {
  description = "SSH through Google's IAP tunnel, for when Tailscale is down."
  value       = "gcloud compute ssh ${google_compute_instance.devbox.name} --zone ${google_compute_instance.devbox.zone} --tunnel-through-iap"
}

output "serial_console" {
  value = "gcloud compute connect-to-serial-port ${google_compute_instance.devbox.name} --zone ${google_compute_instance.devbox.zone}"
}
