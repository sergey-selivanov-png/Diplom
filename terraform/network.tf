# Сеть
resource "yandex_vpc_network" "bastion-network" {
  name = "bastion-network"
}

# Внешняя подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.bastion-network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Внутренняя подсеть
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.bastion-network.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# Зона A
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.bastion-network.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# Зона B
resource "yandex_vpc_subnet" "private-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.bastion-network.id
  v4_cidr_blocks = ["10.0.4.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}


# NAT-шлюз
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  name = "nat_route"
  network_id = yandex_vpc_network.bastion-network.id 

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
