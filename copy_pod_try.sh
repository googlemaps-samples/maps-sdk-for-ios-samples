#!/bin/sh
POD_NAME="$1"
DESTINATION_DIR="$2"
POD_TRY_OPTION="$3"

echo "Invoking 'pod try $POD_NAME'"
POD_TRY_DIR="$(pod _1.6.1_ try $POD_NAME <<< $POD_TRY_OPTION | tail -1 | awk '{print $2}' | echo "/$(cut -d\/ -f2-11)")"

echo "Copying contents of '$POD_TRY_DIR' into '$DESTINATION_DIR'"
cp -R $POD_TRY_DIR/* $DESTINATION_DIR/.

