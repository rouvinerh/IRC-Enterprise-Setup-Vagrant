output "public_subnet" {
  value = aws_subnet.public.cidr_block
}

output "internal_subnet" {
  value = aws_subnet.internal.cidr_block
}

output "router_private_ip" {
  value = aws_instance.router.private_ip
}

output "router_public_ip" {
  value = aws_instance.router.public_ip
}

output "attacker_private_ip" {
  value = aws_instance.attacker.private_ip
}

output "attacker_public_ip" {
  value = aws_instance.attacker.public_ip
}

output "siem_private_ip" {
  value = aws_instance.siem.private_ip
}

output "siem_public_ip" {
  value = aws_instance.siem.public_ip
}

output "DC_private_ip" {
  value = aws_instance.DC.private_ip
}

output "DC_public_ip" {
  value = aws_instance.DC.public_ip
}

output "ubuntu_web_server_private_ip" {
  value = aws_instance.ubuntu_web_server.private_ip
}

output "ubuntu_web_server_public_ip" {
  value = aws_instance.ubuntu_web_server.public_ip
}

output "windows_host_private_ip" {
  value = aws_instance.windows_host.private_ip
}

output "windows_host_public_ip" {
  value = aws_instance.windows_host.public_ip
}