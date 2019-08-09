SHELL=bash

ZOOM_MAX=6
DIR=map-201908

all: genmaps | gentiles

png/zoom-%.png:
	./genmap.sh $(subst png/zoom-,,$(subst .png,,$(@))) $(@)

MAPS=$(foreach var,$(shell seq 1 $(ZOOM_MAX)),png/zoom-$(var).png)
genmaps: $(MAPS)

# TODO: do not hardcode PNG filenames in gentiles.sh
gentiles:
	./gentiles.sh map-201908 $(ZOOM_MAX)

# TODO: do not hardcode maximum zoom level and map-201908 directory name in index.html
