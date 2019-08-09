#!/bin/bash

ZOOM=$1
PNG=$2

pdftoppm -png -singlefile -scale-to-x $((256 * 2**ZOOM)) -scale-to-y -1 pdf/latest ${PNG%%.png}

width=$(identify -format "%W" ${PNG})
height=$(identify -format "%H" ${PNG})
if [ $width -gt $height ]; then
	height=$(( width ))
elif [ $height -gt $width ]; then
	width=$(( ( (height / 256) + ((height % 256)?1:0) ) * 256 ))
fi

convert ${PNG} \
	-background none \
	-gravity north-west\
	-extent ${width}x${height} \
	${PNG%%.png}-fixed.png

mv ${PNG%%.png}-fixed.png ${PNG}
