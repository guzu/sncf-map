SHELL=bash

all: genmaps | gentiles

genmaps:
	./genmaps.sh

gentiles:
	for i in $$(seq 1 6); do \
		mkdir -p map-201908/$$i ; \
	        convert png/zoom-$$i.png \
			-crop 256x256 \
			-set tile '%[fx:page.x/256]_%[fx:page.y/256]' \
			+repage +adjoin \
			"map-201908/$$i/tile.png" ; \
		for y in $$(seq 0 $$(( (2**i)-1 ))); do \
			for x in $$(seq 0 $$(((2**i)-1 ))); do \
				mkdir -p map-201908/$$i/$${x}; \
				mv map-201908/$$i/tile-$$((x + y*(2**i) )).png map-201908/$$i/$$x/$$y.png || true; \
			done; \
		done; \
	done
