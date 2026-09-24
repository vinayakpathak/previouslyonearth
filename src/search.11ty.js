class SearchIndex {
  data() {
    return { permalink: "/search.json", eleventyExcludeFromCollections: true };
  }
  render(data) {
    const posts = data.collections.journal.map((post) => ({
      type: "Article",
      title: post.data.title,
      description: post.data.description,
      keywords: [
        post.data.category,
        post.data.era,
        post.templateContent.replace(/<[^>]*>/g, " "),
      ].join(" "),
      url: post.url,
    }));
    const books = data.books.map((book) => ({
      type: "Book",
      title: book.title,
      description: [book.subtitle, book.author].filter(Boolean).join(" · "),
      keywords: [book.note, book.year, book.status].filter(Boolean).join(" "),
      url: `/bookshelf/#${book.id}`,
    }));
    return JSON.stringify([...posts, ...books]);
  }
}
module.exports = SearchIndex;
