resource "libvirt_domain" "openwrt" {
  count  = var.node_count
  name   = "openwrt-${count.index}"
  vcpu   = 1
  memory = 128
  running = true

  kernel = libvirt_volume.kernel.id
  cmdline = [{
    root = "/dev/vda"
  }]

  disk {
    volume_id = libvirt_volume.rootfs[count.index].id
  }

  dynamic "network_interface" {
    for_each = (count.index == 0 || count.index == var.node_count - 1) ? [ max(0, count.index - 1) ] : [count.index - 1, count.index]
    content {
      network_id = libvirt_network.public[network_interface.value].id
      addresses  = [
        cidrhost(data.template_file.network_public_cidr[network_interface.value].rendered, count.index + 100)
      ]
    }
  }

  network_interface {
    network_id = libvirt_network.private[count.index].id
  }

}
