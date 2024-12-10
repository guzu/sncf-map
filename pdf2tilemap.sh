#!/bin/bash

set -e

ZOOM_MAX=6  # default to 6
#PDF_FILE=pdf/latest

STATIC=static
TILE_SIZE=256

genmap() {
	zoom=$1
	pdffile="$2"
	pngfile="$3"

	echo "### Generating map for zoom level $i"

	pdftoppm -png -singlefile \
		 -scale-to-x $((TILE_SIZE * 2**zoom)) \
		 -scale-to-y -1 \
		 "${pdffile}" "${pngfile%%.png}"

	width=$(identify -format "%W" "${pngfile}")
	height=$(identify -format "%H" "${pngfile}")
	if [ $width -gt $height ]; then
		height=$(( width ))
	elif [ $height -gt $width ]; then
		width=$(( ( (height / TILE_SIZE) + ((height % TILE_SIZE)?1:0) ) * TILE_SIZE ))
	fi

	# Every tile must be exact tile size or map will be stretched
	# so map must extended with transparent margin
	convert ${pngfile} \
		-background none \
		-gravity north-west\
		-extent ${width}x${height} \
		"${pngfile%%.png}-fixed.png"

	mv "${pngfile%%.png}-fixed.png" "${pngfile}"
}

gentile() {
	zoom=$1
	pngfile=$2

	echo "### Generating tiles for zoom level $i"
	mkdir -p ${TILE_DIR}/$i

	convert ${pngfile} \
		-crop ${TILE_SIZE}x${TILE_SIZE} \
		-set filename:tile "%[fx:page.x/${TILE_SIZE}]_%[fx:page.y/${TILE_SIZE}]" \
		+repage +adjoin \
		"${TILE_DIR}/${zoom}/%[filename:tile].png"

	for png in ${TILE_DIR}/${i}/*.png; do
		mkdir -p ${png%%_*.png}
		mv ${png} ${png/_/\/}
	done
}


while [ $# -gt 0 ]; do
	case "$1" in
	--pdf)
	    PDF_FILE=$2
	    shift 2
        ;;
	--year)
		YEAR=$2
		shift 2
		;;
    --outdir)
	    TILE_DIR=$2
	    shift 2
        ;;
    --zoom)
	    ZOOM_MAX=$2
	    shift 2
        ;;
    --*)
        echo "ERROR: unknown option ${opt}"
        exit 1
	    ;;
	--help)
		echo "USAGE: $0 --pdf PDF --year YEAR [--zoom ZOOM-LEVEL]"
		;;
	*)
		break
		;;
    esac
done


if [ -z "$PDF_FILE" ]; then
	echo "ERROR: a PDF file must be provided"
	exit 1
fi
if [ -z "$YEAR" ]; then
	echo "ERROR: a YEAR must be provided"
	exit 1
fi

TILE_DIR=${STATIC}/map-${YEAR}

mkdir -p ${STATIC}
mkdir -p maps
echo "### Generating website..."

for i in $(seq 1 $ZOOM_MAX); do
	if [ ! -e maps/full-zoom-$i.png ]; then
		genmap $i "${PDF_FILE}" maps/full-zoom-$i.png
	fi
	gentile $i maps/full-zoom-$i.png
done

# Copy other 
sed "s,map-XXXXXX,$(basename ${TILE_DIR}), ; s/YEAR/${YEAR}/ ; s/MAX_ZOOM/${ZOOM_MAX}/" index.html > ${STATIC}/index.html
cp -a styles.css leaflet* img ${STATIC}/

echo "You can now copy 'static' directory"