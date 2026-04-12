---
name: webapp-testing
description: Use when testing web applications with Playwright for browser automation, screenshot capture, DOM inspection, and interactive testing. Verifies frontend functionality, debugs UI behavior, tests user flows, and performs end-to-end testing.
---

# Web Application Testing

## When to use
Use this skill when asked to test a web application, verify UI functionality, capture screenshots, debug browser behavior, or write E2E tests.

## ⚠️ Command Safety
This skill runs test and inspection commands only. Never run deploy commands. Playwright runs in headless mode by default (safe, no visible browser window).

## Decision Tree

```
User task → Is the app already running?
    ├─ Yes → Navigate, inspect, test
    │
    └─ No → Is it static HTML?
        ├─ Yes → Open file directly (file:// URL)
        └─ No → Start dev server first, then test
```

## Quick Start

### Install Playwright
```bash
# Node.js
pnpm add -D @playwright/test
npx playwright install chromium

# Python
pip install playwright
playwright install chromium
```

### Basic Test (Python)
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("http://localhost:3000")
    page.wait_for_load_state("networkidle")  # Wait for JS to finish

    # Take screenshot
    page.screenshot(path="screenshot.png", full_page=True)

    # Inspect DOM
    title = page.title()
    buttons = page.locator("button").all()
    print(f"Title: {title}, Buttons: {len(buttons)}")

    browser.close()
```

### Basic Test (TypeScript / Playwright Test)
```typescript
import { test, expect } from "@playwright/test";

test("homepage loads correctly", async ({ page }) => {
  await page.goto("http://localhost:3000");
  await expect(page).toHaveTitle(/My App/);
  await expect(page.locator("h1")).toBeVisible();
});

test("login flow works", async ({ page }) => {
  await page.goto("http://localhost:3000/login");

  await page.fill('[name="email"]', "test@example.com");
  await page.fill('[name="password"]', "password123");
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL(/dashboard/);
  await expect(page.locator("text=Welcome")).toBeVisible();
});
```

## Reconnaissance Pattern

When you don't know the app's structure, inspect first:

```python
# Step 1: Navigate and wait
page.goto("http://localhost:3000")
page.wait_for_load_state("networkidle")

# Step 2: Screenshot for visual inspection
page.screenshot(path="inspect.png", full_page=True)

# Step 3: Discover elements
content = page.content()            # Full HTML
links = page.locator("a").all()     # All links
buttons = page.locator("button").all()  # All buttons
inputs = page.locator("input").all()    # All inputs

for link in links:
    print(f"Link: {link.text_content()} → {link.get_attribute('href')}")

# Step 4: Use discovered selectors for actions
page.click("text=Sign In")
```

## Common Actions

```python
# Click
page.click("text=Submit")
page.click("#submit-btn")
page.click('button:has-text("Save")')

# Fill form
page.fill('[name="email"]', "user@example.com")
page.fill('[placeholder="Search..."]', "query")

# Select dropdown
page.select_option("select#country", "US")

# Check/uncheck
page.check("#agree-terms")

# Wait for element
page.wait_for_selector(".results", timeout=5000)

# Get text content
text = page.locator(".status").text_content()

# Check visibility
is_visible = page.locator(".error").is_visible()

# screenshot specific element
page.locator(".chart").screenshot(path="chart.png")
```

## Capture Console Logs

```python
# Listen for console messages
page.on("console", lambda msg: print(f"[{msg.type}] {msg.text}"))

# Listen for errors
page.on("pageerror", lambda err: print(f"Page error: {err}"))

page.goto("http://localhost:3000")
page.wait_for_load_state("networkidle")
```

## Playwright Config (for test suites)

```typescript
// playwright.config.ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",
  timeout: 30_000,
  retries: 1,
  use: {
    baseURL: "http://localhost:3000",
    headless: true,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
  },
  webServer: {
    command: "pnpm dev",
    port: 3000,
    reuseExistingServer: true,
  },
});
```

## Common Pitfalls

- ❌ Inspecting DOM before `networkidle` on SPAs (incomplete DOM)
- ❌ Using fixed `sleep()` / `wait_for_timeout()` instead of proper waits
- ❌ Not closing the browser (leaks processes)
- ❌ Hardcoding localhost URLs that change between environments

- ✅ Always `wait_for_load_state("networkidle")` for dynamic apps
- ✅ Use `wait_for_selector()` for specific elements
- ✅ Always `browser.close()` in a `finally` block or `with` statement
- ✅ Use `baseURL` in config for environment portability

## Gotchas

- **headless: true is required** in CI and most server environments (no display).
- **networkidle waits for 500ms of no network activity** — may not work for apps with persistent WebSocket or polling connections. Use `wait_for_selector` instead.
- **Playwright auto-waits** before actions (click, fill) — you usually don't need explicit waits for elements.
- **Use `page.locator()` over `page.$()`** — locators auto-retry and are more reliable.

## Integration

- **Before this skill:** frontend-design
- **After this skill:** code-review
- **Complementary skills:** test-writer, test-driven-development
