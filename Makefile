all: html.html

html.html: logo-optimized.svg
	{ echo '<!DOCTYPE html><html><body>'; cat $<; } > $@

logo-optimized.svg: logo-inkscaped.svg config-svgo.yml
	./node_modules/.bin/svgo --config config-svgo.yml -i $< -o $@

logo-inkscaped.svg: logo-text.svg
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

logo-text.svg: script-text-svg.sh
	./script-text-svg.sh 'Zilla Slab' 'bold' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-optimized.svg
	rm -f logo-inkscaped.svg
	rm -f logo-inkscaped.svg.tmp.svg
	rm -f logo-text.svg
