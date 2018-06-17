all: html.html

html.html: logo-scaled-optimized.svg
	{ echo '<!DOCTYPE html><html><head><style>svg{background-color:goldenrod}</style></head><body style="margin: 0">'; cat $<; } > $@

logo-scaled-optimized.svg: logo-scaled-inkscaped.svg config-svgo.yml
	./node_modules/.bin/svgo --config config-svgo.yml -i $< -o $@

logo-scaled-inkscaped.svg: logo-scaled-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb EditSelectAll \
		--verb ObjectToPath \
		--verb SelectionUnGroup \
		--verb SelectionUnion \
		--verb AlignHorizontalCenter \
		--verb AlignVerticalCenter \
		--verb FileSave \
		--verb FileQuit \
		$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-scaled-text.svg: logo-test-inkscaped.svg
	svg() { echo "<svg width=\"500\" height=\"500\"><text x=\"50%\" y=\"50%\" text-anchor=\"middle\" dominant-baseline=\"middle\" font-family=\"$$1\" font-weight=\"$$2\" font-size=\"$$3\">$$4</text></svg>"; }; \
	svg 'Zilla Slab' 'bold' '495.16442231741703223005' 'ov' > $@

logo-test-inkscaped.svg: logo-test-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb FitCanvasToDrawing \
		--verb FileSave \
		--verb FileQuit \
		$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-test-text.svg: Makefile
	svg() { echo "<svg><text font-family=\"$$1\" font-weight=\"$$2\" font-size=\"$$3\">$$4</text></svg>"; }; \
	svg 'Zilla Slab' 'bold' '1000' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-scaled-optimized.svg
	rm -f logo-scaled-inkscaped.svg
	rm -f logo-scaled-inkscaped.svg.tmp.svg
	rm -f logo-scaled-text.svg
	rm -f logo-test-inkscaped.svg
	rm -f logo-test-inkscaped.svg.tmp.svg
	rm -f logo-test-text.svg
