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
  title: "Previously, on Earth",
  subtitle: [],
  author: "Vinayak Pathak",
  year: 2026,
  // On the front cover, below the title. Two lines are joined by "or,".
  tagline: ([A History of the World], [The Bits I Have Read About So Far]),
  bibliography: bibliography("books.yml"),
)

// The book is in three parts. Each `#part` opens with a title page and is
// followed by its chapters. The two chapters below are samples showing the
// design. Replace them with your own.

#part[Argentina]
#include "chapters/01-a-possession-for-all-time.typ"

#part[Germany]
#include "chapters/02-the-age-of-the-antonines.typ"

#part[India]
