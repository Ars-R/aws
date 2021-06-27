[apache2]
%{ for num, dns_name in dns ~}
${dns_name} ansible_ssh_private_key_file=${path}${pem}.pem
%{ endfor ~}

[web1]
${web1} ansible_ssh_private_key_file=${path}${pem}.pem

[web2]
${web2} ansible_ssh_private_key_file=${path}${pem}.pem

