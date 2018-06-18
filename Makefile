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
		echo "<svg width=\"500\" height=\"500\">"; \
		echo "  <text"; \
		echo "    x=\"50%\""; \
		echo "    y=\"50%\""; \
		echo "    text-anchor=\"middle\""; \
		echo "    dominant-baseline=\"middle\""; \
		echo "    font-family=\"$$1\""; \
		echo "    font-weight=\"$$2\""; \
		echo "    font-size=\"$$3\""; \
		echo "    >$$4</text>"; \
		echo "</svg>"; \
	}; \
	font_size() { \
		echo "(500 * $(TEST_FONT_SIZE)) / `width`" | bc -l; \
	}; \
	width() { \
		inkscape --query-width $(CURDIR)/$<; \
	}; \
	svg 'Zilla Slab' 'bold' "`font_size`" 'ov' > $@

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
