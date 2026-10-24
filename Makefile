# Typeset Previously on Earth.
#
#   make          previously-on-earth.pdf
#   make watch    re-typeset whenever a file is saved
#   make print    previously-on-earth-print.pdf, on white paper for printing

TYPST := typst
FONTS := --font-path fonts
SOURCES := book.typ books.yml $(wildcard chapters/*.typ template/*.typ fonts/*/*.otf fonts/*/*.ttf)

previously-on-earth.pdf: $(SOURCES)
	$(TYPST) compile $(FONTS) book.typ $@

previously-on-earth-print.pdf: $(SOURCES)
	$(TYPST) compile $(FONTS) --input print=true book.typ $@

.PHONY: watch print clean
watch:
	typst watch $(FONTS) book.typ previously-on-earth.pdf

print: previously-on-earth-print.pdf

clean:
	rm -f previously-on-earth.pdf previously-on-earth-print.pdf
