module.exports = {
  title: "Previously on Earth",
  description:
    "A history blog and reading list.",
  url: (process.env.SITE_URL || "").replace(/\/$/, ""),
  year: new Date().getFullYear(),
};
