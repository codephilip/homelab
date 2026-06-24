output "vm_ips" {
  description = "Map of VM name -> IP address"
  value       = { for name, vm in local.vms : name => vm.ip }
}

output "ssh_targets" {
  description = "Quick-paste ssh commands for each VM"
  value       = { for name, vm in local.vms : name => "ssh ubuntu@${vm.ip}" }
}
