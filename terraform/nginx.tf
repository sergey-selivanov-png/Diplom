# Web-server 1

resource "yandex_compute_instance" "nginx-1" {
  name = "nginx-1"
  hostname = "nginx-1"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    security_group_ids = [yandex_vpc_security_group.internal.id]


    nat       = false
    ip_address = "10.0.3.4"
  }

  metadata = {
    user-data = file("/home/vboxuser/DipSSS/.cloud.yaml")
  }

  scheduling_policy {
    preemptible = true
  }

}


# Web-server 2 

resource "yandex_compute_instance" "nginx-2" {
  name = "nginx-2"
  hostname = "nginx-2"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-b.id
    security_group_ids = [yandex_vpc_security_group.internal.id]


    nat       = false
    ip_address = "10.0.4.4"
  }

  metadata = {
    user-data = file("/home/vboxuser/DipSSS/.cloud.yaml")
  }

    scheduling_policy {
    preemptible = true
  }
}
