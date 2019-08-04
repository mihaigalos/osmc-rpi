#! /bin/bash
set -e
set -u
set -x

function set_variables {
  OSMC_VERSION=20190623
  OSMC_URL="http://download.osmc.tv/installers/diskimages/OSMC_TGT_rbp2_${OSMC_VERSION}.img.gz"
  DOWNLOAD_DIR=/home/osmc/Downloads
  EXTRACT_DIR=/home/osmc/Downloads/DockerImages
  MOUNT_DIR=/home/osmc/Downloads/DockerImagesMnt/
  LOOP_DEV=/dev/loop1 # Loop device used for mounting .img file
}

function make_directories {
  mkdir -p "${DOWNLOAD_DIR}"
  mkdir -p "${EXTRACT_DIR}"
  mkdir -p "${MOUNT_DIR}"
}

function get_osmc_image {
  curl -L "$OSMC_URL" -o "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz"
}

function setup_downloaded_image_as_loopback {
  gunzip "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz" # extract image
  sudo losetup -P "${LOOP_DEV}" "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
  sudo mount "${LOOP_DEV}p1" "${MOUNT_DIR}"
  cp -f "${MOUNT_DIR}/filesystem.tar.xz" "${EXTRACT_DIR}"
}

function remove_image {
  sudo umount "${MOUNT_DIR}"
  sudo losetup -d "${LOOP_DEV}"
  rm -f "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
}

function create_docker {
  cat "${EXTRACT_DIR}/filesystem.tar.xz" | docker import - "mihaigalos/osmc-rpi:base_${OSMC_VERSION}"
}

function remove_filesystem {
  rm -f "${EXTRACT_DIR}/filesystem.tar.xz"
}

set_variables
make_directories
get_osmc_image
setup_downloaded_image_as_loopback
remove_image
create_docker
remove_filesystem
