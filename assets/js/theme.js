export function validTheme(value) {
  return value === "sunshine" || value === "moonlight";
}

// Keep the server-rendered Hologram shell in sync with the LiveView theme switcher.
export function synchronizeTheme(win = window, doc = document) {
  const root = doc.documentElement;
  const save = () => {
    const theme = root.getAttribute("data-theme");
    if (!validTheme(theme)) return;
    try { win.localStorage.setItem("theme", theme); } catch { /* Storage may be blocked. */ }
    try {
      doc.cookie = `gsmlg_theme=${theme}; Path=/; Max-Age=31536000; SameSite=Lax${win.location.protocol === "https:" ? "; Secure" : ""}`;
    } catch { /* Cookie restrictions must not prevent LiveView from connecting. */ }
  };
  try {
    const stored = win.localStorage.getItem("theme");
    if (validTheme(stored)) root.setAttribute("data-theme", stored);
  } catch { /* Use the server-rendered theme when storage is unavailable. */ }
  save();
  const observer = new win.MutationObserver(save);
  observer.observe(root, { attributes: true, attributeFilter: ["data-theme"] });
  const onStorage = (event) => {
    if (event.key === "theme" && validTheme(event.newValue)) {
      root.setAttribute("data-theme", event.newValue);
    }
  };
  win.addEventListener("storage", onStorage);
  return () => {
    observer.disconnect();
    win.removeEventListener("storage", onStorage);
  };
}
