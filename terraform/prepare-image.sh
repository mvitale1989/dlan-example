#!/bin/bash
set -exu

OUTPUT_FILE=${1:?The output image path should be passed as an argument to this script}
SCRIPT_PATH="$(dirname $(realpath $0))"
BASEIMG_FILE="${SCRIPT_PATH}/volumes/openwrt-baseimage.img"

for COMMAND in flock curl gzip virt-copy-in; do
  which "${COMMAND}" >/dev/null 2>&1 || {
    echo "Missing required CLI tool: ${COMMAND}. Aborting."
    exit 1
  }
done

# Pull base image once
exec 200> "${SCRIPT_PATH}/volumes/.openwrt-baseimage.img.lock"
flock 200
[ -f "${BASEIMG_FILE}" ] || {
   curl -L -o "${BASEIMG_FILE}.gz" "https://downloads.openwrt.org/releases/19.07.3/targets/x86/64/openwrt-19.07.3-x86-64-rootfs-ext4.img.gz";
   gzip -d "${BASEIMG_FILE}.gz";
}
flock -u 200

# Copy base image, and configure it
cp "${BASEIMG_FILE}" "${OUTPUT_FILE}"
sudo -n virt-copy-in -a "${OUTPUT_FILE}" "${SCRIPT_PATH}/files/99_local.sh" "/etc/uci-defaults/"
