#!/bin/bash
cat $1 | sed -e 's~^\([^ ]*\) *.*/\(.*\)$~\1 \2~' | sort
