LOGO_SIZE = 500

TEST_FONT_SIZE = 1000

all: html.html

html.html: logo-scaled-optimized.svg
	main() { \
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
		echo; \
		cat $<; \
	}; \
	main > $@

logo-scaled-optimized.svg: logo-scaled-inkscaped.svg config-svgo.yml
	./node_modules/.bin/svgo --config config-svgo.yml -i $< -o $@

logo-scaled-inkscaped.svg: logo-scaled-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb EditSelectAll \
		--verb ObjectToPath \
		--verb SelectionUnGroup \
		--verb SelectionUnion \
		--verb FileSave \
		--verb FileQuit \
		$(CURDIR)/$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-scaled-text.svg: logo-test-inkscaped.svg
	svg() { \
		echo "<svg width=\"$(LOGO_SIZE)\" height=\"$(LOGO_SIZE)\">"; \
		echo "  <text"; \
		echo "    font-family=\"$$1\""; \
		echo "    font-weight=\"$$2\""; \
		echo "    font-size=\"$$3\""; \
		echo "    x=\"$$4\""; \
		echo "    y=\"50%\""; \
		echo "    dominant-baseline=\"middle\""; \
		echo "    >$$5</text>"; \
		echo "</svg>"; \
	}; \
	font_size() { \
		expression "`query width`" "`query height`" | bc -l; \
	}; \
	expression() { \
		echo "define max(a, b) {"; \
		echo "  if (a < b)"; \
		echo "    return (b);"; \
		echo "  return (a);"; \
		echo "}"; \
		echo "( $(LOGO_SIZE) * $(TEST_FONT_SIZE) ) / max($$1, $$2)"; \
	}; \
	query() { \
		inkscape --query-$$1 $(CURDIR)/$<; \
	}; \
	offset() { \
		echo "`text_x` / 2" | bc -l; \
	}; \
	text_x() { \
		xmllint --xpath 'string(//*[local-name()="text"]/@x)' $<; \
	}; \
	svg 'Zilla Slab' 'bold' "`font_size`" "`offset`" 'ov' > $@

logo-test-inkscaped.svg: logo-test-text.svg
	cp $< $@.tmp.svg
	inkscape \
		--verb FitCanvasToDrawing \
		--verb FileSave \
		--verb FileQuit \
		$(CURDIR)/$@.tmp.svg \
		;
	mv $@.tmp.svg $@

logo-test-text.svg: Makefile
	svg() { \
		echo "<svg>"; \
		echo "  <text"; \
		echo "    font-family=\"$$1\""; \
		echo "    font-weight=\"$$2\""; \
		echo "    font-size=\"$$3\""; \
		echo "    >$$4</text>"; \
		echo "</svg>"; \
	}; \
	svg 'Zilla Slab' 'bold' '$(TEST_FONT_SIZE)' 'ov' > $@

clean:
	rm -f html.html
	rm -f logo-scaled-optimized.svg
	rm -f logo-scaled-inkscaped.svg
	rm -f logo-scaled-inkscaped.svg.tmp.svg
	rm -f logo-scaled-text.svg
	rm -f logo-test-inkscaped.svg
	rm -f logo-test-inkscaped.svg.tmp.svg
	rm -f logo-test-text.svg
