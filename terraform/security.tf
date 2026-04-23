resource "yandex_vpc_security_group" "internal" {
  name       = "internal-rules"
  network_id = yandex_vpc_network.bastion-network.id

  ingress {
    protocol       = "ANY"
    description    = "permit any connections from local networks"
	predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "permit any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sec-bastion" {
  name       = "sec-bastion-rules"
  network_id = yandex_vpc_network.bastion-network.id

  ingress {
    protocol       = "TCP"
    description    = "allows SSH connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allows ICMP connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "permit any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sec-zabbix" {
  name       = "sec-zabbix-rules"
  network_id = yandex_vpc_network.bastion-network.id

  ingress {
    protocol       = "TCP"
    description    = "allows TCP connections on port 10051 for Zabbix"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Allows TCP connections on port 80 for Zabbix"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  ingress {
    protocol       = "ICMP"
    description    = "allows ICMP connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "permit any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sec-kibana" {
  name       = "sec-kibana-rules"
  network_id = yandex_vpc_network.bastion-network.id

  ingress {
    protocol       = "TCP"
    description    = "allows TCP connections on port 5601 for Kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allows ICMP connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "permit any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sec-balancer" {
  name       = "sec-balancer-rules"
  network_id = yandex_vpc_network.bastion-network.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allows ICMP connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "permit any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
