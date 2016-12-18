#!/bin/bash
function die() {
  echo "$*"
  exit 1
}

[[ -f "$1" ]] || die "no such file $1"

set -x
touch -t "$(exiftool -DateTimeOriginal -CreateDate -ModifyDate -d %Y%m%d%H%M.%S "$1" | grep -e "[0-9]\{12\}.[0-9]\{2\}" | head -n 1 | sed -e 's/ *//g' -e 's/^[^:]*://')" "$1"
