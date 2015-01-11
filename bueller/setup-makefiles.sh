#!/bin/bash

export VENDOR=amazon
export DEVICE=bueller

OUTDIR=vendor/$VENDOR/$DEVICE
MAKEFILE=../../../$OUTDIR/$DEVICE-vendor.mk
FILELIST=../../../device/$VENDOR/$DEVICE/proprietary-files.txt

(cat << EOF) > $MAKEFILE
PRODUCT_COPY_FILES += \\
EOF

LINEEND=" \\"
COUNT=`wc -l $FILELIST | awk {'print $1'}`
DISM=`egrep -c '(^#|^$)' $FILELIST`
COUNT=`expr $COUNT - $DISM`
for FILE in `egrep -v '(^#|^$)' $FILELIST`; do
  COUNT=`expr $COUNT - 1`
  if [ $COUNT = "0" ]; then
    LINEEND=""
  fi
  # Split the file from the destination (format is "file[:destination]")
  OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
  if [[ ! "$FILE" =~ ^-.* ]]; then
    FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
    DEST=${PARSING_ARRAY[1]}
    if [ -n "$DEST" ]; then
        FILE=$DEST
    fi
    echo "    $OUTDIR/proprietary/$FILE:system/$FILE$LINEEND" >> $MAKEFILE
  fi
done
