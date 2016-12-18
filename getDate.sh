#!/bin/bash


file_name="$(basename $1)"
extension="$(echo $file_name | sed -e 's/.*\.\([^.]*\)$/\1/')"


echo $file_name
echo $extension

case "$extension" in

  "gif" | "GIF")
    echo $file_name | sed -e 's/\([0-9]*\)_\([0-9]*\)_.*$/\1T\2/'
  ;;

  "jpg" | "JPG" | "jpeg" | "JPEG")
    exiftool -EXIF:CreateDate -d %Y%m%dT%H%M%S "$1" | sed -e 's/.*\([0-9]*T[0-9]*\).*$/\1/'
  ;;

  "mp4" | "MP4")
    exiftool -CreateDate -d %Y%m%dT%H%M%S "$1" | sed -e 's/.*  *\([0-9]*T[0-9]*\).*$/\1/'
  ;;

  *)
    echo "no rule for $extension ($file_name)"
  ;;

esac
