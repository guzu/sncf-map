#!/bin/bash

set -x

for i in $(seq 1 6); do
	pdftoppm -png -singlefile -scale-to-x $((256 * 2**i)) -scale-to-y -1 pdf/latest png/zoom-$i

	width=$(identify -format "%W" png/zoom-${i}.png)
	height=$(identify -format "%H" png/zoom-${i}.png)
	if [ $width -gt $height ]; then
		height=$(( width ))
	elif [ $height -gt $width ]; then
		width=$(( ( (height / 256) + ((height % 256)?1:0) ) * 256 ))
	fi

	convert png/zoom-${i}.png \
		-background none \
		-gravity north-west\
		-extent ${width}x${height} \
		png/zoom-${i}-fixed.png

	mv png/zoom-${i}-fixed.png png/zoom-${i}.png
done
