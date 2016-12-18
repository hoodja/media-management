#!/bin/bash
cat $1  | sed -e 's~^MD5 (.*/\([^)]*\)) = \(.*\)$~\2 \1~' | sort
