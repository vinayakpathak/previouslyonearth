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
| `@gibbon` or `@gibbon[ch. 3]` | a citation, which becomes a footnote |

Straight quotes (`"…"`) and dashes (`--` for –, `---` for —) are converted to their typographic forms.

## The bookshelf

`books.yml` lists the books you have read for the book. All of them appear at the back under **Bookshelf**, cited or not. Each entry has a key, like `gibbon:`, that you use to cite it. The format is [Hayagriva's](https://github.com/typst/hayagriva/blob/main/docs/file-format.md).

## The samples

The two chapters in `chapters/` and the three entries in `books.yml` are samples that show the design. The chapters are Thucydides and Gibbon in public-domain texts. Delete them, and their `#include` lines in `book.typ`, when you start writing. If `books.yml` is left with no entries, the Bookshelf page comes out empty. To leave it out, delete the `bibliography:` line in `book.typ`.

The title, subtitle, author, and the epigraph from Herodotus (in Greek and English) are at the top of `book.typ`.

## The design

`template/design.typ` controls the look of the book: page size (6 × 9 in), margins, colours, type sizes, chapter openings, running heads, contents, bookshelf, and colophon. `template/initials.typ` makes the decorated initials.

- **Text:** EB Garamond 11.5 pt, with old-style figures and true small capitals
- **Titles and chapter numerals:** Cormorant Garamond Light
- **Initials and the ornament:** Zallman Caps, in rubric red
- **Paper:** warm off-white on screen; `make print` uses white

The fonts are in `fonts/`, so the book looks the same on any machine. Their sources and licences are in [fonts/README.md](fonts/README.md).
