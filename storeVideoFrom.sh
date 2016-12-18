#!/bin/bash

function die() {
  echo $*
  exit 1
}

MOUNT_POINT=/tmp/video_mnt
STORED_HASH=/tmp/stored.videos

diskutil umount $MOUNT_POINT
mkdir -p $MOUNT_POINT
mount -t afp afp://${STORE_IP:?'no STORE_IP set'}/video $MOUNT_POINT
[[ $? == 0 ]] || die "mount point didn't work"

[[ -f $MOUNT_POINT/file_shasums ]] || die "no file_shasums at mount point"
cat $MOUNT_POINT/file_shasums | sed -e 's/^\([^ ]*\).*/\1/'>$STORED_HASH

find $* \( -iname '*.mp4' -or -iname '*.mov' -or -iname '*.m4v' \) -print0 | while read -d $'\0' file; do
	CAMERA_PATH="$file"
	CAMERA_FILE="$(basename "$CAMERA_PATH")"
	SHA_SUM="$(shasum "$CAMERA_PATH" | sed -e 's/ .*$//')"

	if [[ "$(grep -F "$SHA_SUM" $STORED_HASH | wc -l)" -eq "0" ]]; then
	  echo $CAMERA_FILE seems new
	  STORE_DIR="$MOUNT_POINT/$(exiftool -DateTimeOriginal -CreateDate -ModifyDate -d %Y/%B "$CAMERA_PATH" | grep -e "[0-9]\{4\}/[a-zA-Z]*" | head -n 1 | sed -e 's/ *//g' -e 's/^[^:]*://')"
	  STORE_PATH="$STORE_DIR/$CAMERA_FILE"

	  mkdir -p $STORE_DIR && cp -p -n "$CAMERA_PATH" "$STORE_PATH" && rm "$CAMERA_PATH"
	  [[ $? == 0 ]] || echo "WARN: $STORE_PATH not saved"
          ~/video_retouch.sh "$STORE_PATH" || echo "WARN: Could not set correct timestamp on $STORE_PATH"
	else
	  echo "$CAMERA_FILE already saved"
	fi

done

diskutil umount $MOUNT_POINT
