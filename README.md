# Previously on Earth

A book of history, written while reading it. It is typeset with [Typst](https://typst.app).

## Typeset the book

```sh
make          # previously-on-earth.pdf
make watch    # re-typeset whenever a file is saved
make print    # previously-on-earth-print.pdf, on white paper for printing
```

Typst 0.15.1 is installed at `~/.local/bin/typst`. The first run downloads one small Typst package, [droplet](https://typst.app/universe/package/droplet), which flows the text around the decorated initials. After that the book builds offline.

In VS Code, the Tinymist extension shows a live preview. Open `book.typ` and run **Typst Preview: Preview Opened File**. `.vscode/settings.json` points Tinymist to the book's fonts. If it reports an unknown font, reload the window once.

## Write a chapter

Each chapter is a file in `chapters/`, and starts like this:

```typst
#import "../template/design.typ": *

#show: chapter.with(
  title: [The Fall of Constantinople],
  era: [AD 1453],                        // optional
  epigraph: [A quotation, if you like.], // optional
  source: [Its author, _Its Book_],      // optional
)

The first paragraph starts here and gets the decorated initial.

= A section

More paragraphs.
```

Then add the chapter to the list at the bottom of `book.typ`, in reading order:

```typst
#include "chapters/03-the-fall-of-constantinople.typ"
```

The chapters are grouped into parts: Argentina, Germany, and India. Each part starts with a `#part[…]` line in `book.typ`, which gives it a title page on a right-hand page. Put each chapter's `#include` under the part it belongs to. Chapters are numbered straight through the book.

Each chapter opens on a right-hand page with its number, title, and dates. The first paragraph gets the decorated initial, and its first few words are set in small capitals. To begin a chapter without the initial, add `initial: false`.

Inside a chapter:

| Write | For |
| --- | --- |
| a blank line | a new paragraph |
| `_words_` | italics |
| `= Heading` | a section, in spaced small capitals |
| `== Heading` | a subsection, in italics |
| `#ornament` | a rosette marking a break in the narrative |
| `#footnote[…]` | a footnote (numbering restarts each chapter) |
| `#quote(block: true, attribution: [Livy])[…]` | an indented quotation |
| `@bridges` or `@bridges[p. 12]` | a citation, which becomes a footnote |

Straight quotes (`"…"`) and dashes (`--` for –, `---` for —) are converted to their typographic forms.

## The bookshelf

`books.yml` lists the books you have read for the book. All of them appear at the back under **Bookshelf**, cited or not. Each entry has a key, like `bridges:`, that you use to cite it. The format is [Hayagriva's](https://github.com/typst/hayagriva/blob/main/docs/file-format.md).

`books.yml` is also your reading record. Each entry has `topics` (places, periods and themes) and a `read:` section with your notes: how hard and how engaging you found the book, what you learned, what it left you curious about, and anything else. These never appear in the book. The fields are described at the top of `books.yml`. You don't have to write them yourself: tell Claude what you thought of a book and it will add the entry.

## What to read next

Ask Claude for a book, for example "a new book about Germany", or run `/recommend-books`. It reads `books.yml` and your chapters, and recommends a few books at the margin of what you know: ones that build on what you have read, are a little harder than comfortable, and are written in a way you have enjoyed. Each round of recommendations is recorded in `recommendations.md`.

The steps it follows are in `.claude/skills/recommend-books/SKILL.md`, and `CLAUDE.md` tells Claude how this repo works. Both are in git, so they work on any computer with this repo.

## The samples

`chapters/02-the-age-of-the-antonines.typ` is a sample chapter, from Gibbon's public-domain text, that shows the design. Delete it, and its `#include` line in `book.typ`, when you no longer need it. If `books.yml` is left with no entries, the Bookshelf page comes out empty. To leave it out, delete the `bibliography:` line in `book.typ`.

The title, subtitle, and author are at the top of `book.typ`. To add an epigraph page after the copyright page, pass `epigraph:` and `epigraph-source:` there too.

The front cover shows the title, the `tagline:` from `book.typ`, and the author. A tagline of two lines, like `([A History of the World], [The Bits I Have Read About So Far])`, is joined by "or,". `make print` leaves the cover out.

## The design

`template/design.typ` controls the look of the book: page size (6 × 9 in), margins, colours, type sizes, chapter openings, running heads, contents, bookshelf, and colophon. `template/initials.typ` makes the decorated initials.

- **Text:** EB Garamond 11.5 pt, with old-style figures and true small capitals
- **Titles and chapter numerals:** Cormorant Garamond Light
- **Initials and the ornament:** Zallman Caps, in rubric red
- **Paper:** warm off-white on screen; `make print` uses white
- **Cover:** gold lettering on oxblood cloth, inside a double rule

The fonts are in `fonts/`, so the book looks the same on any machine. Their sources and licences are in [fonts/README.md](fonts/README.md).
