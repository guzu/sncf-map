#!/bin/bash

DIR=$1
ZOOM_MAX=$2

for i in $(seq 1 $ZOOM_MAX); do

	echo "### Generating tiles for zoom level $i"
	mkdir -p ${DIR}/$i

	convert png/zoom-$i.png \
		-crop 256x256 \
		-set filename:tile '%[fx:page.x/256]_%[fx:page.y/256]' \
		+repage +adjoin \
		"${DIR}/$i/%[filename:tile].png"

	for png in $DIR/$i/*.png; do
		mkdir -p ${png%%_*.png}
		mv ${png} ${png/_/\/}
	done
done
