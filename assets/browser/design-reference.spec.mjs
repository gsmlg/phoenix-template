import { test, expect } from "@playwright/test";
import { readFile } from "node:fs/promises";
import { createHash } from "node:crypto";

const connected = page => expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
const action = (page, id) => page.locator(`#${id}`).getByRole("button");

function captureErrors(page, expectedRedirects = []) {
  const errors = [];
  page.on("pageerror", error => errors.push(error.message));
  page.on("console", message => { if (message.type() === "error") errors.push(message.text()); });
  page.on("response", response => {
    const url = new URL(response.url());
    const expectedRedirect = response.status() === 302 && expectedRedirects.includes(`${url.pathname}${url.search}`);
    if (["document", "stylesheet", "script"].includes(response.request().resourceType()) &&
        !response.ok() && response.status() !== 304 && !expectedRedirect) errors.push(`${response.status()} ${response.url()}`);
  });
  return errors;
}

async function selectTheme(page, theme) {
  const settings = await page.context().newPage();
  await settings.goto("/use-cases/settings/appearance");
  await connected(settings);
  await settings.locator(`#appearance-preference button[value="${theme}"]`).click();
  await expect(settings.locator("html")).toHaveAttribute("data-theme", theme);
  await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
  await settings.close();
  if (await page.locator("[data-phx-session]").count()) await connected(page);
}

test("reference navigation, ecosystem roles and canonical specification export", async ({ page, request }) => {
  const errors = captureErrors(page);
  await page.goto("/");
  await connected(page);
  await expect(page.locator("h1")).toContainText("One design language.");
  for (const repository of ["design", "duskmoonui", "duskmoon-react", "duskmoon-elements", "phoenix-duskmoon-ui"]) {
    await expect(page.locator(`a[href="https://github.com/duskmoon-dev/${repository}"]`).first()).toBeVisible();
  }
  const navigation = page.getByRole("navigation", { name: "Main navigation", exact: true });
  for (const [name, path] of [["Guidelines", "/guidelines"], ["Components", "/components"], ["Use Cases", "/use-cases"], ["Overview", "/"]]) {
    await navigation.getByRole("link", { name: new RegExp(name) }).click();
    await expect(page).toHaveURL(new RegExp(`${path === "/" ? "/" : path}$`));
    await expect(navigation.locator(`a[href="${path}"]:visible`)).toHaveAttribute("aria-current", "page");
    await connected(page);
  }
  await page.goto("/guidelines");
  await expect(page.locator("#design-specification")).toContainText("Downstream Alignment");
  const source = await readFile(new URL("../../DESIGN.md", import.meta.url));
  const response = await request.get("/guidelines/DESIGN.md");
  expect(response.ok()).toBeTruthy();
  expect(Buffer.compare(await response.body(), source)).toBe(0);
  expect(response.headers()["x-design-spec-sha256"]).toBe(createHash("sha256").update(source).digest("hex"));
  const downloadPromise = page.waitForEvent("download");
  await page.locator("#download-design").click();
  expect((await downloadPromise).suggestedFilename()).toBe("DESIGN.md");
  expect(errors).toEqual([]);
});

