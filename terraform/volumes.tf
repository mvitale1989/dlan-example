resource "libvirt_volume" "kernel" {
  name   = "openwrt-vmlinuz.img"
  source = "https://downloads.openwrt.org/releases/19.07.3/targets/x86/64/openwrt-19.07.3-x86-64-vmlinuz"
}

resource "null_resource" "rootfs_configured" {
  count = var.node_count
  provisioner "local-exec" {
    command = "${path.module}/prepare-image.sh ${path.module}/volumes/openwrt-rootfs-${count.index}.img"
  }
  triggers = {
    uci_script_sha256 = filesha256("${path.module}/files/99_local.sh")
  }
}

resource "libvirt_volume" "rootfs" {
  count = var.node_count
  name   = "openwrt-rootfs-${count.index}.img"
  source = "${path.module}/volumes/openwrt-rootfs-${count.index}.img"
  depends_on = [
    null_resource.rootfs_configured
  ]
}
