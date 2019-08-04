#! /bin/bash
set -e
set -u
set -x

function set_variables {
  homedir=~
  eval homedir=$homedir
  OSMC_VERSION=20190623
  OSMC_URL="http://download.osmc.tv/installers/diskimages/OSMC_TGT_rbp2_${OSMC_VERSION}.img.gz"
  DOWNLOAD_DIR=$homedir/Downloads
  EXTRACT_DIR=$homedir/Downloads/DockerImages
  MOUNT_DIR=$homedir/Downloads/DockerImagesMnt/
  LOOP_DEV=/dev/loop1 # Loop device used for mounting .img file
  echo ""
}

function make_directories {
  mkdir -p "${DOWNLOAD_DIR}"
  mkdir -p "${EXTRACT_DIR}"
  mkdir -p "${MOUNT_DIR}"
  echo ""
}

function get_osmc_image {
  curl -L "$OSMC_URL" -o "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz"
  echo ""
}

function setup_downloaded_image_as_loopback {
  gunzip "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz" # extract image
  sudo losetup -P "${LOOP_DEV}" "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
  sudo mount "${LOOP_DEV}p1" "${MOUNT_DIR}"
  cp -f "${MOUNT_DIR}/filesystem.tar.xz" "${EXTRACT_DIR}"
  echo ""
}

function remove_image {
  sudo umount "${MOUNT_DIR}"
  sudo losetup -d "${LOOP_DEV}"
  rm -f "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
  echo ""
}

function create_docker {
  cat "${EXTRACT_DIR}/filesystem.tar.xz" | docker import - "mihaigalos/osmc-rpi:base_${OSMC_VERSION}"
  echo ""
}

function remove_filesystem {
  rm -f "${EXTRACT_DIR}/filesystem.tar.xz"
  echo ""
}

set_variables
make_directories
get_osmc_image
setup_downloaded_image_as_loopback
remove_image
create_docker
remove_filesystem
