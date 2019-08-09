#!/bin/sh

DIR=$1
ZOOM_MAX=$2

for i in $(seq 1 $ZOOM_MAX); do
	mkdir -p ${DIR}/$i

	convert png/zoom-$i.png \
		-crop 256x256 \
		-set tile '%[fx:page.x/256]_%[fx:page.y/256]' \
		+repage +adjoin \
		"${DIR}/$i/tile.png" ; \

	# Fix convert, the filename should already be good with the use
	# of %[tile].png and FX but it doesn't work, so do it manually
	for y in $(seq 0 $(( (2**i)-1 ))); do
		for x in $(seq 0 $(((2**i)-1 ))); do
			mkdir -p ${DIR}/$i/${x}
			mv ${DIR}/$i/tile-$((x + y*(2**i) )).png ${DIR}/$i/$x/$y.png || true
		done
	done
done
