# Bastion

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [
                             yandex_vpc_security_group.internal.id, 
                             yandex_vpc_security_group.sec-bastion.id
                         ]


    nat        = true
    ip_address = "10.0.1.4"
  }

  metadata = {
    user-data = file("/home/vboxuser/DipSSS/.cloud.yaml")
  }

  scheduling_policy {
    preemptible = true
  }

}

resource "local_file" "inventory" {
  content  = <<-XYZ
  [all:vars]
  ansible_user=vboxuser
  ansible_ssh_private_key_file=/home/vboxuser/.ssh/id_ed25519
  ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q vboxuser@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  
  [log]
  elastic_server ansible_host=elasticsearch.ru-central1.internal
  kibana_server  ansible_host=kibana.ru-central1.internal

  [nginx-web]
  nginx-1_server ansible_host=nginx-1.ru-central1.internal
  nginx-2_server ansible_host=nginx-2.ru-central1.internal

  [zabbix]
  zabbix_server ansible_host=zabbix.ru-central1.internal
  XYZ
  filename = "/home/vboxuser/DipSSS/ansible/hosts.ini"
}
