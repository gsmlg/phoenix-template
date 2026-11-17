export function validTheme(value) {
  return value === "sunshine" || value === "moonlight";
}

export function validThemePreference(value) {
  return value === "default" || validTheme(value);
}

function syncPreferenceControls(group, preference) {
  for (const button of group.querySelectorAll("button[value]")) {
    const active = button.value === preference;
    button.setAttribute("aria-pressed", String(active));
    button.classList.toggle("toggle-btn-active", active);
  }
}

export const AppearancePreference = {
  mounted() { syncPreferenceControls(this.el, this.el.ownerDocument.documentElement.getAttribute("data-theme-preference")); },
  updated() { this.mounted(); },
};

// Share one preference between the home switcher, Appearance, and other renderers.
export function synchronizeTheme(win = window, doc = document) {
  const root = doc.documentElement;
  const darkQuery = win.matchMedia?.("(prefers-color-scheme: dark)");
  const readPreference = () => {
    try { return win.localStorage.getItem("theme"); } catch { return null; }
  };
  const stored = readPreference();
  let preference = validThemePreference(stored) ? stored : "default";
  const resolve = value => value === "default" ? (darkQuery?.matches ? "moonlight" : "sunshine") : value;
  const saveCookie = () => {
    const theme = root.getAttribute("data-theme");
    if (!validTheme(theme)) return;
    try {
      doc.cookie = `gsmlg_theme=${theme}; Path=/; Max-Age=31536000; SameSite=Lax${win.location.protocol === "https:" ? "; Secure" : ""}`;
    } catch { /* Cookie restrictions must not prevent LiveView from connecting. */ }
  };
  const apply = (next, persist = false) => {
    if (!validThemePreference(next)) return;
    preference = next;
    const theme = resolve(preference);
    if (root.getAttribute("data-theme") !== theme) root.setAttribute("data-theme", theme);
    root.setAttribute("data-theme-preference", preference);
    if (persist) {
      try { win.localStorage.setItem("theme", preference); } catch { /* Persistence is optional. */ }
    }
    for (const group of doc.querySelectorAll?.("[data-appearance-control]") || []) syncPreferenceControls(group, preference);
    for (const input of doc.querySelectorAll?.('[phx-hook="ThemeSwitcher"] .theme-controller-item') || []) input.checked = input.value === preference;
    saveCookie();
  };
  apply(preference);
  const observer = new win.MutationObserver(() => {
    const storedPreference = readPreference();
    if (validThemePreference(storedPreference) && storedPreference !== preference) {
      apply(storedPreference);
    } else {
      const theme = root.getAttribute("data-theme");
      if (validTheme(theme) && theme !== resolve(preference)) apply(theme, true);
      else saveCookie();
    }
  });
  observer.observe(root, { attributes: true, attributeFilter: ["data-theme"] });
  const onStorage = (event) => {
    if (event.key === "theme" && validThemePreference(event.newValue)) apply(event.newValue);
  };
  const onSystemTheme = () => { if (preference === "default") apply("default"); };
  const onClick = event => {
    const button = event.target.closest?.("[data-appearance-control] button[value]");
    if (button) apply(button.value, true);
  };
  win.addEventListener("storage", onStorage);
  win.addEventListener("click", onClick);
  darkQuery?.addEventListener("change", onSystemTheme);
  return () => {
    observer.disconnect();
    win.removeEventListener("storage", onStorage);
    win.removeEventListener("click", onClick);
    darkQuery?.removeEventListener("change", onSystemTheme);
  };
}
