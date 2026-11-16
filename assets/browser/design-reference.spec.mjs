import { test, expect } from "@playwright/test";
import { readFile } from "node:fs/promises";
import { createHash } from "node:crypto";

const connected = page => expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
const action = (page, id) => page.locator(`#${id}`).getByRole("button");

function captureErrors(page) {
  const errors = [];
  page.on("pageerror", error => errors.push(error.message));
  page.on("console", message => { if (message.type() === "error") errors.push(message.text()); });
  page.on("response", response => {
    if (["document", "stylesheet", "script"].includes(response.request().resourceType()) &&
        !response.ok() && response.status() !== 304) errors.push(`${response.status()} ${response.url()}`);
  });
  return errors;
}

async function selectTheme(page, theme) {
  const switcher = page.locator('[phx-hook="ThemeSwitcher"]');
  await switcher.locator("summary").click();
  const id = await switcher.locator(`input[value="${theme}"]`).getAttribute("id");
  await switcher.locator(`label[for="${id}"]`).click();
  await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
  await page.locator("h1").click();
  await connected(page);
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
    for (const path of ["/", "/guidelines", "/components", "/use-cases", "/use-cases/session", "/hologram-demo"]) {
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
          return [...el.querySelectorAll('a:not([aria-current="page"])')]
            .every(link => getComputedStyle(link).color === expected);
        })).toBe(true);
        const barBox = await appbar.boundingBox();
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

test("contextual left menu reaches component topics and state demonstrations", async ({ page }) => {
  const errors = captureErrors(page);
  await page.goto("/components");
  await connected(page);
  await page.locator("#design-left-menu").getByRole("link", { name: "React", exact: true }).click();
  await expect(page).toHaveURL(/\/components#react$/);
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
