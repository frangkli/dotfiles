# infra

The box: one GCP VM in us-west1, set up with OpenTofu and cloud-init. This is a snapshot from October 2026, not kept in sync with what I actually run.

| File | What it holds |
|---|---|
| `versions.tf` | OpenTofu and Google provider versions |
| `variables.tf` | Every knob: project, machine type, disk sizes, user |
| `network.tf` | Private network; the only inbound rules are SSH through Google's IAP tunnel and Tailscale's UDP port |
| `compute.tf` | VM, boot disk, a separate data disk for `/home`, daily snapshots |
| `cloud-init.yaml` | First boot: user, data disk, Docker, Tailscale, zram and earlyoom |
| `outputs.tf` | Break-glass SSH and serial-console commands |
| `tailscale/policy.hujson` | Example tailnet policy |

## Use

Needs `gcloud` logged in (`gcloud auth application-default login`) and OpenTofu. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your project and user.

```bash
tofu init
tofu plan
tofu apply
```

State stays local and gitignored.

## After the first apply

1. Wait about 5 minutes for cloud-init, then connect: `gcloud compute ssh <name> --zone <zone> --tunnel-through-iap`.
2. Check it finished: `cloud-init status --wait` and `df -h /data /home`.
3. Join Tailscale: `sudo tailscale up --ssh --advertise-tags=tag:devbox --hostname=<name>`, then `sudo tailscale set --auto-update --accept-dns=false --operator=<user>`.
4. Set a serial-console password (`sudo passwd <user>`) for when everything else is broken.

## Resize

Change `machine_type` and run `tofu apply`. The VM stops, changes type and starts in a minute or two; disks and the Tailscale identity stay. Grow a disk by raising `data_disk_gb` or `boot_disk_gb`, then run `sudo xfs_growfs /data` (data) or reboot (boot). Disks never shrink.

## Rebuild

`cloud-init.yaml` only runs on a new VM. To rebuild, turn off `deletion_protection` and run `tofu apply -replace=google_compute_instance.devbox`. The data disk, and with it `/home`, is kept and reattached.
