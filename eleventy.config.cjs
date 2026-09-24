module.exports = function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy({ "src/assets": "assets" });
  eleventyConfig.addWatchTarget("src/assets/");

  eleventyConfig.addFilter("dateLabel", (date) =>
    new Intl.DateTimeFormat("en", {
      day: "numeric",
      month: "long",
      year: "numeric",
      timeZone: "UTC",
    }).format(new Date(date)),
  );
  eleventyConfig.addFilter("dateISO", (date) =>
    new Date(date).toISOString().slice(0, 10),
  );
  eleventyConfig.addFilter("year", (date) => new Date(date).getUTCFullYear());
  eleventyConfig.addFilter("pad", (number) => String(number).padStart(2, "0"));
  eleventyConfig.addFilter("json", (value) => JSON.stringify(value));
  eleventyConfig.addCollection("journal", (api) =>
    api.getFilteredByTag("posts").sort((a, b) => b.date - a.date),
  );

  return {
    dir: {
      input: "src",
      includes: "_includes",
      data: "_data",
      output: "_site",
    },
    htmlTemplateEngine: "njk",
    markdownTemplateEngine: "njk",
    templateFormats: ["njk", "md", "11ty.js"],
  };
};
