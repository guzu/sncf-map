SHELL=bash

ZOOM_MAX=7

all: map-201904

map-201904: PDF=pdf/MEP_POSTER_avril2019_POUR_LE_WEB.PDF
map-201707: PDF=pdf/SNCF-Reseau_Carte-RFN-Pliee_juil2017_01.pdf

map-%:
	sed "s/maxZoom: [0-9]*,/maxZoom: $(ZOOM_MAX),/; s/map-XXXXXX/map-$(*)/" index.html > index-$(*).html
	./pdf2tilemap.sh --zoom $(ZOOM_MAX) --outdir map-$(*) --pdf-file $(PDF)
