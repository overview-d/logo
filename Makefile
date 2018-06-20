LOGO_SIZE = 500
LOGO_TEXT = ov

FONT_FAMILY = Zilla Slab
FONT_WEIGHT = bold
FONT_SIZE = 10000

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

logo-transformed.svg: part-path part-max part-width part-height
	svg() { \
		echo "<svg width=\"$$1\" height=\"$$1\">"; \
		echo "  <g transform=\""; \
		echo "      translate("; \
		echo "        `offset "$$1" "$$2" "$$3"`,"; \
		echo "        `offset "$$1" "$$2" "$$4"`"; \
		echo "      )"; \
		echo "      scale(`scale "$$1" "$$2"`)"; \
		echo "    \">"; \
		cat $<; \
		echo "  </g>"; \
		echo "</svg>"; \
	}; \
	scale() { \
		echo "$$1 / $$2" | bc -l; \
	}; \
	offset() { \
		echo "$$1 / 2 - ( $$1 * $$3 ) / ( 2 * $$2 )" | bc -l; \
	}; \
	svg '$(LOGO_SIZE)' "`cat part-max`" "`cat part-width`" "`cat part-height`" > $@

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
	svg '$(FONT_FAMILY)' '$(FONT_WEIGHT)' '$(FONT_SIZE)' '$(LOGO_TEXT)' > $@

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
