---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use when the user asks to build web components, pages, landing pages, dashboards, React components, HTML/CSS layouts, or when styling and beautifying any web UI. Guides creative, polished code and UI design that avoids generic aesthetics. Trigger when user mentions building UI, creating web pages, designing components, or improving visual design.
---

# Frontend Design

## When to use
Use this skill when asked to build any frontend interface — web pages, components, dashboards, landing pages, or when improving the visual design of an existing UI.

## ⚠️ Command Safety
This skill generates code and markup. Only run dev servers (`npm run dev`, `pnpm dev`) for preview. Never run deploy commands without user approval.

## Design Thinking

Before coding, commit to a clear aesthetic direction:

1. **Purpose**: What problem does this interface solve? Who uses it?
2. **Tone**: Pick a specific aesthetic — minimal, editorial, brutalist, retro-futuristic, luxury, playful, industrial, organic, art deco, soft/pastel
3. **Constraints**: Framework (React, Vue, vanilla), performance, accessibility
4. **Memorable element**: What's the ONE thing someone will remember about this design?

## Stack Detection

| Signal | Stack | Approach |
|--------|-------|----------|
| `package.json` + `next` | Next.js | App Router, Server Components, `use client` where needed |
| `package.json` + `react` | React (Vite) | Components with hooks |
| `package.json` + `vue` | Vue | Composition API |
| No `package.json` | Vanilla | HTML + CSS + JS |

Check the **nodejs-expert** skill for framework-specific patterns.

## Aesthetics Guidelines

### Typography
- **Never use**: Arial, Helvetica, Times New Roman, system defaults
- **Choose distinctive fonts**: Pair a display font with a refined body font
- Use Google Fonts: `@import url('https://fonts.googleapis.com/css2?family=...')`
- Set proper hierarchy: headings, body, captions, labels

### Color & Theme
- Use CSS custom properties for consistency
- Dominant color with sharp accents (not evenly distributed)
- Commit to light OR dark — design for it intentionally
- Use HSL for color manipulation: `hsl(220, 80%, 50%)`

```css
:root {
  --color-bg: hsl(220, 15%, 8%);
  --color-surface: hsl(220, 15%, 12%);
  --color-text: hsl(220, 10%, 92%);
  --color-accent: hsl(160, 90%, 50%);
  --color-muted: hsl(220, 10%, 50%);
  --radius: 12px;
  --transition: 200ms ease;
}
```

### Motion & Animation
- Use CSS transitions for hover/focus states
- Staggered reveals on page load (`animation-delay`)
- Keep animations under 300ms for interactions, up to 800ms for page transitions
- Prefer CSS animations over JS for performance

```css
.card {
  opacity: 0;
  transform: translateY(20px);
  animation: fadeUp 0.5s ease forwards;
}

@keyframes fadeUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### Layout
- Use CSS Grid for page layouts, Flexbox for component layouts
- Try asymmetric layouts, overlapping elements, broken grids
- Generous whitespace OR controlled density — avoid the middle ground

### Visual Details
- Background textures: noise, gradients, subtle patterns
- Glassmorphism: `backdrop-filter: blur(10px)` with semi-transparent backgrounds
- Shadows with color: `box-shadow: 0 8px 32px hsl(220 80% 50% / 0.2)`
- Border effects: gradient borders, glow effects

## Component Patterns

### Card
```css
.card {
  background: var(--color-surface);
  border: 1px solid hsl(220 15% 20%);
  border-radius: var(--radius);
  padding: 2rem;
  transition: transform var(--transition), box-shadow var(--transition);
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px hsl(0 0% 0% / 0.3);
}
```

### Button
```css
.btn-primary {
  background: var(--color-accent);
  color: var(--color-bg);
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition);
}

.btn-primary:hover {
  filter: brightness(1.1);
  transform: translateY(-1px);
}
```

## Anti-Patterns (avoid these)

- ❌ Default browser styles with no customization
- ❌ Generic color schemes (especially purple gradients on white)
- ❌ Using only system fonts or overused fonts (Inter, Roboto everywhere)
- ❌ Cookie-cutter Bootstrap/Tailwind defaults with no personality
- ❌ Placeholder images with no alt text
- ❌ Forms with no clear visual hierarchy

## Accessibility Baseline

- Color contrast ratio ≥ 4.5:1 for text, ≥ 3:1 for large text
- Interactive elements need focus styles (`:focus-visible`)
- Use semantic HTML (`nav`, `main`, `article`, `button`)
- Images need `alt` text
- Forms need associated `label` elements

## Gotchas

- **Test responsive.** Always check mobile view. Use `clamp()` for fluid typography.
- **Performance.** Heavy animations + large images = slow. Optimize images, use `will-change` sparingly.
- **Accessibility.** Beautiful design that's unusable is not good design.
- **Dark mode.** If using dark mode, ensure all text is readable and images work on dark backgrounds.
