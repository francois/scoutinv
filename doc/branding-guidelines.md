# Scoutinv Brand Identity Guidelines

## Purpose

This document defines Scoutinv's proposed brand identity. It is the reference for anyone designing or implementing the interface, marketing site, email, and product documents.

These guidelines are self-contained. The signed-in application should reuse this system without turning every screen into a newspaper page.

## Core idea

Scoutinv is not an abstract “inventory management” product. It helps a group retain the memory of its equipment: what leaves for an adventure, what returns, what needs checking or repair, and what the next equipment volunteers need to know.

The identity should convey:

- the calm confidence of a well-kept notebook;
- the field and the real life of equipment;
- continuity between volunteers;
- care for shared objects;
- open-source software that is clear and trustworthy.

It must not feel like an aggressive SaaS startup, a military tool, or a generic camping application.

## Editorial voice

Prefer concrete, human facts: a tent, a door, an outing, a return, a person taking over. The benefit should emerge from the situation rather than from an abstract marketing promise.

Prefer:

- “Your equipment goes on adventures. Keep track of its return.”
- “Sarah hands the equipment over to Martin.”
- “A problem was reported with the tent door.”
- “Prepare. Leave. Return.”

Avoid:

- “Optimize your inventory flows.”
- “The all-in-one platform that revolutionizes your logistics.”
- inflated quantities or screenshots that claim to represent the actual product.

Serial numbers are real identifiers: `MJ9`, `N8C`, and `D81` identify one specific item among several otherwise similar objects. Write them as concrete data, never as decorative codes.

## Colour palette

Use semantic names in code rather than colour names.

| Token | Value | Role | Intended feeling |
| --- | --- | --- | --- |
| `--paper` | `#f5eee2` | Main background | Paper, archive, warmth, longevity |
| `--surface` | `#fffdf8` | Cards and raised backgrounds | Clean, readable, breathable page |
| `--ink` | `#263a56` | Text, rules, structure | Newspaper ink, precision, trust |
| `--action` | `#bd513e` | Primary action and occasional accent | Terracotta, human gesture, action |
| `--sage` | `#b8d3be` | Calm status, equipment sheet, secondary background | Maintenance, attention, living equipment |
| `--field` | `#639078` | Illustration and mid-green accent | Field, outdoors, real use |
| `--forest` | `#192d28` | Dark panels and contrast | Solidity, workshop, reliability |

Rules:

- `--ink` replaces pure black for text and rules. Do not add decorative `#000`.
- `--action` is rare and intentional: the primary CTA, a small brand accent, or a state that needs attention. It must not become a second dominant background.
- The greens are not three competing CTA colours. They communicate field work, state, and maintenance.
- Keep `--paper` as the dominant background and `--surface` as gentle contrast; the interface must not become a mosaic of coloured panels.
- Test every foreground/background combination for WCAG AA contrast before shipping.

## Typography

Limit the final system to three families.

| Family | Use | Why |
| --- | --- | --- |
| Newsreader | Editorial and major section headings | A contemporary, human, memorable newspaper voice |
| DM Sans | Interface, navigation, body text, fields, and buttons | Clear, warm reading without a technocratic feel |
| DM Mono | Metadata and technical markers | Recalls physical labels, serial numbers, and equipment sheets |

### Scale and styles

| Use | Family / weight | Target size | Leading / spacing |
| --- | --- | --- | --- |
| Marketing manifesto title | Newsreader 600 | `clamp(3rem, 7vw, 6.6rem)` | `0.9–0.95`, tracking `-0.05em` to `-0.065em` |
| Application H1 | Newsreader 600 | 2.5–3.25 rem | 1.0 |
| Section H2 | Newsreader 600 | 2–3 rem | 0.95–1.0 |
| H3 / card title | DM Sans 700 | 1.1–1.4 rem | 1.15 |
| Body text | DM Sans 400 | 1 rem / 16 px | 1.45–1.6 |
| Button | DM Sans 700 | 0.875–1 rem | 1 |
| Actual form `<label>` | DM Sans 600 | 0.875 rem | normal |
| Editorial eyebrow, serial number, state, date | DM Mono 400 or 500 | 0.66–0.75 rem | optional capitals, `0.05–0.08em` |

Monospace is not for long text or actual form labels. It makes a data point instantly scannable: `S/N · MJ9`, `UNDER REPAIR`, a date, or a location.

### Font loading

DM Sans, DM Mono, and Newsreader are not reliable system fonts. Host them in Scoutinv's assets with `@font-face`; do not depend on Google Fonts in production. Use these fallbacks:

```css
font-family: "Newsreader", Georgia, serif;
font-family: "DM Sans", system-ui, sans-serif;
font-family: "DM Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
```

Declare `font-display: swap` and include the weights actually used: Newsreader 600, DM Sans 400/600/700, and DM Mono 400/500.

## Logo and graphic marks

The proposed wordmark is `Scoutinv`:

- “Scout” uses `--forest` or `--ink`;
- “inv” uses `--action`;
- DM Sans 800 with slightly tight tracking;
- do not add a compass, tent, or fleur-de-lis icon by default.

For production, create a final logo SVG rather than recreating the wordmark in HTML in every view.

## Motifs and imagery

Useful motifs are editorial: fine rules, newspaper double rules, columns, sheet labels, and large serial numbers. They must support information, never become decorative noise.

Images should show an object, its use, or its real condition: an identified tent, a zipper, an axe, a stove, or a storage shelf. Avoid generic stock photos of smiling young people around a fire: they do not explain what Scoutinv does.

## Interface principles

- Readability takes precedence over editorial flourish on working screens.
- Use Newsreader to give important titles personality, not for tables, forms, or repeated actions.
- Name actions with verbs: “Register my group”, “Send”, “Mark for repair”, “Confirm return”.
- Keep equipment state and serial number close together; users should not need to open a detail page to identify an item.
- On mobile, turn columns into a vertical sequence with clear separators.

## Implementation direction

Build the final system from semantic design tokens and reusable components. Do not encode visual directions as numbered page classes; production CSS should expose intentional tokens, typography styles, and component classes instead.
