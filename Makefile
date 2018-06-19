LOGO_SIZE = 500

FONT_FAMILY = Zilla Slab
TEST_FONT_SIZE = 1000

all: html.html

html.html: logo-optimized.svg
	header() { \
		echo '<!DOCTYPE html>'; \
		echo '<html>'; \
		echo '<head>'; \
		echo '  <style>'; \
		echo '    body {'; \
		echo '      margin: 0;'; \
		echo '    }'; \
		echo '    svg {'; \
		echo '      background-color: goldenrod;'; \
		echo '    }'; \
		echo '  </style>'; \
		echo '</head>'; \
		echo '<body>'; \
	}; \
	{ header; echo; cat $<; } > $@

logo-optimized.svg: config-svgo.yml logo-transformed.svg
	./node_modules/.bin/svgo -o $@ --config $^

logo-transformed.svg: part-path part-height part-width part-max
	svg() { \
		echo "<svg width=\"$(LOGO_SIZE)\" height=\"$(LOGO_SIZE)\">"; \
		echo "  <g>"; \
		cat $<; \
		echo "  </g>"; \
		echo "</svg>"; \
	}; \
	svg > $@

part-max: part-height part-width
	expression() { \
		max "`cat "$$1"`" "`cat "$$2"`"; \
	}; \
	max() { \
		echo "define max(a, b) {"; \
		echo "  if (a < b)"; \
		echo "    return (b);"; \
		echo "  return (a);"; \
		echo "}"; \
		echo "max($$1, $$2)"; \
	}; \
	expression $^ | bc -l > $@

part-path: logo-path.svg
	xmllint --xpath '//*[local-name()="path"]' $< > $@

part-height: logo-path.svg
	xmllint --xpath 'string(/*[local-name()="svg"]/@height)' $< > $@

part-width: logo-path.svg
	xmllint --xpath 'string(/*[local-name()="svg"]/@width)' $< > $@

logo-path.svg: logo-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb EditSelectAll \
		--verb FitCanvasToDrawing \
		--verb ObjectToPath \
		--verb SelectionUnGroup \
		--verb SelectionUnion \
		--verb FileSave \
		--verb FileQuit \
		$(CURDIR)/$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-text.svg: Makefile
	svg() { \
		echo "<svg>"; \
		echo "  <text"; \
		echo "    font-family=\"$$1\""; \
		echo "    font-weight=\"$$2\""; \
		echo "    font-size=\"$$3\""; \
		echo "    >$$4</text>"; \
		echo "</svg>"; \
	}; \
	svg '$(FONT_FAMILY)' 'bold' '$(TEST_FONT_SIZE)' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-optimized.svg
	rm -f logo-transformed.svg
	rm -f part-height
	rm -f part-max
	rm -f part-path
	rm -f part-width
	rm -f logo-path.svg
	rm -f logo-path.svg.tmp.svg
	rm -f logo-text.svg
