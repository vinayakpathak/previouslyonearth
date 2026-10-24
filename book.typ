// Previously on Earth
//
// This file is the book. Each chapter is a file in chapters/, listed at the
// bottom in reading order. Books you read go in books.yml. The design lives
// in template/.
//
//   make          typeset previously-on-earth.pdf
//   make watch    re-typeset whenever a file changes

#import "template/design.typ": *

#show: book.with(
  title: "Previously on Earth",
  subtitle: [A history, written as I read],
  author: "Vinayak Pathak",
  year: 2026,
  epigraph: [
    #text(style: "normal", lang: "el")[Ἡροδότου Ἁλικαρνησσέος ἱστορίης ἀπόδεξις ἥδε, ὡς μήτε τὰ γενόμενα ἐξ ἀνθρώπων τῷ χρόνῳ ἐξίτηλα γένηται …]

    This is the display of the inquiry of Herodotus of Halicarnassus, so that things done by man not be forgotten in time …
  ],
  epigraph-source: [Herodotus, _Histories_ I, trans. A. D. Godley],
  bibliography: bibliography("books.yml"),
)

// The two chapters below are samples showing the design.
// Replace them with your own.
#include "chapters/01-a-possession-for-all-time.typ"
#include "chapters/02-the-age-of-the-antonines.typ"
