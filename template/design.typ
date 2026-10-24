// The design of Previously on Earth.
//
// Page geometry, typefaces, chapter openings, running heads, contents,
// bookshelf and colophon all live here. `book.typ` applies the design with
// `#show: book.with(..)`, and every chapter opens with `#show: chapter.with(..)`.

#import "initials.typ": dropped, initials-font

// ---------------------------------------------------------------- colours

// Typeset with `--input print=true` (`make print`) for white paper.
#let for-print = sys.inputs.at("print", default: "false") == "true"

#let paper = if for-print { white } else { rgb("#fbf8f1") }
#let ink = rgb("#1d1a16")
#let rubric = rgb("#8f2f1f") // the red of rubricated manuscripts
#let faded = rgb("#7a6f63") // running heads, dates, attributions

// ---------------------------------------------------------------- type

#let serif = "EB Garamond"
#let display = "Cormorant Garamond"
#let body-size = 11.5pt

// How far down the page chapter openings begin.
#let sink = 1.15in

// ---------------------------------------------------------------- markers

// Every opening (chapter, bookshelf, colophon) leaves a `start` mark and
// every ending an `end` mark. Running heads, folios and the contents page
// are all worked out from these.
#let mark(kind, ..fields) = [#metadata((kind: kind, ..fields.named())) <poe-mark>]

#let chapter-counter = counter("poe-chapter")

// What sort of page `p` is: "front", "blank", "opening" or "text".
#let page-kind(p) = {
  let main = query(<poe-main>)
  if main.len() == 0 or p < main.first().location().page() { return "front" }
  let marks = query(<poe-mark>)
  let here-marks = marks.filter(m => m.location().page() == p)
  if here-marks.any(m => m.value.kind == "start") {
    return if here-marks.any(m => m.value.at("folio", default: true) == false) { "front" } else { "opening" }
  }
  let before = marks.filter(m => m.location().page() < p)
  if before.len() > 0 and before.last().value.kind == "end" { return "blank" }
  "text"
}

// ---------------------------------------------------------------- pieces

// The rosette from the Zallman initials, the book's one ornament.
#let fleuron(size: 46pt) = text(
  font: initials-font, fill: rubric, size: size,
  top-edge: "bounds", bottom-edge: "bounds", "❦",
)

// A break between movements within a chapter: `#ornament` on a line of its own.
#let ornament = block(width: 100%, above: 1.5em, below: 1.5em, align(center, fleuron()))

#let small-caps(body, tracking: 0.12em) = text(tracking: tracking, smallcaps(all: true, body))

#let roman(n) = numbering("I", n)

// An epigraph: a quotation in italic, set in a narrow column with its source
// beneath. Use _underscores_ inside it for titles, which then turn upright.
#let epigraph-block(body, source, width: 74%, size: 10pt) = align(center, block(width: width, {
  set text(size: size, style: "italic", hyphenate: false)
  set par(justify: false, first-line-indent: 0pt, leading: 0.62em, spacing: 0.9em)
  align(left, body)
  if source != none {
    v(0.2em)
    align(right, text(size: size - 0.5pt, style: "normal", [— #small-caps(source, tracking: 0.06em)]))
  }
}))

// The opening of a chapter or of back matter: title, and below it an
// optional dateline, epigraph and so on.
#let opening(title, numeral: none, era: none, epigraph: none, source: none) = {
  v(sink)
  if numeral != none {
    align(center, text(font: display, weight: "light", size: 30pt, fill: rubric, numeral))
    v(0.15em)
  }
  heading(level: 1, title)
  if era != none {
    v(0.35em)
    align(center, text(size: 9pt, fill: faded, small-caps(era, tracking: 0.16em)))
  }
  if epigraph != none {
    v(2.1em)
    epigraph-block(epigraph, source)
  }
  v(2.6em)
}

// ---------------------------------------------------------------- chapters

// Begins a chapter. Use at the top of a chapter file:
//
//   #show: chapter.with(
//     title: [The Title],
//     era: [431 – 404 BC],          // optional
//     epigraph: [A quotation …],    // optional
//     source: [Its Author],         // optional
//   )
//
// The first paragraph is opened with a decorated initial automatically.
// Inside a chapter, `= Heading` starts a section and `== Heading` a smaller one.
#let chapter(title: none, era: none, epigraph: none, source: none, initial: true, body) = {
  pagebreak(weak: true, to: "odd")
  chapter-counter.step()
  counter(footnote).update(0)
  mark("start", title: title, era: era, numbered: true)
  context opening(title, numeral: roman(chapter-counter.get().first()),
    era: era, epigraph: epigraph, source: source)

  // Find the first paragraph, past any quotation or figure that opens the
  // chapter, to give it the decorated initial.
  let block-elements = (heading, block, figure, quote, list.item, enum.item,
    terms.item, table, grid, image, pagebreak, v, place, align, pad, line, stack)
  let children = if body.func() == [].func() { body.children } else { (body,) }
  let start = children.position(c => c.func() not in ([ ].func(), parbreak, ..block-elements))
  let (before, first, after) = (body, none, none)
  if initial and start != none {
    let stop = start
    while stop < children.len() and children.at(stop).func() != parbreak and children.at(stop).func() not in block-elements {
      stop += 1
    }
    before = children.slice(0, start).join()
    first = children.slice(start, stop).join()
    after = children.slice(stop).join()
  }

  {
    set heading(offset: 1)
    before
    if first != none {
      dropped(first, lines: 4, fill: rubric)
      after
    }
  }
  mark("end")
}

