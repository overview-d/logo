all: html.html

html.html: logo-scaled-optimized.svg
	{ echo '<!DOCTYPE html><html><body style="margin: 0">'; cat $<; } > $@

logo-scaled-optimized.svg: logo-scaled-inkscaped.svg config-svgo.yml
	./node_modules/.bin/svgo --config config-svgo.yml -i $< -o $@

logo-scaled-inkscaped.svg: logo-scaled-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb FitCanvasToDrawing \
		--verb EditSelectAll \
		--verb ObjectToPath \
		--verb SelectionUnGroup \
		--verb SelectionUnion \
		--verb FileSave \
		--verb FileQuit \
		$(CURDIR)/$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-scaled-text.svg: Makefile
	svg() { echo "<svg><text font-family=\"$$1\" font-weight=\"$$2\">$$3</text></svg>"; }; \
	svg 'Zilla Slab' 'bold' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-scaled-optimized.svg
	rm -f logo-scaled-inkscaped.svg
	rm -f logo-scaled-inkscaped.svg.tmp.svg
	rm -f logo-scaled-text.svg
