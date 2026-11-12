import { test, expect } from "@playwright/test";

test("desktop document, assets and LiveView work without browser errors", async ({ page }) => {
  const errors = [];
  const assets = [];
  page.on("pageerror", error => errors.push(error.message));
  page.on("console", message => { if (message.type() === "error") errors.push(message.text()); });
  page.on("response", response => {
    if (["stylesheet", "script"].includes(response.request().resourceType())) assets.push(response);
  });
  const response = await page.goto("/");
  expect(response.ok()).toBeTruthy();
  await expect(page.locator("#counter")).toHaveText("0");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("1");
  for (let count = 2; count <= 5; count++) {
    await page.locator("#increment").click();
    await expect(page.locator("#counter")).toHaveText(String(count));
  }
  await page.reload();
  await expect(page.locator("#counter")).toHaveText("5");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await page.locator("#reset").click();
  await expect(page.locator("#counter")).toHaveText("0");
  expect(assets.some(response => response.request().resourceType() === "stylesheet")).toBeTruthy();
  expect(assets.some(response => response.request().resourceType() === "script")).toBeTruthy();
  expect(assets.filter(response => !response.ok()).map(response => response.url())).toEqual([]);
  expect(errors).toEqual([]);
});

test("session counter is shared across tabs but isolated across browser contexts", async ({ page, context, browser }) => {
  await page.goto("/");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("1");
  const tab = await context.newPage();
  await tab.goto("/");
  await expect(tab.locator("#counter")).toHaveText("1");
  await expect.poll(() => tab.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await tab.locator("#increment").click();
  await expect(tab.locator("#counter")).toHaveText("2");
  await expect(page.locator("#counter")).toHaveText("2");
  const isolated = await browser.newContext();
  try {
    const other = await isolated.newPage();
    await other.goto(new URL("/", page.url()).href);
    await expect(other.locator("#counter")).toHaveText("0");
  } finally { await isolated.close(); }
});

test("Hologram runtime executes client-side actions and inherits theme", async ({ page, context }) => {
  const errors = [];
  const assets = [];
  page.on("pageerror", error => errors.push(error.message));
  page.on("response", response => {
    if (["stylesheet", "script"].includes(response.request().resourceType())) assets.push(response);
  });
  await page.goto("/");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  // ThemeSwitcher button selectors require verification against the installed UI package.
  await page.evaluate(() => document.documentElement.setAttribute("data-theme", "moonlight"));
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await expect.poll(async () => (await context.cookies()).find(cookie => cookie.name === "gsmlg_theme")?.value).toBe("moonlight");
  await page.goto("/hologram-demo");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "moonlight");
  await expect(page.locator("#hologram-count")).toHaveText("0");
  // Complete a client-side action before going offline, rather than racing
  // runtime initialization or relying only on server-rendered markup.
  await page.locator("#hologram-increment").click();
  await expect(page.locator("#hologram-count")).toHaveText("1");
  await context.setOffline(true);
  try {
    await page.locator("#hologram-increment").click();
    await expect(page.locator("#hologram-count")).toHaveText("2");
    await page.locator("#hologram-reset").click();
    await expect(page.locator("#hologram-count")).toHaveText("0");
  } finally { await context.setOffline(false); }
  expect(assets.filter(response => !response.ok()).map(response => response.url())).toEqual([]);
  expect(errors).toEqual([]);
});

test("LiveView reconnects without losing session state", async ({ page, context }) => {
  test.setTimeout(90000);
  await page.goto("/");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("1");
  await context.setOffline(true);
  try {
    await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected()), { timeout: 45000 }).toBe(false);
  } finally { await context.setOffline(false); }
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected()), { timeout: 20000 }).toBe(true);
  await expect(page.locator("#counter")).toHaveText("1");
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("2");
});

test("navigation between renderers and browser history preserve LiveView state", async ({ page }) => {
  await page.goto("/");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("1");
  await page.locator("#hologram-demo-link").click();
  await expect(page.locator("#hologram-count")).toHaveText("0");
  await page.goBack();
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected())).toBe(true);
  await expect(page.locator("#counter")).toHaveText("1");
  await page.goForward();
  await expect(page.locator("#hologram-count")).toHaveText("0");
});


test("both page renderers serve security headers and sans-serif styling", async ({ page }) => {
  const errors = [];
  page.on("pageerror", error => errors.push(error.message));
  page.on("console", message => { if (message.type() === "error") errors.push(message.text()); });
  for (const path of ["/", "/hologram-demo"]) {
    const response = await page.goto(path);
    expect(response.ok()).toBeTruthy();
    const headers = response.headers();
    expect(headers["x-frame-options"].toUpperCase()).toBe("SAMEORIGIN");
    expect(headers["x-content-type-options"]).toBe("nosniff");
    expect(headers["referrer-policy"]).toBeTruthy();
    await expect.poll(() => page.locator("body").evaluate(el => getComputedStyle(el).fontFamily)).toMatch(/sans-serif/);
  }
  expect(errors).toEqual([]);
});

test("LiveView falls back to longpoll when WebSocket transport is closed", async ({ page }) => {
  await page.routeWebSocket("**/live/websocket**", socket => socket.close());
  const polling = [];
  page.on("response", response => {
    if (new URL(response.url()).pathname === "/live/longpoll") polling.push(response);
  });
  await page.goto("/");
  await expect.poll(() => page.evaluate(() => window.liveSocket?.isConnected()), { timeout: 20000 }).toBe(true);
  await expect.poll(() => polling.some(response => response.ok()), { timeout: 20000 }).toBe(true);
  await page.locator("#increment").click();
  await expect(page.locator("#counter")).toHaveText("1");
});
