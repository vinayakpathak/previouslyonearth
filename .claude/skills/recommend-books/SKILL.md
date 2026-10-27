---
name: recommend-books
description: Recommend history books for the user to read next, at the margin of what they already know. Use whenever they ask what to read next or for a book on a place, period or theme ("a new book about Germany", "something on the industrial revolution").
---

# Recommend books

The user reads history the Tyler Cowen way: the next book should sit at the
margin of what they already know. Look for books that

- assume what they already know, rather than teaching it again;
- teach them something they don't know;
- are a little harder than what they find comfortable, and no harder;
- are written in a way they enjoy, judged by what has engaged and bored them before.

## 1. Read everything they have written

- `books.yml`: every book they have read, in the order they read them. An entry's `topics` say what the book is about and its `form` what kind of book it is, such as travel memoir or narrative history. Its `read:` section holds their verdict: difficulty, engagement, what they learned, the questions it left them with, and their thoughts. Read every entry, not just the ones on the topic asked about, since their taste shows across all of them.
- `chapters/*.typ`: their own notes in *Previously, on Earth*. They show what they have absorbed, what they find interesting, and where their knowledge is thin. `book.typ` lists the parts, which are the places they are writing about.
- `recommendations.md`: what has been recommended before, and how the picks they read went.

## 2. Work out where the margin is

For the topic asked about, or, if none was given, for the threads their reading and questions leave open:

- **What do they already know?** List the books they have read on it, by `topics` and by judgement (a book on the Thirty Years' War is about Germany even if not tagged so), and what their chapters cover.
- **How hard should it be?** Calibrate against the books they rated, how engaging each was at that difficulty, and why they found them hard (a dense argument, many names, unfamiliar background). Aim a little past what they found moderate, and well short of too hard.
- **What keeps them reading?** Look for patterns in engagement and thoughts: form, length, editing, pace, narrative or argument.
- **What have they asked?** A book that answers one of their open questions is usually the best pick.

If the request is too vague to place, ask one question before searching.

## 3. Find and check candidates

- Search the web for candidates rather than relying on memory: reviews in serious publications, historians' reading lists, Five Books interviews, Tyler Cowen's Marginal Revolution.
- Check every book you recommend: exact title, author, year of first publication, page count, and that it can be bought in print or as an ebook. Drop any you cannot confirm.
- Read what reviewers and readers say about readability and pace, not just importance.
- Leave out books already in `books.yml` or in `recommendations.md`, unless they ask again.

## 4. Recommend

Recommend three books unless they ask for another number. Usually one sits squarely at the margin, one is a stretch, and one is a different form, such as a memoir, primary source or biography, where that suits the topic. For each, give:

- title, author, year and length;
- what it would add to what they already know, naming the books or chapters it builds on;
- why they would likely enjoy it, from their own notes;
- how hard it is, compared with a book they rated;
- any caveat, such as chapters to skip.

Then say which one to start with, and why. End with links to the sources you used.

## 5. Record it

Add the round to the end of `recommendations.md`:

```markdown
## 2026-11-02: a new book about Germany

- *Title*, by Author (year). One line on why.
```

Only books they have read go in `books.yml`. When they later log a book that was recommended here, add how it went to its line, e.g. "→ Read 2026-12: moderate, gripping."
