SOURCES = \
GraphicsEvents.ml \
DisplayElt.ml \
Ras2Vec.ml \
Event51.ml \
Polyline.ml \
Contour.ml

all: $(SOURCES)
	corebuild -quiet -lib graphics Ras2Vec.native

check: $(SOURCES)
	@chmod u+x check_width 
	@check_width GraphicsEvents.ml	
	@check_width DisplayElt.ml
	@check_width Ras2Vec.ml
	@check_width Contour.ml
clean:
	rm -rf _build Ras2Vec.native
