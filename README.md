# Previously on Earth

A minimalist history blog built with Eleventy. The image-free homepage uses typography to present searchable articles, with an independent bookshelf and light and dark appearances. The typography pairs Cormorant Garamond with Inter; both fonts are served locally.

## Start locally

Install [Node.js](https://nodejs.org/) 18 or newer, then run these commands from this folder:

```sh
npm install
npm run dev
```

Open **http://localhost:4321**. Saving content or templates rebuilds the site and refreshes the preview.

## Make it yours

- Edit the sample essay in [`src/posts/rome-wasnt-built-in-a-story.md`](src/posts/rome-wasnt-built-in-a-story.md). It is a starting draft with a sample notice.
- Update the reading list in [`src/_data/books.json`](src/_data/books.json).
- Change the site title and description in [`src/_data/site.js`](src/_data/site.js), and the personal introduction in [`src/about.njk`](src/about.njk).
- Page layouts live in `src/_includes/`; the homepage is `src/index.njk`.

The sample essay’s date is a placeholder. Replace it with your own date and remove the sample notice when you have edited the essay into your own entry.

## Add an essay

Create a Markdown file inside `src/posts/`. Begin with this front matter, changing the title, date, description, and permalink:

```markdown
---
title: A question from the margins
date: 2026-09-24
description: A short introduction to this entry and the question it explores.
layout: post.njk
tags:
  - posts
permalink: /journal/a-question-from-the-margins/
---

Begin your essay here. Its opening paragraph receives a drop cap.

## A thought worth following

Continue in Markdown, with headings, links, and reading notes as needed.
```

Give every essay a unique `permalink`, beginning with `/journal/` and ending with `/`. Article headers and listings show only the title and date. The title is rendered automatically, so begin the body with a paragraph and use `##` for section headings.

The homepage lists articles by date, newest first. It initially shows five articles, with a **More articles** button to reveal the rest on the same page. Without JavaScript, all articles are visible. There is no separate journal listing page; the `/journal/` prefix is kept for individual article URLs.

The optional `description` provides a short summary for page metadata and search. Optional `category` and `era` fields can add search keywords.

Essays are text-only by default; no image fields are needed. To include an image, save it in `src/assets/images/` and insert it directly into the Markdown body wherever you want it to appear:

```markdown
A paragraph introducing the image.

![A description of what the image shows](/assets/images/your-image.jpg)

Continue your essay here.
```

Images scale to the essay’s width. Use an image you have permission to publish and give it descriptive alternative text.

## Maintain the bookshelf

`src/_data/books.json` is a JSON array. All books appear in one list, in the order they are written here. Add a comma between book objects and keep each `id` unique; lowercase words separated by hyphens work well.

```json
{
  "id": "your-book-id",
  "title": "Book title",
  "subtitle": "An optional subtitle",
  "author": "Author name",
  "year": 2026,
  "cover": "/assets/images/books/your-book.jpg",
  "coverWidth": 600,
  "coverHeight": 900,
  "url": "https://example.com/book"
}
```

Save a cover image in `src/assets/images/books/`, set `cover` to its public path, and record the image’s actual pixel dimensions in `coverWidth` and `coverHeight`. The cover appears on the bookshelf. If no cover is supplied, a typographic cover is used as a fallback. The book title links to `url`. Bookshelf entries are maintained independently of articles.

Existing `status`, `finished`, and `note` fields can remain as optional reading records, but the bookshelf displays a single list without status labels or filters. If you use `status`, its allowed values are **Read**, **Reading**, and **To read**.

Search runs in the visitor’s browser using an index generated from your content. It needs no account, API key, or external search service. Rebuild after adding or editing content.

## Build and publish

```sh
npm run build
```

Eleventy writes the finished site to **`_site/`**. Edit files in `src/`; generated files in `_site/` are replaced on the next build.

Run `npm run check` after a build to check post front matter, bookshelf data, local links, search destinations, and assets.

On a static hosting service, use **`npm run build`** as the build command and **`_site`** as the publish directory. Deploy at the root of your domain, since links and assets use paths beginning with `/`.

Optionally set the host’s `SITE_URL` environment variable to your production origin, for example `https://your-domain.com`. This enables absolute canonical URLs and social sharing metadata. For a local production build:

```sh
SITE_URL=https://your-domain.com npm run build
```

Font licenses, artwork credits, and original asset sources are documented in [`ASSETS.md`](ASSETS.md).