test("Core, Phoenix and React execute real interactions and share both themes", async ({ page }, testInfo) => {
  const errors = captureErrors(page);
  await page.goto("/components");
  await connected(page);
  await page.locator("#core-add").click();
  await expect(page.locator("#core-count")).toHaveText("1 items");
  await page.locator("#core-reset").click();
  await expect(page.locator("#core-count")).toHaveText("0 items");

  await page.locator("#component-label").fill("Release review");
  await expect(page.locator("#component-label-output")).toHaveText("Release review");
  for (let step = 1; step <= 4; step++) {
    await action(page, "component-advance").click();
    await expect(page.locator("#component-progress")).toHaveAttribute("aria-valuenow", String(step * 25));
  }
  await expect(action(page, "component-advance")).toBeDisabled();
  await action(page, "component-reset").click();
  await expect(page.locator("#component-progress")).toHaveAttribute("aria-valuenow", "0");
  await page.locator("#react-component-preview").scrollIntoViewIfNeeded();
  const react = page.frameLocator("#react-component-preview");
  await expect(react.locator("#react-approval-count")).toHaveText("0 of 3 approved");
  for (let count = 1; count <= 3; count++) {
    await react.locator("#react-approve").click();
    await expect(react.locator("#react-approval-count")).toHaveText(`${count} of 3 approved`);
  }
  await expect(react.locator("#react-approve")).toBeDisabled();
  await react.locator("#react-reset").click();
  await expect(react.locator("#react-approval-count")).toHaveText("0 of 3 approved");

  for (const theme of ["moonlight", "sunshine"]) {
    await selectTheme(page, theme);
    await expect(react.locator("html")).toHaveAttribute("data-theme", theme);
    const parentPrimary = await page.locator("html").evaluate(el => getComputedStyle(el).getPropertyValue("--color-primary"));
    await expect.poll(() => react.locator("html").evaluate(el => getComputedStyle(el).getPropertyValue("--color-primary")))
      .toBe(parentPrimary);
    await expect(react.locator("#react-approve")).toHaveCSS("padding", "10px 20px");
    await expect(react.locator("#react-approve")).toHaveCSS("border-top-width", "1px");
    await expect(react.locator("#react-approve")).not.toHaveCSS("background-color", "rgba(0, 0, 0, 0)");
    await page.locator("#react-component-preview").scrollIntoViewIfNeeded();
    await page.screenshot({ path: testInfo.outputPath(`components-${theme}.png`) });
    await expect.poll(() => page.locator("body").evaluate(el => getComputedStyle(el).fontFamily)).toMatch(/sans-serif/);
  }
  const registered = await page.evaluate(() => ["el-dm-button", "el-dm-input", "el-dm-switch", "el-dm-dialog", "el-dm-table"].every(tag => customElements.get(tag)));
  expect(registered).toBe(true);
  expect(errors).toEqual([]);
});

test("use-case settings support Enter and cancel, filters recover and selection is cleared", async ({ page }) => {
  const errors = captureErrors(page);
  await page.goto("/use-cases");
  await connected(page);
  await page.locator("#profile-name").fill("Atlas team");
  await page.locator("#profile-name").press("Enter");
  await expect(page.locator("#saved-profile")).toContainText("Atlas team");
  await page.locator("#profile-name").fill("Unsaved edit");
  await action(page, "cancel-settings").click();
  await expect(page.locator("#profile-name")).toHaveValue("Atlas team");
  await action(page, "select-record-atlas").click();
  await expect(page.locator("#selected-record")).toContainText("Atlas workspace");
  await page.locator("#search-status").selectOption("draft");
  await expect(page.locator("#selected-record")).toHaveCount(0);
  await expect(page.locator("#result-count")).toHaveText("1 workspace");
  await page.locator("#search-query").fill("missing");
  await expect(page.locator("#empty-results")).toBeVisible();
  await action(page, "clear-filters").click();
  await expect(page.locator("#result-count")).toHaveText("3 workspaces");
  await expect(page.locator("#search-status")).toHaveValue("all");
  await selectTheme(page, "moonlight");
  await action(page, "ask-remove").click();
  await action(page, "cancel-remove").click();
  await expect(page.locator("#ask-remove")).toBeVisible();
  expect(errors).toEqual([]);
});

