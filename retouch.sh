#!/bin/bash
function die() {
  echo "$*"
  exit 1
}

[[ -f "$1" ]] || die "no such file $1"

touch_time="$(exiftool -EXIF:CreateDate -EXIF:DateTimeOriginal -IFD0:ModifyDate -FileModifyDate -d %Y%m%d%H%M.%S "$1" | grep -e "[0-9]\{12\}.[0-9]\{2\}" | head -n 1 | sed -e 's/ *//g' -e 's/^[^:]*://')"
if [[ -z "$touch_time" ]]; then
  echo "WARN: cannot get creation time for $1"
else
  echo touch -t "$touch_time" "$1"
  touch -t "$touch_time" "$1"
fi