// ---------------------------------------------------------------- front matter

#let half-title(title) = {
  v(2.1in)
  align(center, text(size: 10.5pt, small-caps(title, tracking: 0.32em)))
}

// The title in large type. A title too long for one line is broken into two
// lines of as nearly equal length as possible.
#let display-title(title, size: 48pt) = layout(bounds => {
  let set-in(s) = text(font: display, weight: "light", size: size, s)
  let words = title.split(" ")
  if measure(set-in(title)).width <= bounds.width or words.len() < 2 {
    return set-in(title)
  }
  let widest(k) = calc.max(
    measure(set-in(words.slice(0, k).join(" "))).width,
    measure(set-in(words.slice(k).join(" "))).width,
  )
  let k = range(1, words.len()).sorted(key: widest).first()
  set par(leading: 0.3em)
  set-in(words.slice(0, k).join(" ")) + linebreak() + set-in(words.slice(k).join(" "))
})

#let title-page(title, subtitle, author, year) = {
  v(1.2in)
  align(center, {
    block(width: 88%, display-title(title))
    if subtitle != none {
      v(1.1em)
      text(size: 12pt, style: "italic", fill: faded, subtitle)
    }
    v(2.4em)
    fleuron(size: 54pt)
    v(2.4em)
    if author != none { text(size: 10.5pt, small-caps(author, tracking: 0.22em)) }
  })
  v(1fr)
  if year != none {
    align(center, text(size: 9pt, fill: faded, small-caps(numbering("I", year), tracking: 0.3em)))
  }
  v(0.2in)
}

#let imprint-page(body) = {
  v(1fr)
  set text(size: 8.5pt, fill: faded)
  set par(justify: false, first-line-indent: 0pt, spacing: 1em)
  body
}

#let epigraph-page(body, source) = {
  v(2.2in)
  epigraph-block(body, source, width: 88%, size: 11pt)
}

#let contents-page() = {
  v(sink)
  heading(level: 1, outlined: false, bookmarked: false, [Contents])
  v(2.6em)
  context {
    let entries = query(<poe-mark>).filter(m => m.value.kind == "start" and m.value.at("toc", default: true))
    set par(justify: false, first-line-indent: 0pt)
    grid(
      columns: (2.4em, 1fr, auto),
      row-gutter: 1.35em,
      ..entries.map(m => {
        let loc = m.location()
        let number = if m.value.numbered { roman(chapter-counter.at(loc).first()) }
        let page-number = counter(page).at(loc).first()
        (
          link(loc, text(font: display, weight: "regular", size: 11.5pt, fill: rubric, number)),
          link(loc, {
            m.value.title
            if m.value.era != none {
              linebreak()
              text(size: 8.5pt, fill: faded, small-caps(m.value.era, tracking: 0.1em))
            }
          }),
          link(loc, str(page-number)),
        )
      }).flatten(),
    )
  }
}

// ---------------------------------------------------------------- back matter

#let bookshelf-section(bib) = {
  pagebreak(weak: true, to: "odd")
  mark("start", title: [Bookshelf], era: none, numbered: false)
  opening([Bookshelf])
  set text(size: 10pt, hyphenate: false)
  set par(justify: false, first-line-indent: 0pt, hanging-indent: 1.6em, leading: 0.6em, spacing: 1.1em)
  bib
  mark("end")
}

#let colophon-section(body) = {
  pagebreak(weak: true, to: "odd")
  mark("start", title: [Colophon], era: none, numbered: false, toc: false, folio: false)
  v(2.4in)
  align(center, block(width: 72%, {
    fleuron()
    v(1.4em)
    set text(size: 9.5pt, style: "italic", hyphenate: false)
    set par(justify: false, first-line-indent: 0pt, leading: 0.65em, spacing: 0.9em)
    body
  }))
  mark("end")
}

