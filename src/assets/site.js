(() => {
  const themeButton = document.querySelector("[data-theme-toggle]");
  const syncThemeLabel = () => {
    const dark = document.documentElement.dataset.theme === "dark";
    themeButton?.setAttribute(
      "aria-label",
      `Switch to ${dark ? "light" : "dark"} appearance`,
    );
    const label = document.querySelector("[data-theme-label]");
    if (label) label.textContent = dark ? "Light mode" : "Dark mode";
    document
      .querySelector('meta[name="theme-color"]')
      ?.setAttribute("content", dark ? "#242520" : "#f5f2e9");
  };
  syncThemeLabel();
  themeButton?.addEventListener("click", () => {
    const next =
      document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    document.documentElement.dataset.theme = next;
    try {
      localStorage.setItem("poe-theme", next);
    } catch (_) {
      /* Theme still works without storage. */
    }
    syncThemeLabel();
  });

  const articleList = document.querySelector("#article-list");
  const moreArticles = document.querySelector("[data-more-articles]");
  if (articleList && moreArticles) {
    const articles = [...articleList.querySelectorAll(".featured-post")];
    const initialCount = 5;
    let showAll = false;
    try {
      showAll = sessionStorage.getItem("poe-all-articles") === "true";
    } catch (_) {
      /* All articles can still be opened without storage. */
    }
    if (articles.length > initialCount && !showAll) {
      const remaining = articles.slice(initialCount);
      remaining.forEach((article) => {
        article.hidden = true;
      });
      moreArticles.hidden = false;
      moreArticles.addEventListener("click", () => {
        remaining.forEach((article) => {
          article.hidden = false;
        });
        moreArticles.hidden = true;
        try {
          sessionStorage.setItem("poe-all-articles", "true");
        } catch (_) {
          /* Expansion still works for this visit. */
        }
        remaining[0].querySelector("a")?.focus();
      });
    }
  }

  const dialog = document.querySelector(".search-dialog");
  const input = document.querySelector("#search-input");
  const results = document.querySelector(".search-results");
  let searchIndex;
  let loading;
  const normalize = (value) =>
    value
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[’‘]/g, "'");
  const showMessage = (message) => {
    const paragraph = document.createElement("p");
    paragraph.className = "search-empty";
    paragraph.textContent = message;
    results.replaceChildren(paragraph);
  };
  const renderSearch = () => {
    if (!searchIndex) return;
    const query = normalize(input.value.trim());
    const words = query.split(/\s+/).filter(Boolean);
    const matches = searchIndex
      .filter((item) =>
        words.every((word) =>
          normalize(
            `${item.title} ${item.description} ${item.keywords}`,
          ).includes(word),
        ),
      )
      .slice(0, 15);
    results.replaceChildren();
    if (!matches.length) return showMessage("No results found.");
    matches.forEach((item) => {
      const link = document.createElement("a");
      link.className = "search-result";
      link.href = item.url;
      const type = document.createElement("span");
      type.className = "overline";
      type.textContent = item.type;
      const title = document.createElement("h3");
      title.textContent = item.title;
      const description = document.createElement("p");
      description.textContent = item.description;
      link.append(type, title, description);
      link.addEventListener("click", () => {
        if (
          item.url.startsWith("/bookshelf/#") &&
          location.pathname === "/bookshelf/"
        ) {
          requestAnimationFrame(() =>
            document.getElementById(item.url.split("#")[1])?.scrollIntoView(),
          );
        }
        dialog.close();
      });
      results.append(link);
    });
  };
  const loadIndex = async () => {
    if (searchIndex) return;
    if (!loading)
      loading = fetch("/search.json")
        .then((response) => {
          if (!response.ok) throw new Error("Search index unavailable");
          return response.json();
        })
        .then((data) => {
          searchIndex = data;
        })
        .catch((error) => {
          loading = undefined;
          throw error;
        });
    await loading;
  };
  const openSearch = async () => {
    if (!dialog || dialog.open) return;
    dialog.showModal();
    document.body.style.overflow = "hidden";
    input.focus();
    showMessage("Loading…");
    try {
      await loadIndex();
      renderSearch();
    } catch (_) {
      showMessage("Search could not be loaded. Please try again.");
    }
  };
  document
    .querySelector("[data-open-search]")
    ?.addEventListener("click", openSearch);
  document
    .querySelector(".close-search")
    ?.addEventListener("click", () => dialog.close());
  dialog?.addEventListener("close", () => {
    document.body.style.overflow = "";
  });
  dialog?.addEventListener("click", (event) => {
    const bounds = dialog.getBoundingClientRect();
    if (
      event.target === dialog &&
      (event.clientX < bounds.left ||
        event.clientX > bounds.right ||
        event.clientY < bounds.top ||
        event.clientY > bounds.bottom)
    )
      dialog.close();
  });
  input?.addEventListener("input", renderSearch);
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && dialog?.open) {
      event.preventDefault();
      dialog.close();
      return;
    }
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      if (dialog?.open) dialog.close();
      else openSearch();
    }
  });

  const progress = document.querySelector(".reading-progress > span");
  const article = document.querySelector(".post-body");
  if (progress && article) {
    let scheduled = false;
    const update = () => {
      const start = article.getBoundingClientRect().top + window.scrollY;
      const distance = article.offsetHeight - window.innerHeight + 100;
      const fraction =
        distance <= 0
          ? window.scrollY >= start
            ? 1
            : 0
          : (window.scrollY - start + 100) / distance;
      progress.style.transform = `scaleX(${Math.min(1, Math.max(0, fraction))})`;
      scheduled = false;
    };
    const scheduleUpdate = () => {
      if (!scheduled) {
        scheduled = true;
        requestAnimationFrame(update);
      }
    };
    window.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", scheduleUpdate);
    document.fonts?.ready.then(update);
    update();
  }
})();
