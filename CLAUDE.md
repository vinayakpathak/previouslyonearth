# Previously, on Earth

This repo has two purposes.

1. **The book.** The user is writing *Previously, on Earth*, a history written while reading, typeset with Typst. README.md explains how it is built and laid out. The look matters most: check any design change by rendering the pages and looking at them. The writing is deliberately casual and silly, set in very serious typography, and the design keeps that contrast.
2. **Finding the next book.** `books.yml` records every book the user has read for the project, with its topics and their notes on it. `reading-patterns.md` sums up what that record shows about how they read. Use both, together with the chapters, to recommend what to read next, at the margin of what they know.

## Logging a book

When the user tells you about a book they have read, add it to `books.yml`, or update its entry. The fields are described at the top of that file.

- Check the title, author and year of first publication, and look them up if unsure. For a translation, give the translator and the year of the translation they read.
- Add new books at the end, since the file is in the order they were read.
- Give it `topics`: places (countries, then regions), periods (centuries or named eras) and themes. Reuse topics already in the file before making new ones. Give its `form` too, such as travel memoir or narrative history.
- Fill in `read:` from what they said. Keep their words, fixing only typos, and don't add opinions they didn't give. If `status`, `difficulty` or `engagement` isn't clear, make your best guess and tell them which fields you guessed.
- If the book was recommended in `recommendations.md`, note there how it went.
- Update `reading-patterns.md`: add, revise or remove the patterns the new book supports or contradicts, naming the books each one rests on. Keep it short. Do the same when they correct an entry.
- Run `make` to check that the book still builds.
- Commit and push to `main` without asking, so the record is the same on every computer.

## Recommending books

Use the `recommend-books` skill.

## Git

Commit straight to `main` and push `main`, unless told otherwise. Do this when asked, and after logging a book.
