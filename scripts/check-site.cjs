#!/usr/bin/env node
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const source = path.join(root, "src");
const output = path.join(root, "_site");
const errors = [];
const required = [
  "index.html",
  "bookshelf/index.html",
  "about/index.html",
  "404.html",
  "search.json",
];
const fail = (message) => errors.push(message);
const exists = (file) => fs.existsSync(file) && fs.statSync(file).isFile();
const read = (file) => fs.readFileSync(file, "utf8");

function filesIn(directory) {
  if (!fs.existsSync(directory)) return [];
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const file = path.join(directory, entry.name);
    return entry.isDirectory() ? filesIn(file) : [file];
  });
}

function json(file) {
  try {
    return JSON.parse(read(file));
  } catch (error) {
    fail(`${path.relative(root, file)}: ${error.message}`);
    return null;
  }
}

// The generated markup uses quoted attributes; unquoted values are also supported.
function attributes(html, name) {
  const pattern = new RegExp(
    `(?:\\s|<)${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)'|([^\\s>]+))`,
    "gi",
  );
  return [...html.matchAll(pattern)].map((match) =>
    decodeEntities(match[1] ?? match[2] ?? match[3]),
  );
}

function decodeEntities(value) {
  return value.replace(
    /&(#x[\da-f]+|#\d+|amp|quot|apos|lt|gt);/gi,
    (match, entity) => {
      if (entity.startsWith("#")) {
        const number =
          entity[1].toLowerCase() === "x"
            ? parseInt(entity.slice(2), 16)
            : Number(entity.slice(1));
        return number <= 0x10ffff ? String.fromCodePoint(number) : match;
      }
      return { amp: "&", quot: '"', apos: "'", lt: "<", gt: ">" }[
        entity.toLowerCase()
      ];
    },
  );
}

const books = json(path.join(source, "_data/books.json"));
const bookIds = new Set();
if (!Array.isArray(books)) fail("src/_data/books.json must contain an array.");
for (const [index, book] of (Array.isArray(books) ? books : []).entries()) {
  if (!book || typeof book !== "object") {
    fail(`Book ${index + 1} must be an object.`);
    continue;
  }
  if (
    typeof book.id !== "string" ||
    !/^[a-z0-9]+(?:[-_][a-z0-9]+)*$/.test(book.id)
  )
    fail(`Book ${index + 1} has an invalid id: ${JSON.stringify(book.id)}.`);
  if (bookIds.has(book.id)) fail(`Duplicate book id: ${book.id}.`);
  bookIds.add(book.id);
  if (book.status && !["Read", "Reading", "To read"].includes(book.status))
    fail(`Book ${book.id}: status must be Read, Reading, or To read.`);
}

const postFiles = filesIn(path.join(source, "posts")).filter((file) =>
  file.endsWith(".md"),
);
if (!postFiles.length) fail("Add at least one Markdown post in src/posts/.");
for (const file of postFiles) {
  const label = path.relative(root, file);
  const frontmatter = read(file).match(
    /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/,
  )?.[1];
  if (!frontmatter) {
    fail(`${label}: missing YAML front matter.`);
    continue;
  }
}

if (!fs.existsSync(output)) {
  fail("No _site build found. Run npm run build, then npm run check.");
  finish();
}

for (const route of required) {
  const file = path.join(output, route);
  if (!exists(file) || fs.statSync(file).size === 0)
    fail(`Required output is missing or empty: _site/${route}.`);
}

if (exists(path.join(output, "journal/index.html")))
  fail("Obsolete journal listing remains at _site/journal/index.html. Remove it and rebuild.");

const htmlFiles = filesIn(output).filter((file) => file.endsWith(".html"));
const html = new Map(htmlFiles.map((file) => [file, read(file)]));
const idsByFile = new Map(
  [...html].map(([file, content]) => [
    file,
    new Set(attributes(content, "id")),
  ]),
);
let checkedLinks = 0;

function checkUrl(value, context, requireLocal = false) {
  if (!value.startsWith("/") || value.startsWith("//")) {
    if (requireLocal)
      fail(
        `${context}: expected a local URL, received ${JSON.stringify(value)}.`,
      );
    return;
  }
  checkedLinks++;
  let url, pathname, hash;
  try {
    url = new URL(value, "https://local.invalid");
    pathname = decodeURIComponent(url.pathname);
    hash = decodeURIComponent(url.hash.slice(1));
  } catch {
    fail(`${context}: invalid URL ${JSON.stringify(value)}.`);
    return;
  }
  let target = path.resolve(output, `.${pathname}`);
  if (target !== output && !target.startsWith(`${output}${path.sep}`)) {
    fail(`${context}: URL escapes _site: ${value}.`);
    return;
  }
  if (fs.existsSync(target) && fs.statSync(target).isDirectory())
    target = path.join(target, "index.html");
  if (!exists(target)) {
    fail(`${context}: broken local URL ${value}.`);
    return;
  }
  if (hash && target.endsWith(".html") && !idsByFile.get(target)?.has(hash))
    fail(`${context}: missing anchor #${hash} in ${pathname}.`);
}

for (const [file, content] of html) {
  const context = path.relative(output, file);
  for (const value of [
    ...attributes(content, "href"),
    ...attributes(content, "src"),
  ])
    checkUrl(value, context);
}

const searchFile = path.join(output, "search.json");
const search = exists(searchFile) ? json(searchFile) : null;
if (!Array.isArray(search)) fail("_site/search.json must contain an array.");
for (const [index, entry] of (Array.isArray(search) ? search : []).entries()) {
  if (
    !entry ||
    typeof entry.title !== "string" ||
    !entry.title.trim() ||
    typeof entry.url !== "string"
  ) {
    fail(`Search entry ${index + 1} needs a title and URL.`);
    continue;
  }
  checkUrl(entry.url, `Search entry "${entry.title}"`, true);
}
if (Array.isArray(search)) {
  for (const id of bookIds)
    if (!search.some((entry) => entry?.url === `/bookshelf/#${id}`))
      fail(`Book ${id} is missing from search.json.`);
  if (!search.some((entry) => entry?.type === "Article"))
    fail("search.json does not contain an article entry.");
}

let checkedAssets = 0;
for (const directory of ["assets/fonts", "assets/images"]) {
  const assets = filesIn(path.join(source, directory)).filter((file) =>
    /\.(?:woff2?|ttf|otf|jpe?g|png|webp|avif|gif|svg)$/i.test(file),
  );
  if (!assets.length) fail(`No assets found in src/${directory}/.`);
  for (const file of assets) {
    checkedAssets++;
    const relative = path.relative(source, file);
    const built = path.join(output, relative);
    if (fs.statSync(file).size === 0)
      fail(`Source asset is empty: src/${relative}.`);
    if (!exists(built) || fs.statSync(built).size === 0)
      fail(`Built asset is missing or empty: _site/${relative}.`);
  }
}

finish(
  `${htmlFiles.length} pages, ${checkedLinks} local links, ${postFiles.length} post, ${bookIds.size} book, ${checkedAssets} font/image assets`,
);

function finish(summary) {
  if (errors.length) {
    console.error(
      `Site check failed (${errors.length} issue${errors.length === 1 ? "" : "s"}):\n${errors.map((message) => `  • ${message}`).join("\n")}`,
    );
    process.exit(1);
  }
  console.log(`Site check passed: ${summary}.`);
}
