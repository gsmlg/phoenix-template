import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";
import { synchronizeTheme, validTheme, validThemePreference } from "../js/theme.js";

function browser({ stored = null, blocked = false, protocol = "https:", dark = false } = {}) {
  const attributes = { "data-theme": "sunshine" };
  const listeners = {};
  let systemListener;
  const media = {
    matches: dark,
    addEventListener: (_key, fn) => { systemListener = fn; },
    removeEventListener: () => { systemListener = undefined; },
  };
  const doc = { cookie: "", documentElement: {
    getAttribute: key => attributes[key], setAttribute: (key, value) => { attributes[key] = value; },
  } };
  const win = {
    location: { protocol },
    matchMedia: () => media,
    systemTheme: value => { media.matches = value; systemListener?.(); },
    localStorage: { getItem: () => { if (blocked) throw Error("blocked"); return stored; },
      setItem: (_key, value) => { if (blocked) throw Error("blocked"); stored = value; } },
    MutationObserver: class {
      constructor(callback) { win.mutate = callback; }
      observe(_root, options) { assert.deepEqual(options.attributeFilter, ["data-theme"]); }
      disconnect() { win.disconnected = true; }
    },
    addEventListener: (key, fn) => { listeners[key] = event => {
      if (key === "storage" && event.key === "theme") stored = event.newValue;
      fn(event);
    }; },
    removeEventListener: (key) => { delete listeners[key]; },
  };
  return { win, doc, listeners };
}

test("only supported themes are accepted", () => {
  for (const value of [null, undefined, "default", "dark", "moonlight; injected=true"]) assert.equal(validTheme(value), false);
  assert.equal(validTheme("moonlight"), true);
  assert.equal(validTheme("sunshine"), true);
  assert.equal(validThemePreference("default"), true);
  assert.equal(validThemePreference("dark"), false);
});
test("initial document theme script tolerates blocked storage and rejects unknown themes", () => {
  const layout = readFileSync(new URL("../../lib/gsmlg_web/components/layouts/root.html.heex", import.meta.url), "utf8");
  const script = layout.match(/<script>\s*([\s\S]*?)<\/script>/)?.[1];
  assert.ok(script, "the pre-paint theme script exists");

  for (const options of [{ blocked: true }, { stored: "invalid" }, { stored: "moonlight" }, { stored: "default", dark: true }]) {
    const { win, doc } = browser(options);
    assert.doesNotThrow(() => runInNewContext(script, { localStorage: win.localStorage, document: doc, matchMedia: win.matchMedia }));
    assert.equal(doc.documentElement.getAttribute("data-theme"), options.stored === "moonlight" || options.dark ? "moonlight" : "sunshine");
  }
});
test("stored theme initializes document and server cookie", () => {
  const { win, doc } = browser({ stored: "moonlight" });
  synchronizeTheme(win, doc);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "moonlight");
  assert.match(doc.cookie, /^gsmlg_theme=moonlight; Path=\/; Max-Age=31536000; SameSite=Lax; Secure$/);
});
test("blocked storage still synchronizes the cookie", () => {
  const { win, doc } = browser({ blocked: true, protocol: "http:" });
  synchronizeTheme(win, doc);
  assert.match(doc.cookie, /^gsmlg_theme=sunshine;/);
  assert.equal(doc.cookie.includes("Secure"), false);
});
test("blocked cookies do not stop theme initialization or subsequent updates", () => {
  const { win, doc } = browser({ stored: "moonlight" });
  Object.defineProperty(doc, "cookie", { set() { throw new Error("SecurityError"); } });
  const cleanup = synchronizeTheme(win, doc);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "moonlight");
  doc.documentElement.setAttribute("data-theme", "sunshine");
  assert.doesNotThrow(() => win.mutate());
  assert.equal(win.localStorage.getItem("theme"), "sunshine");
  cleanup();
});
test("unsupported stored and cross-tab themes leave the current theme unchanged", () => {
  const { win, doc, listeners } = browser({ stored: "invalid" });
  const cleanup = synchronizeTheme(win, doc);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
  for (const newValue of [null, "dark", "moonlight; injected=true"]) {
    listeners.storage({ key: "theme", newValue });
  }
  listeners.storage({ key: "unrelated", newValue: "moonlight" });
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
  cleanup();
});
test("switches and cross-tab changes persist; cleanup releases listeners", () => {
  const { win, doc, listeners } = browser();
  const cleanup = synchronizeTheme(win, doc);
  doc.documentElement.setAttribute("data-theme", "moonlight"); win.mutate();
  assert.match(doc.cookie, /^gsmlg_theme=moonlight;/);
  listeners.storage({ key: "theme", newValue: "sunshine" }); win.mutate();
  assert.match(doc.cookie, /^gsmlg_theme=sunshine;/);
  cleanup(); assert.equal(win.disconnected, true); assert.deepEqual(listeners, {});
});

test("Auto follows system changes without overwriting the stored preference", () => {
  const { win, doc } = browser({ stored: "default", dark: true });
  const cleanup = synchronizeTheme(win, doc);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "moonlight");
  assert.equal(doc.documentElement.getAttribute("data-theme-preference"), "default");
  win.systemTheme(false);
  win.mutate();
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
  assert.equal(win.localStorage.getItem("theme"), "default");
  cleanup();
  win.systemTheme(true);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
});

test("Appearance selections persist and explicit modes ignore system changes", () => {
  const { win, doc, listeners } = browser();
  synchronizeTheme(win, doc);
  listeners.click({ target: { closest: () => ({ value: "moonlight" }) } });
  assert.equal(win.localStorage.getItem("theme"), "moonlight");
  win.systemTheme(false);
  assert.equal(doc.documentElement.getAttribute("data-theme"), "moonlight");
  listeners.click({ target: { closest: () => ({ value: "default" }) } });
  assert.equal(win.localStorage.getItem("theme"), "default");
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
  listeners.click({ target: { closest: () => ({ value: "unsupported" }) } });
  assert.equal(win.localStorage.getItem("theme"), "default");
});

test("the home switcher can replace an automatic preference", () => {
  const { win, doc } = browser({ stored: "default", dark: true });
  synchronizeTheme(win, doc);
  win.localStorage.setItem("theme", "sunshine");
  doc.documentElement.setAttribute("data-theme", "sunshine");
  win.mutate();
  win.systemTheme(true);
  assert.equal(doc.documentElement.getAttribute("data-theme-preference"), "sunshine");
  assert.equal(doc.documentElement.getAttribute("data-theme"), "sunshine");
});

test("cross-tab preferences update already mounted home selector inputs", () => {
  const { win, doc, listeners } = browser({ stored: "sunshine" });
  const inputs = [{ value: "default" }, { value: "sunshine" }, { value: "moonlight" }];
  doc.querySelectorAll = selector => selector.includes("ThemeSwitcher") ? inputs : [];
  synchronizeTheme(win, doc);
  assert.equal(inputs[1].checked, true);
  listeners.storage({ key: "theme", newValue: "moonlight" });
  assert.equal(inputs[1].checked, false);
  assert.equal(inputs[2].checked, true);
  listeners.storage({ key: "theme", newValue: "default" });
  assert.equal(inputs[0].checked, true);
  assert.equal(inputs[2].checked, false);
});