for (const theme of ["sunshine", "moonlight"]) {
  test(`desktop pages render in ${theme} without overflow or runtime errors`, async ({ page }, testInfo) => {
    const errors = captureErrors(page);
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.addInitScript(theme => localStorage.setItem("theme", theme), theme);
    for (const path of ["/", "/guidelines", "/components", "/use-cases", "/use-cases/settings", "/use-cases/session", "/hologram-demo"]) {
      await page.goto(path);
      if (path !== "/hologram-demo") await connected(page);
      await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
      await expect(page.locator("h1")).toHaveCount(1);
      if (path === "/use-cases") {
        await expect.poll(() => page.locator(".badge-neutral").evaluateAll(elements =>
          elements.every(element => getComputedStyle(element).backgroundColor === "rgba(0, 0, 0, 0)")))
          .toBe(true);
      }
      await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
      await expect.poll(() => page.locator(".design-shell").evaluate(el => getComputedStyle(el).display)).toBe(path === "/" ? "block" : "grid");
      const appbar = page.locator("#design-appbar");
      const menu = page.locator("#design-left-menu");
      if (path === "/") {
        await expect(page.locator("#home-page-header")).toBeVisible();
        await expect(appbar).toHaveCount(0);
        await expect(menu).toHaveCount(0);
      } else {
        await expect(appbar).toBeVisible();
        await expect(menu).toBeVisible();
        await expect.poll(() => menu.evaluate(el => {
          const expected = getComputedStyle(el).color;
          return [...el.querySelectorAll('a:not([aria-current="page"]), [data-left-menu-toggle]')]
            .every(link => getComputedStyle(link).color === expected);
        })).toBe(true);
        const barBox = await appbar.boundingBox();
        const brandBox = await appbar.locator(".appbar-brand").boundingBox();
        const navBox = await appbar.locator("nav[aria-label='Main navigation']").boundingBox();
        expect(navBox.x).toBeGreaterThanOrEqual(brandBox.x + brandBox.width);
        expect(navBox.x - brandBox.x - brandBox.width).toBeLessThan(80);
        await expect(appbar.locator('[phx-hook="ThemeSwitcher"]')).toHaveCount(0);
        const menuBox = await menu.boundingBox();
        const mainBox = await page.locator("main").boundingBox();
        expect(menuBox.y).toBeGreaterThanOrEqual(barBox.y + barBox.height - 1);
        expect(mainBox.x).toBeGreaterThanOrEqual(menuBox.x + menuBox.width - 1);
        expect(barBox.width).toBeGreaterThan(menuBox.width + 500);
      }
      await page.screenshot({ path: testInfo.outputPath(`${path.replaceAll("/", "_") || "overview"}-${theme}.png`) });
    }
    expect(errors).toEqual([]);
  });
}

// TODO(upstream): duskmoon-dev/duskmoon-elements#90; keep this
// regression failing until a published aggregate release preserves input focus.
test("Elements input accepts keyboard entry and survives unrelated LiveView updates", async ({ page }) => {
  await page.goto("/components");
  await connected(page);
  const input = page.locator("#elements-name").locator("input");
  await input.fill("Design team");
  await expect(input).toHaveValue("Design team");
  await page.locator("#core-add").click();
  await expect(input).toHaveValue("Design team");
});

test("Elements switch supports pointer and keyboard changes and retains local state", async ({ page }) => {
  const errors = captureErrors(page);
  await page.goto("/components");
  await connected(page);
  const toggle = page.locator("#elements-switch").getByRole("switch");
  await expect(toggle).toHaveAttribute("aria-checked", "false");
  await toggle.click();
  await expect(toggle).toHaveAttribute("aria-checked", "true");
  await page.locator("#core-add").click();
  await expect(page.locator("#core-count")).toHaveText("1 items");
  await expect(toggle).toHaveAttribute("aria-checked", "true");
  await toggle.focus();
  await page.keyboard.press("Space");
  await expect(toggle).toHaveAttribute("aria-checked", "false");
  expect(errors).toEqual([]);
});

