import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";
import { synchronizeTheme, validTheme } from "../js/theme.js";

function browser({ stored = null, blocked = false, protocol = "https:" } = {}) {
  let theme = "sunshine";
  const listeners = {};
  const doc = { cookie: "", documentElement: {
    getAttribute: () => theme, setAttribute: (_key, value) => { theme = value; },
  } };
  const win = {
    location: { protocol },
    localStorage: { getItem: () => { if (blocked) throw Error("blocked"); return stored; },
      setItem: (_key, value) => { if (blocked) throw Error("blocked"); stored = value; } },
    MutationObserver: class {
      constructor(callback) { win.mutate = callback; }
      observe(_root, options) { assert.deepEqual(options.attributeFilter, ["data-theme"]); }
      disconnect() { win.disconnected = true; }
    },
    addEventListener: (key, fn) => { listeners[key] = fn; },
    removeEventListener: (key) => { delete listeners[key]; },
  };
  return { win, doc, listeners };
}

test("only supported themes are accepted", () => {
  for (const value of [null, undefined, "default", "dark", "moonlight; injected=true"]) assert.equal(validTheme(value), false);
  assert.equal(validTheme("moonlight"), true);
  assert.equal(validTheme("sunshine"), true);
});
test("initial document theme script tolerates blocked storage and rejects unknown themes", () => {
  const layout = readFileSync(new URL("../../lib/gsmlg_web/components/layouts/root.html.heex", import.meta.url), "utf8");
  const script = layout.match(/<script>\s*([\s\S]*?)<\/script>/)?.[1];
  assert.ok(script, "the pre-paint theme script exists");

  for (const options of [{ blocked: true }, { stored: "invalid" }, { stored: "moonlight" }]) {
    const { win, doc } = browser(options);
    assert.doesNotThrow(() => runInNewContext(script, { localStorage: win.localStorage, document: doc }));
    assert.equal(doc.documentElement.getAttribute("data-theme"), options.stored === "moonlight" ? "moonlight" : "sunshine");
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
