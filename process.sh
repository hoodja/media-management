#!/bin/bash -x


echo "$1"
base_dir=.
unknown="$base_dir/UNKNOWN" && mkdir -p $unknown

# find the tag
for tag in CreateDate DateCreated ModifyDate DateTimeOriginal; do
  date=$(exiftool -$tag "$1" | sed -e 's/.*\([0-9][0-9][0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\).*/\1 \2 \3/')

  if [[ -n "$date" ]]; then
    break
  fi
done

#[[ -n "$date" ]] && echo "date is $date"
if [[ -z "$date" ]]; then
  echo "no date found for $1" 
  mv "$1" $unknown 
  exit 0
fi

# get the date
year="$(echo $date | sed -e 's/.*\([0-9][0-9][0-9][0-9]\) \([0-9][0-9]\) \([0-9][0-9]\).*/\1/')"
month="$(echo $date | sed -e 's/.*\([0-9][0-9][0-9][0-9]\) \([0-9][0-9]\) \([0-9][0-9]\).*/\2/')"
day="$(echo $date | sed -e 's/.*\([0-9][0-9][0-9][0-9]\) \([0-9][0-9]\) \([0-9][0-9]\).*/\3/')"
path="$base_dir/$(gdate -d "$month/$day/$year" +%Y/%B)"
echo "path is $path"
mkdir -p $path

# retouch the file
touch -t "$year$month${day}0000" "$1"

# move to the right location
mv "$1" $path