for (const theme of ["sunshine", "moonlight"]) {
  test(`sidebar collapse preserves navigation, drafts and renderer state in ${theme}`, async ({ page }, testInfo) => {
    const errors = captureErrors(page);
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.addInitScript(theme => localStorage.setItem("theme", theme), theme);
    await page.context().addCookies([{ name: "gsmlg_theme", value: theme, url: "http://localhost:4444" }]);
    await page.goto("/use-cases");
    await connected(page);
    const menu = page.locator("#design-left-menu");
    const expandedWidth = await menu.evaluate(el => el.getBoundingClientRect().width);
    const expandedContentX = await page.locator("main").evaluate(el => el.getBoundingClientRect().x);
    const draft = page.getByRole("textbox", { name: "Workspace name", exact: true });
    await draft.fill("Sidebar draft");
    const collapse = menu.getByRole("button", { name: "Collapse navigation", exact: true });
    await collapse.focus();
    await page.keyboard.press("Enter");
    await expect(menu).toHaveAttribute("data-collapsed", "true");
    await expect(menu.getByRole("button", { name: "Expand navigation" })).toHaveAttribute("aria-expanded", "false");
    await expect(draft).toHaveValue("Sidebar draft");
    await expect.poll(() => menu.evaluate(el => el.getBoundingClientRect().width)).toBeLessThan(expandedWidth - 100);
    await expect.poll(() => page.locator("main").evaluate(el => el.getBoundingClientRect().x)).toBeLessThan(expandedContentX - 100);
    const sessionLink = menu.getByRole("link", { name: "Session state", exact: true });
    await sessionLink.focus();
    await expect(page.getByRole("tooltip", { name: "Session state", exact: true })).toBeVisible();
    await page.screenshot({ path: testInfo.outputPath(`sidebar-collapsed-${theme}.png`) });
    await sessionLink.click();
    await connected(page);
    await expect(menu).toHaveAttribute("data-collapsed", "true");
    await expect(menu.locator("a[aria-current='page']")).toHaveAccessibleName("Session state");
    await page.reload();
    await connected(page);
    await expect(menu).toHaveAttribute("data-collapsed", "true");
    await menu.getByRole("link", { name: "Browser-local state", exact: true }).click();
    await expect(page).toHaveURL(/\/hologram-demo$/);
    await expect(menu).toHaveAttribute("data-collapsed", "true");
    await menu.getByRole("link", { name: "Session state", exact: true }).focus();
    await expect(page.getByRole("tooltip", { name: "Session state", exact: true })).toBeVisible();
    await page.locator("#hologram-increment").click();
    await expect(page.locator("#hologram-count")).toHaveText("1");
    await menu.getByRole("button", { name: "Expand navigation" }).click();
    await expect(menu).toHaveAttribute("data-collapsed", "false");
    await expect(page.locator("#hologram-count")).toHaveText("1");
    await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
    await menu.getByRole("link", { name: "Introduction", exact: true }).click();
    await connected(page);
    await expect(menu).toHaveAttribute("data-collapsed", "false");
    await expect.poll(() => menu.evaluate(el => el.getBoundingClientRect().width)).toBe(expandedWidth);
    expect(errors).toEqual([]);
  });
}

for (const theme of ["sunshine", "moonlight"]) {
  test(`object settings support section navigation, save and cancel in ${theme}`, async ({ page }, testInfo) => {
    const errors = captureErrors(page);
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.addInitScript(theme => localStorage.setItem("theme", theme), theme);
    await page.goto("/use-cases");
    await connected(page);
    await page.locator("#design-left-menu").getByRole("link", { name: "Settings layout", exact: true }).click();
    await connected(page);
    const sections = page.getByRole("navigation", { name: "Workspace settings sections" });
    const name = page.getByRole("textbox", { name: "Display name", exact: true });
    await name.fill("Draft workspace");
    await page.getByRole("textbox", { name: "Description", exact: true }).fill("A shared profile.");
    await sections.getByRole("link", { name: "GitHub integration", exact: true }).click();
    await expect(page).toHaveURL(/\/use-cases\/settings\/github$/);
    await page.getByRole("textbox", { name: "Repository", exact: true }).fill("invalid");
    await page.getByRole("button", { name: "Save integration", exact: true }).click();
    await expect(page.locator("#settings-repository-errors")).toContainText("Use owner/repository");
    await sections.getByRole("link", { name: "General", exact: true }).click();
    await expect(name).toHaveValue("Draft workspace");
    await name.fill(" ");
    await page.getByRole("button", { name: "Save changes", exact: true }).click();
    await expect(page.locator("#settings-display-name-errors")).toBeVisible();
    await name.fill("  Atlas workspace  ");
    await page.getByRole("button", { name: "Save changes", exact: true }).click();
    await expect(page.locator("#settings-workspace-name")).toHaveText("Atlas workspace");
    await expect(name).toHaveValue("Atlas workspace");
    await name.fill("Unsaved workspace");
    await page.getByRole("button", { name: "Cancel changes", exact: true }).click();
    await expect(name).toHaveValue("Atlas workspace");
    await expect(page.locator("#settings-feedback")).toHaveCount(0);
    await expect(sections.getByRole("link", { name: "General", exact: true })).toHaveAttribute("aria-current", "page");
    const navBox = await sections.boundingBox();
    const panelBox = await page.locator(".design-settings-panel").boundingBox();
    expect(panelBox.x).toBeGreaterThan(navBox.x + navBox.width);
    await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
    await page.screenshot({ path: testInfo.outputPath(`settings-${theme}.png`), fullPage: true });
    await page.goBack();
    await expect(page).toHaveURL(/\/use-cases\/settings\/github$/);
    await expect(page.locator("#settings-section-title")).toHaveText("GitHub integration");
    await expect(page.getByRole("textbox", { name: "Repository", exact: true })).toHaveValue("invalid");
    await page.goForward();
    await expect(page).toHaveURL(/\/use-cases\/settings$/);
    await expect(name).toHaveValue("Atlas workspace");
    expect(errors).toEqual([]);
  });
}

