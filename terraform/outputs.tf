# Bastion
output "nat-bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}
output "bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "FQDN_bastion" {
  value = yandex_compute_instance.bastion.fqdn
}

# Web-server 1
output "nginx-1" {
  value = yandex_compute_instance.nginx-1.network_interface.0.ip_address
}
output "FQDN_nginx-1" {
  value = yandex_compute_instance.nginx-1.fqdn
}

# Web-server 2
output "nginx-2" {
  value = yandex_compute_instance.nginx-2.network_interface.0.ip_address
}
output "FQDN_nginx-2" {
  value = yandex_compute_instance.nginx-2.fqdn
}


# Balancer
output "load_balancer" {
  value = yandex_alb_load_balancer.web-balancer.listener.0.endpoint.0.address.0.external_ipv4_address
}

# Zabbix
output "nat-zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}
output "zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}
output "FQDN_zabbix" {
  value = yandex_compute_instance.zabbix.fqdn
}


# Elasticsearch
output "elasticsearch" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}
output "FQDN_elasticsearch" {
  value = yandex_compute_instance.elasticsearch.fqdn
}


# Kibana
output "nat-kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
output "kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "FQDN_kibana" {
  value = yandex_compute_instance.kibana.fqdn
}
