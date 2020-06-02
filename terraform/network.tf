data "template_file" "network_public_cidr" {
  count = var.node_count
  template = "192.168.${123 + count.index}.0/24"
}

resource "libvirt_network" "public" {
  count = var.node_count - 1
  name  = "openwrt-publ-${count.index}"
  bridge = "owrtpub${count.index}"
  autostart = true

  mode = "nat"
  domain = "openwrt-publ-${count.index}.lan"
  addresses = [data.template_file.network_public_cidr[count.index].rendered]
}

resource "libvirt_network" "private" {
  count = var.node_count
  name  = "openwrt-priv-${count.index}"
  bridge = "owrtpriv${count.index}"
  autostart = true

  mode = "none"
  domain = "openwrt-priv-${count.index}.lan"
  dhcp {
    enabled = false
  }
}