test("Appearance follows the system, persists explicit modes and shares the home selector", async ({ page }, testInfo) => {
  const errors = captureErrors(page);
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/use-cases/settings/appearance");
  await connected(page);
  const modes = page.getByRole("group", { name: "Color mode", exact: true });
  await expect(modes.getByRole("button", { name: "Auto", exact: true })).toHaveAttribute("aria-pressed", "true");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await page.emulateMedia({ colorScheme: "light" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", "sunshine");
  await modes.getByRole("button", { name: "Dark", exact: true }).click();
  await page.reload();
  await connected(page);
  await expect(modes.getByRole("button", { name: "Dark", exact: true })).toHaveAttribute("aria-pressed", "true");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await modes.getByRole("button", { name: "Auto", exact: true }).focus();
  await page.keyboard.press("Enter");
  await expect.poll(() => page.evaluate(() => localStorage.getItem("theme"))).toBe("default");
  await page.goto("/hologram-demo");
  await expect(page.locator("#hologram-increment")).toBeEnabled();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "sunshine");
  await page.emulateMedia({ colorScheme: "dark" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await page.locator("#hologram-increment").click();
  await expect(page.locator("#hologram-count")).toHaveText("1");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await expect.poll(() => page.evaluate(() => localStorage.getItem("theme"))).toBe("default");
  await selectTheme(page, "sunshine");
  await page.locator("#hologram-increment").click();
  await expect(page.locator("#hologram-count")).toHaveText("2");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "sunshine");
  await page.goto("/");
  await connected(page);
  const switcher = page.locator('#home-page-header [phx-hook="ThemeSwitcher"]:visible');
  await selectTheme(page, "moonlight");
  await expect(switcher.locator('input[value="moonlight"]')).toBeChecked();
  await selectTheme(page, "sunshine");
  await expect(switcher.locator('input[value="sunshine"]')).toBeChecked();
  await switcher.locator("summary").click();
  const id = await switcher.locator('input[value="moonlight"]').getAttribute("id");
  await switcher.locator(`label[for="${id}"]`).click();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await page.goto("/use-cases/settings/appearance");
  await connected(page);
  await expect(modes.getByRole("button", { name: "Dark", exact: true })).toHaveAttribute("aria-pressed", "true");
  await expect(page.locator("#design-appbar [phx-hook='ThemeSwitcher']")).toHaveCount(0);
  await page.locator(".design-settings-panel").screenshot({ path: testInfo.outputPath("appearance-modes.png") });
  expect(errors).toEqual([]);
});

for (const path of ["/components", "/hologram-demo"]) {
  test(`sidebar preserves its width before the runtime loads on ${path}`, async ({ page }) => {
    const errors = captureErrors(page);
    await page.goto(path);
    if (path !== "/hologram-demo") await connected(page);
    const menu = page.locator("#design-left-menu");
    const toggle = menu.locator("[data-left-menu-toggle]");
    await expect(toggle).toHaveAccessibleName("Collapse navigation");
    await toggle.click();
    await expect(menu).toHaveCSS("width", "72px");

    let loadRuntime;
    const runtimeReady = new Promise(resolve => { loadRuntime = resolve; });
    await page.route("**/*", async route => {
      if (route.request().resourceType() === "script") await runtimeReady;
      await route.continue();
    });

    try {
      await page.reload({ waitUntil: "commit" });
      await expect(menu).toHaveCSS("width", "72px");
      await expect(toggle).toHaveAttribute("aria-expanded", "false");
      await expect(toggle).toHaveAccessibleName("Expand navigation");
    } finally {
      loadRuntime();
    }

    if (path !== "/hologram-demo") await connected(page);
    await expect(toggle).toBeEnabled();
    await expect(menu).toHaveCSS("width", "72px");
    await toggle.click();
    await expect(menu).toHaveCSS("width", "256px");
    await page.reload();
    await expect(toggle).toHaveAccessibleName("Collapse navigation");
    await expect(menu).toHaveCSS("width", "256px");
    expect(errors).toEqual([]);
  });
}

test("sidebar toggles when its preference storage is unavailable", async ({ page }) => {
  const errors = captureErrors(page);
  await page.addInitScript(() => {
    // Isolate sidebar persistence from LiveSocket's transport storage.
    const getItem = Storage.prototype.getItem;
    const setItem = Storage.prototype.setItem;
    Storage.prototype.getItem = function (key) {
      if (key === "gsmlg.navigation.collapsed") throw new Error("Preference storage unavailable");
      return getItem.call(this, key);
    };
    Storage.prototype.setItem = function (key, value) {
      if (key === "gsmlg.navigation.collapsed") throw new Error("Preference storage unavailable");
      return setItem.call(this, key, value);
    };
  });
  for (const path of ["/components", "/hologram-demo"]) {
    await page.goto(path);
    if (path !== "/hologram-demo") await connected(page);
    const menu = page.locator("#design-left-menu");
    await menu.getByRole("button", { name: "Collapse navigation" }).click();
    await expect(menu).toHaveAttribute("data-collapsed", "true");
    await menu.getByRole("button", { name: "Expand navigation" }).click();
    await expect(menu).toHaveAttribute("data-collapsed", "false");
  }
  expect(errors).toEqual([]);
});

test("contextual left menu reaches component topics and state demonstrations", async ({ page }) => {
  const errors = captureErrors(page);
  await page.goto("/components");
  await connected(page);
  await page.locator("#design-left-menu").getByRole("link", { name: "React", exact: true }).click();
  await expect(page).toHaveURL(/\/components\/react$/);
  await connected(page);
  await expect(page.locator("#design-left-menu a[aria-current='page']")).toHaveAccessibleName("React");
  await expect(page.locator("section#core, section#elements, section#phoenix")).toHaveCount(0);
  await expect(page.locator("#react-title")).toBeInViewport();
  await expect.poll(() => page.locator("#design-appbar").evaluate(el => Math.round(el.getBoundingClientRect().top))).toBe(0);
  await expect.poll(() => page.locator("#design-left-menu").evaluate(el => Math.round(el.getBoundingClientRect().top))).toBe(64);
  await page.getByRole("navigation", { name: "Main navigation", exact: true }).getByRole("link", { name: "Use Cases" }).click();
  await connected(page);
  await page.locator("#design-left-menu").getByRole("link", { name: "Session state", exact: true }).click();
  await connected(page);
  await expect(page.locator("#design-left-menu a[aria-current='page']")).toHaveText("Session state");
  await page.locator("#design-left-menu").getByRole("link", { name: "Browser-local state", exact: true }).click();
  await expect(page).toHaveURL(/\/hologram-demo$/);
  await expect(page.locator("#design-left-menu a[aria-current='page']")).toHaveText("Browser-local state");
  await page.locator("#design-left-menu").getByRole("link", { name: "Record browser", exact: true }).click();
  await expect(page).toHaveURL(/\/use-cases\/records$/);
  await connected(page);
  await expect(page.locator("#design-left-menu a[aria-current='page']")).toHaveText("Record browser");
  await expect(page.locator("section#workspace-settings, section#confirmation, section#progress")).toHaveCount(0);
  expect(errors).toEqual([]);
});

for (const [section, topics] of [
  ["guidelines", [
    ["Semantic colors", "/guidelines/colors", "#token-examples", "#design-specification"],
    ["Design specification", "/guidelines/specification", "#design-specification", "#token-examples"]
  ]],
  ["components", [
    ["Core CSS", "/components/core", "section#core", "section#elements, section#phoenix, section#react"],
    ["Web Components", "/components/elements", "section#elements", "section#core, section#phoenix, section#react"],
    ["Phoenix", "/components/phoenix", "section#phoenix", "section#core, section#elements, section#react"],
    ["React", "/components/react", "section#react", "section#core, section#elements, section#phoenix"]
  ]],
  ["use-cases", [
    ["Workspace settings", "/use-cases/workspace-settings", "section#workspace-settings", "section#record-browser, section#confirmation, section#progress"],
    ["Record browser", "/use-cases/records", "section#record-browser", "section#workspace-settings, section#confirmation, section#progress"],
    ["Confirmation", "/use-cases/confirmation", "section#confirmation", "section#workspace-settings, section#record-browser, section#progress"],
    ["Progress", "/use-cases/progress", "section#progress", "section#workspace-settings, section#record-browser, section#confirmation"]
  ]]
]) {
  test(`${section} sidebar topics support path routes, reload and history`, async ({ page }) => {
    const errors = captureErrors(page);
    await page.goto(`/${section}`);
    await connected(page);
    const menu = page.locator("#design-left-menu");
    const destinations = await menu.locator("a").evaluateAll(links => links.map(link => link.getAttribute("href")));
    expect(new Set(destinations).size).toBe(destinations.length);
    expect(destinations.every(path => path.startsWith("/") && !/[#?]/.test(path))).toBe(true);

    const assertTopic = async ([label, path, present, absent]) => {
      await expect.poll(() => new URL(page.url()).pathname).toBe(path);
      expect(new URL(page.url()).hash).toBe("");
      expect(new URL(page.url()).search).toBe("");
      await connected(page);
      await expect(menu.locator("a[aria-current='page']")).toHaveAccessibleName(label);
      await expect(page).toHaveTitle(new RegExp(label));
      await expect(page.locator(present)).toBeVisible();
      await expect(page.locator(absent)).toHaveCount(0);
      await expect(page.locator("#design-appbar a[aria-current='page']")).toHaveAttribute("href", `/${section}`);
    };

    for (const topic of topics) {
      await menu.getByRole("link", { name: topic[0], exact: true }).click();
      await assertTopic(topic);
      const title = await page.title();
      await page.reload();
      await assertTopic(topic);
      await expect(page).toHaveTitle(title);
    }
    await page.goBack();
    await assertTopic(topics.at(-2));
    await page.goForward();
    await assertTopic(topics.at(-1));
    expect(errors).toEqual([]);
  });
}

test("settings path routes open directly and replace legacy section bookmarks", async ({ page }) => {
  const sectionsToVisit = [
    ["general", "", "General"],
    ["github", "/github", "GitHub integration"],
    ["appearance", "/appearance", "Appearance"],
    ["unknown", "", "General"]
  ];
  const errors = captureErrors(page, sectionsToVisit.map(([section]) => `/use-cases/settings?section=${section}`));
  const sections = page.getByRole("navigation", { name: "Workspace settings sections" });
  for (const [section, suffix, title] of sectionsToVisit) {
    const path = `/use-cases/settings${suffix}`;
    const redirectResponse = page.waitForResponse(response => response.url().endsWith(`/use-cases/settings?section=${section}`));
    await page.goto(`/use-cases/settings?section=${section}`);
    const redirect = await redirectResponse;
    expect(redirect.status()).toBe(302);
    expect(new URL(redirect.headers().location, page.url()).pathname).toBe(path);
    await expect.poll(() => `${new URL(page.url()).pathname}${new URL(page.url()).search}`).toBe(path);
    await connected(page);
    await expect(page.locator("#settings-section-title")).toHaveText(title);
    await expect(sections.locator("a[aria-current='page']")).toHaveAttribute("href", path);
    await page.reload();
    await connected(page);
    await expect(page.locator("#settings-section-title")).toHaveText(title);
    expect(await sections.locator("a").evaluateAll(links => links.every(link => !/[#?]/.test(link.getAttribute("href"))))).toBe(true);
  }
  expect(errors).toEqual([]);
});

test("home PageHeader reveals floating navigation after the hero and supports themes", async ({ page }) => {
  const errors = captureErrors(page);
  await page.goto("/");
  await connected(page);
  const floating = page.locator("#home-page-navigation");
  await expect(floating).toBeHidden();
  await expect(page.locator("#home-page-header h1")).toBeVisible();
  const switcher = page.locator('#home-page-header [phx-hook="ThemeSwitcher"]:visible');
  await switcher.locator("summary").click();
  const id = await switcher.locator('input[value="moonlight"]').getAttribute("id");
  await switcher.locator(`label[for="${id}"]`).click();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await page.locator("h1").click();
  await page.locator("#repositories-title").scrollIntoViewIfNeeded();
  await expect(floating).toBeVisible();
  await expect(floating).toHaveAttribute("aria-hidden", "false");
  await floating.getByRole("link", { name: "Components", exact: true }).click();
  await expect(page).toHaveURL(/\/components$/);
  await connected(page);
  await expect(page.locator("#design-appbar")).toBeVisible();
  await expect(page.locator("#design-left-menu")).toBeVisible();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  expect(errors).toEqual([]);
});
