variable "project" {
  description = "GCP project that holds the devbox."
  type        = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "zone" {
  description = "us-west1-b had no N4D capacity on 2026-10-08."
  type        = string
  default     = "us-west1-a"
}

variable "name" {
  description = "VM name; also the hostname."
  type        = string
  default     = "devbox-gcp-1"
}

variable "machine_type" {
  description = "Resize by changing this and running `tofu apply` (stops and starts the VM)."
  type        = string
  default     = "n4d-standard-8"

  validation {
    condition     = can(regex("^(n4d|c4d)-", var.machine_type))
    error_message = "Use an N4D or C4D type; the disks are Hyperdisk, which older families don't support."
  }
}

variable "boot_disk_gb" {
  type    = number
  default = 100
}

variable "data_disk_gb" {
  description = "Grows live; can't shrink."
  type        = number
  default     = 500
}

variable "snapshot_retention_days" {
  type    = number
  default = 14
}

variable "username" {
  description = "The one Linux user for you and your agents."
  type        = string
}

variable "timezone" {
  type    = string
  default = "America/Los_Angeles"
}
