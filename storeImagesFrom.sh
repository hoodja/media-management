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


find $* \( -iname '*.jpeg' -or -iname '*.jpg' -or -iname '*.png' -or -iname '*.gif' \) -print0 | while read -d $'\0' file; do
  CAMERA_PATH=$file
  CAMERA_FILE="$(basename "$CAMERA_PATH")"

  STORE_LOCATION="$(exiftool -EXIF:CreateDate -EXIF:DateTimeOriginal -IFD0:ModifyDate -FileModifyDate -d %Y/%B "$CAMERA_PATH" | grep -e "[0-9]\{4\}/[a-zA-Z]*" | head -n 1 | sed -e 's/ *//g' -e 's/^[^:]*://')"
  if [[ "$STORE_LOCATION" == "" ]]; then
    echo "WARN: Unknown location for $file"
    STORE_LOCATION="UNKNOWN"
  fi
  STORE_DIR="$MOUNT_POINT/$STORE_LOCATION"
  STORE_PATH="$STORE_DIR/$CAMERA_FILE"

  if [[ -f "$STORE_PATH" ]]; then
    if [[ "$(shasum "$CAMERA_PATH" | sed -e 's/ .*$//')" == "$(shasum "$STORE_PATH" | sed -e 's/ .*$//')" ]]; then
      continue
    else
      echo "DIFFERENT: $STORE_PATH $CAMERA_PATH"
      continue
    fi
  fi

  echo "storing $STORE_PATH"
  mkdir -p "$STORE_DIR" && cp -p -n "$CAMERA_PATH" "$STORE_PATH" && rm "$CAMERA_PATH"
  if [[ $? == 0 ]]; then
    ./retouch.sh "$STORE_PATH"
  else
    echo "WARN: $STORE_PATH not saved"
  fi
done

diskutil umount $MOUNT_POINT