#let default-colophon = [
  This book is set in EB Garamond, Georg Duffner's revival of the roman of
  Claude Garamont and the italic of Robert Granjon, after a specimen printed
  at Frankfurt in 1592, with heavier weights by Octavio Pardo. The titles are
  set in Cormorant Garamond by Christian Thalmann, and the initials and the
  ornament are from Zallman Caps.

  Composed with Typst.
]

// ---------------------------------------------------------------- the book

#let book(
  title: "Previously on Earth",
  subtitle: none,
  author: none,
  year: none,
  imprint: auto,
  epigraph: none,
  epigraph-source: none,
  bibliography: none,
  colophon: auto,
  body,
) = {
  set document(title: title, author: if author != none { author } else { () })

  set page(
    width: 6in,
    height: 9in,
    margin: (inside: 0.8in, outside: 1.1in, top: 0.9in, bottom: 1.3in),
    binding: left,
    fill: paper,
    header-ascent: 38%,
    footer-descent: 34%,
    header: context {
      let p = here().page()
      if page-kind(p) != "text" { return }
      set text(size: 8.5pt, fill: faded)
      let current = query(<poe-mark>)
        .filter(m => m.value.kind == "start" and m.location().page() <= p)
      align(center, if calc.even(p) {
        small-caps(title, tracking: 0.2em)
      } else if current.len() > 0 {
        text(size: 9.5pt, style: "italic", current.last().value.title)
      })
    },
    footer: context {
      let p = here().page()
      if page-kind(p) not in ("text", "opening") { return }
      align(center, text(size: 9.5pt, counter(page).display("1")))
    },
  )

  set text(
    font: serif,
    size: body-size,
    fill: ink,
    lang: "en",
    region: "gb",
    number-type: "old-style",
    hyphenate: true,
  )
  set par(
    justify: true,
    leading: 0.7em,
    spacing: 0.7em,
    first-line-indent: 1em,
    // A hair of letterspacing either way keeps word spaces even.
    justification-limits: (tracking: (min: -0.01em, max: 0.01em)),
  )

  // Chapter titles. (The numeral and dateline are drawn by `opening`.)
  show heading.where(level: 1): it => block(width: 100%, align(center, {
    set par(justify: false, leading: 0.25em)
    set text(font: display, weight: "light", style: "italic", size: 25pt, hyphenate: false)
    it.body
  }))

  // Sections: `=` inside a chapter.
  show heading.where(level: 2): it => block(sticky: true, above: 2.4em, below: 1.4em, width: 100%, align(center, {
    set par(justify: false)
    text(size: 10pt, weight: "regular", small-caps(it.body, tracking: 0.16em))
  }))

  // Subsections: `==` inside a chapter.
  show heading.where(level: 3): it => block(sticky: true, above: 1.8em, below: 1em, width: 100%, align(center, {
    set par(justify: false)
    text(weight: "regular", style: "italic", it.body)
  }))

  show quote.where(block: true): it => pad(left: 1.6em, right: 1.6em, block(above: 1.3em, below: 1.3em, {
    set text(size: 10.5pt)
    set par(first-line-indent: 0pt)
    it.body
    if it.attribution != none {
      align(right, text(size: 9.5pt, [— #small-caps(it.attribution, tracking: 0.06em)]))
    }
  }))

  set footnote.entry(
    separator: line(length: 22%, stroke: 0.4pt + faded),
    clearance: 1.2em,
    gap: 0.55em,
    indent: 0pt,
  )
  show footnote.entry: set text(size: 9pt)
  show footnote.entry: set par(leading: 0.55em, first-line-indent: 0pt, hanging-indent: 0pt)

  show link: it => if type(it.dest) == str {
    underline(stroke: 0.4pt + faded, offset: 2.2pt, evade: true, it)
  } else { it }

  set list(indent: 1em, body-indent: 0.6em, marker: text(fill: rubric, [–]))
  set enum(indent: 1em, body-indent: 0.6em)

  set std.bibliography(title: none, full: true, style: "chicago-notes")

  // ------------------------------------------------ front matter
  half-title(title)
  pagebreak(to: "odd")
  title-page(title, subtitle, author, year)
  pagebreak()
  imprint-page(if imprint == auto {
    [Copyright ©#if year != none [ #year]#if author != none [ #author]]
  } else { imprint })
  if epigraph != none {
    pagebreak()
    epigraph-page(epigraph, epigraph-source)
  }
  pagebreak(to: "odd")
  contents-page()
  pagebreak(to: "odd")

  // ------------------------------------------------ main matter
  counter(page).update(1)
  [#metadata(none) <poe-main>]
  body

  // ------------------------------------------------ back matter
  if bibliography != none { bookshelf-section(bibliography) }
  if colophon != none {
    colophon-section(if colophon == auto { default-colophon } else { colophon })
  }
}
