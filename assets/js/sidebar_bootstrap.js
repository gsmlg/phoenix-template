(() => {
  try {
    if (localStorage.getItem("gsmlg.navigation.collapsed") !== "true") return;
  } catch {
    return;
  }

  // Restore the rail as the document parser inserts it, before the runtime mounts.
  const observer = new MutationObserver(() => {
    const menu = document.getElementById("design-left-menu");
    if (!menu) return;

    menu.dataset.collapsed = "true";
    const toggle = menu.querySelector("[data-left-menu-toggle]");
    if (!toggle) return;

    const label = menu.dataset.expandLabel ?? "Expand navigation";
    toggle.setAttribute("aria-expanded", "false");
    toggle.setAttribute("aria-label", label);
    toggle.title = label;
    observer.disconnect();
  });

  observer.observe(document.documentElement, { childList: true, subtree: true });
  document.addEventListener("DOMContentLoaded", () => observer.disconnect(), { once: true });
})();
