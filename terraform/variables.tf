variable "proxmox_api_token_prox1" {
  description = "API token for prox-1, in the form 'user@realm!tokenid=uuid'"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_prox2" {
  description = "API token for prox-2"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_prox3" {
  description = "API token for prox-3"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key baked into every VM as the ubuntu user's authorized_keys"
  type        = string
}
