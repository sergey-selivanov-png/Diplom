resource "yandex_compute_instance" "kibana" {

  name        = "kibana"
  hostname    = "kibana"
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
    subnet_id = yandex_vpc_subnet.public.id

    security_group_ids = [yandex_vpc_security_group.internal.id,
                          yandex_vpc_security_group.sec-kibana.id]

    nat        = true
    ip_address = "10.0.1.6"
  }

  metadata = {
    user-data = file("/home/vboxuser/DipSSS/.cloud.yaml")
  }

  scheduling_policy {
    preemptible = true
  }

}
