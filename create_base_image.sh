#!/bin/bash

OSMC_VERSION=20190623
OSMC_URL="http://download.osmc.tv/installers/diskimages/OSMC_TGT_rbp2_${OSMC_VERSION}.img.gz"
DOWNLOAD_DIR=/home/osmc/Downloads
EXTRACT_DIR=/home/osmc/Downloads/DockerImages
MOUNT_DIR=/home/osmc/Downloads/DockerImagesMnt/
LOOP_DEV=/dev/loop1 # Loop device used for mounting .img file

mkdir -p "${DOWNLOAD_DIR}"
mkdir -p "${EXTRACT_DIR}"
mkdir -p "${MOUNT_DIR}"

curl -L "$OSMC_URL" -o "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz"
gunzip "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz" # extract image


sudo losetup -P "${LOOP_DEV}" "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
sudo mount "${LOOP_DEV}p1" "${MOUNT_DIR}"

cp -f "${MOUNT_DIR}/filesystem.tar.xz" "${EXTRACT_DIR}"

sudo umount "${MOUNT_DIR}"
sudo losetup -d "${LOOP_DEV}"
rm -f "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img" # remove image

# create the docker image from the filesystem
# create the OSMC base image
cat "${EXTRACT_DIR}/filesystem.tar.xz" | docker import - "mihaigalos/osmc-rpi:base_${OSMC_VERSION}"
rm -f "${EXTRACT_DIR}/filesystem.tar.xz" # remove filesystem
