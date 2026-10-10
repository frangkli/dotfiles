data "google_compute_image" "ubuntu" {
  project = "ubuntu-os-cloud"
  family  = "ubuntu-2604-lts-amd64"
}

# Your home lives here; it outlives the VM.
resource "google_compute_disk" "data" {
  name = "${var.name}-data"
  type = "hyperdisk-balanced"
  zone = var.zone
  size = var.data_disk_gb

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_resource_policy" "daily_snapshots" {
  name   = "${var.name}-daily-snapshots"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "10:00" # UTC; 02:00–03:00 Pacific (03:00–04:00 in winter)
      }
    }

    retention_policy {
      max_retention_days    = var.snapshot_retention_days
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = [var.region]
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "data_snapshots" {
  name = google_compute_resource_policy.daily_snapshots.name
  disk = google_compute_disk.data.name
  zone = var.zone
}

resource "google_compute_instance" "devbox" {
  name                      = var.name
  machine_type              = var.machine_type
  zone                      = var.zone
  tags                      = ["devbox"]
  deletion_protection       = true
  allow_stopping_for_update = true

  # No service_account block: the VM has no Google identity for agents to misuse.

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_gb
      type  = "hyperdisk-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.data.id
    device_name = "data" # appears as /dev/disk/by-id/google-data
  }

  network_interface {
    subnetwork = google_compute_subnetwork.devbox.id

    access_config {
      network_tier = "STANDARD" # cheaper egress; 200 GiB/mo free
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
    serial-port-enable     = "TRUE"
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      username = var.username
      timezone = var.timezone
    })
  }

  lifecycle {
    # cloud-init runs once; later edits apply to rebuilt VMs, not this one.
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      metadata["user-data"],
    ]
  }
}
