all: html.html

html.html: logo-optimized.svg
	{ echo '<!DOCTYPE html><html><body>'; cat $<; } > $@

logo-optimized.svg: logo-inkscaped.svg
	./node_modules/.bin/svgo --config config-svgo.yml -i $< -o $@

logo-inkscaped.svg: logo-text.svg
	cp $< $@

logo-text.svg: script-text-svg.sh
	./script-text-svg.sh 'Zilla Slab' 'bold' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-optimized.svg
	rm -f logo-inkscaped.svg
	rm -f logo-text.svg
