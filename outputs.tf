output "instance_id" {
  description = "ID"
  value       = aws_instance.instance.*.id

}

output "instance_public_ip" {
  description = "public ip"
  value       = aws_instance.instance.*.public_ip
}

output "instance_private_ip" {
  description = "privat ip"
  value       = aws_instance.instance.*.private_ip
}

output "DNS" {
  value = aws_instance.instance.*.public_dns
}

output "machines" {
  value = aws_instance.instance.*.arn
}
/*
output "public_key_openssh" {
  value = aws_key_pair.generated_key.public_key
}
*/

output "gw" {
  value = var.rt_cidr_block
}

output "ff1" {
  value = aws_internet_gateway.gw.id 
}

 # value =var.vpc_cidr_block
 # value =var.sbn_cidr_block
  
