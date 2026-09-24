try {
  const saved = localStorage.getItem("poe-theme");
  if (saved === "dark" || saved === "light")
    document.documentElement.dataset.theme = saved;
} catch (_) {
  /* The default paper theme also works without storage. */
}
