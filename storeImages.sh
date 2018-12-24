#!/bin/bash

function die() {
  echo $*
  exit 1
}

MOUNT_POINT=/tmp/images_mnt

diskutil umount $MOUNT_POINT
mkdir -p $MOUNT_POINT
mount -t afp afp://${STORE_IP:?'no STORE_IP set'}/images $MOUNT_POINT
[[ $? == 0 ]] || die "mount point didn't work"

#TODO: Externalize the search list
#find /Volumes/CAM_SD /Volumes/CAM_MEM /Volumes/DSLR -name '*.JPG' -print0 | while read -d $'\0' file; do
find /Volumes/CAM_SD /Volumes/CAM_MEM -name '*.JPG' -print0 | while read -d $'\0' file; do
  CAMERA_PATH=$file
  CAMERA_FILE="$(basename "$CAMERA_PATH")"

  STORE_DIR="$MOUNT_POINT/$(exiftool -EXIF:CreateDate -d %Y/%B "$CAMERA_PATH" | sed -e 's/ *//g' -e 's/^[^:]*://')"
  STORE_PATH="$STORE_DIR/$CAMERA_FILE"

  if [[ -f "$STORE_PATH" ]]; then
    if [[ "$(shasum "$CAMERA_PATH" | sed -e 's/ .*$//')" == "$(shasum "$STORE_PATH" | sed -e 's/ .*$//')" ]]; then
      continue
    else
      die "DIFFERENT: $STORE_PATH $CAMERA_PATH"
    fi
  fi

  echo "storing $STORE_PATH"
  mkdir -p "$STORE_DIR" && cp -p -n "$CAMERA_PATH" "$STORE_PATH" && ./retouch.sh "$STORE_PATH"
  [[ $? == 0 ]] || echo "WARN: $STORE_PATH not saved"
done

diskutil umount $MOUNT_POINT
