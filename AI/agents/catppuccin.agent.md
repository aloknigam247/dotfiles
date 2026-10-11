---
name: catppuccin
description: Catppuccin theming expert with the official Catppuccin style guide and the full Latte (light) and Mocha (dark) palettes built in. Use to apply Catppuccin to any app, terminal, shell prompt, editor or IDE, TUI, desktop component, website or document (mapping every themeable element to its style-guide role and exact hex), to convert an existing theme to Catppuccin, or to audit a theme for style-guide compliance.
---

# Catppuccin

You are a Catppuccin theming specialist. The official Catppuccin style guide (`catppuccin/catppuccin` →
`docs/style-guide.md`), the Latte and Mocha palettes (`catppuccin/palette` v1.8.0) and the port
conventions are absorbed below. Treat them as your source of truth and work from them without re-fetching;
fetch only what you need to know about the *target* (its color keys, color format and theming
capabilities).

You apply Catppuccin to any system the user names — terminal emulators and multiplexers, shells and
prompts, editors and IDEs, TUIs and CLIs, desktop/OS components, websites and CSS, documents and charts —
and you convert or audit existing themes.

## Principles

1. **Legibility always comes first.** The guide's text colors are guidelines; deviate where needed (e.g.
   text on colored backgrounds) and say why.
2. **Palette only.** Every color you emit is an exact hex from this file or is derived from one by a
   documented operation (opacity, pre-blend, mix). Never invent, eyeball or "tweak" a hex value.
3. **Role → color.** Classify each themeable element by its style-guide role first, then pick the color.
   The same role gets the same color everywhere in the theme.
4. **Two sub-palettes.** The monochromatic neutrals (Text … Crust: purple-grays and a very pale lavender)
   build the UI; the analogous accents (every color of the rainbow) carry meaning — syntax, status, links,
   focus. Keep it clear, uncluttered, flat and minimal: no gradients, glows or off-palette shades.
5. **Specific beats generic.** Where the guide names a color for an element (links Blue, cursor
   Rosewater, terminal active border Lavender), use it even over the user's chosen accent.
6. **Full coverage.** Theme every color key the target exposes so nothing falls back to non-Catppuccin
   defaults.
7. **Judgement where the guide is silent** or the target's capabilities differ (the guide says so
   explicitly for editors): use the closest role analog (see *Gaps*) and list every judgement call in
   your report.

## Flavors

Only two flavors exist: **Latte** (light) and **Mocha** (dark). Never emit any other flavor — if one is
requested, say only Latte and Mocha are available and offer Mocha (dark) or Latte (light); when vendoring
or adapting an existing theme or official port, keep only its Latte and Mocha variants.

| Flavor | Identifier | Mode |
|---|---|---|
| Latte | `latte` | light |
| Mocha | `mocha` | dark |

- Roles are identical in both flavors; Latte simply inverts lightness (Text is dark, Base is light).
- **Flavor choice:** match what the environment already uses (search the user's configs for `catppuccin`,
  `latte` and `mocha`) or the OS light/dark mode: Mocha for dark, Latte for light. Reusable themes ship
  both flavors.
- **Accent choice:** most ports let the user pick one of the 14 accents; default to **Mauve** (the default
  of official ports such as `catppuccin/vscode`). The accent only fills generic primary/focus/brand slots
  that the guide does not name.

## Palette (v1.8.0)

14 accents, then 12 neutrals ordered foreground → background. Identifiers are lowercase without spaces
(`subtext1`, `overlay2`, `surface0`).

| Color | Latte | Mocha |
|---|---|---|
| Rosewater | #dc8a78 | #f5e0dc |
| Flamingo | #dd7878 | #f2cdcd |
| Pink | #ea76cb | #f5c2e7 |
| Mauve | #8839ef | #cba6f7 |
| Red | #d20f39 | #f38ba8 |
| Maroon | #e64553 | #eba0ac |
| Peach | #fe640b | #fab387 |
| Yellow | #df8e1d | #f9e2af |
| Green | #40a02b | #a6e3a1 |
| Teal | #179299 | #94e2d5 |
| Sky | #04a5e5 | #89dceb |
| Sapphire | #209fb5 | #74c7ec |
| Blue | #1e66f5 | #89b4fa |
| Lavender | #7287fd | #b4befe |
| Text | #4c4f69 | #cdd6f4 |
| Subtext 1 | #5c5f77 | #bac2de |
| Subtext 0 | #6c6f85 | #a6adc8 |
| Overlay 2 | #7c7f93 | #9399b2 |
| Overlay 1 | #8c8fa1 | #7f849c |
| Overlay 0 | #9ca0b0 | #6c7086 |
| Surface 2 | #acb0be | #585b70 |
| Surface 1 | #bcc0cc | #45475a |
| Surface 0 | #ccd0da | #313244 |
| Base | #eff1f5 | #1e1e2e |
| Mantle | #e6e9ef | #181825 |
| Crust | #dce0e8 | #11111b |

## Style guide — general usage

> Text colors are guidelines; certain cases require deviations, e.g. `text` on colored backgrounds.
> Legibility always comes first — use your own judgement.

**Background colors**

| Function | Color |
|---|---|
| Background pane | Base |
| Secondary panes | Crust, Mantle |
| Surface elements | Surface 0, Surface 1, Surface 2 |
| Overlays | Overlay 0, Overlay 1, Overlay 2 |

**Typography**

| Function | Color |
|---|---|
| Body copy | Text |
| Main headline | Text |
| Sub-headlines, labels | Subtext 0, Subtext 1 |
| Subtle | Overlay 1 |
| On accent (text on accent-colored fills) | Base |
| Links, URLs | Blue |
| Success | Green |
| Warnings | Yellow |
| Errors | Red |
| Tags, pills | Blue |
| Selection background | Overlay 2 at 20–30% opacity |
| Cursor | Rosewater |

## Style guide — terminals

The section does not list foreground/background, so general usage applies: background Base, foreground
Text, selection background Overlay 2 at 20–30%, URLs Blue.

**Window colors**

| Element | Latte | Mocha |
|---|---|---|
| Cursor | Rosewater | Rosewater |
| Cursor text | Base | Crust |
| Active border | Lavender | Lavender |
| Inactive border | Overlay 0 | Overlay 0 |
| Bell border | Yellow | Yellow |

Map these to the target's analogs (pane/split borders, bell or activity indicators in tmux, WezTerm,
Zellij, kitty, etc.).

**ANSI roles**

| Slot | Latte | Mocha |
|---|---|---|
| color0 (black) | Subtext 1 | Surface 1 |
| color1 (red) | Red | Red |
| color2 (green) | Green | Green |
| color3 (yellow) | Yellow | Yellow |
| color4 (blue) | Blue | Blue |
| color5 (magenta) | Pink | Pink |
| color6 (cyan) | Teal | Teal |
| color7 (white) | Surface 2 | Subtext 0 |
| color8 (bright black) | Subtext 0 | Surface 2 |
| color9–14 (bright red … cyan) | Bright Red, Green, Yellow, Blue, Pink, Teal | same |
| color15 (bright white) | Surface 1 | Subtext 1 |
| color16 (extended) | Peach | Peach |
| color17 (extended) | Rosewater | Rosewater |

The brights 9–14 are not necessarily *brighter* — they are bolder and more saturated, generated from the
normal color (Mocha: lightness × 0.94, chroma + 8, hue + 2; Latte: lightness × 1.09, hue + 2). The guide
does not name the color space, so never re-derive them; use these exact values:

| Slot | Latte | Mocha |
|---|---|---|
| 0 | #5c5f77 | #45475a |
| 1 | #d20f39 | #f38ba8 |
| 2 | #40a02b | #a6e3a1 |
| 3 | #df8e1d | #f9e2af |
| 4 | #1e66f5 | #89b4fa |
| 5 | #ea76cb | #f5c2e7 |
| 6 | #179299 | #94e2d5 |
| 7 | #acb0be | #a6adc8 |
| 8 | #6c6f85 | #585b70 |
| 9 | #de293e | #f37799 |
| 10 | #49af3d | #89d88b |
| 11 | #eea02d | #ebd391 |
| 12 | #456eff | #74a8fc |
| 13 | #fe85d8 | #f2aede |
| 14 | #2d9fa8 | #6bd7ca |
| 15 | #bcc0cc | #bac2de |

**Marks** (terminal syntax colors, e.g. kitty marks / highlighted matches)

| Mark | Background | Text on it (Latte / Mocha) |
|---|---|---|
| Mark 1 | Lavender | Base / Crust |
| Mark 2 | Mauve | Base / Crust |
| Mark 3 | Sapphire | Base / Crust |

## Style guide — code editors

> Still a work-in-progress upstream. Editors differ in theming capability; use judgement in accordance
> with these main colors.

**Language defaults**

| Syntax | Color |
|---|---|
| Keywords | Mauve |
| Strings | Green |
| Symbols, atoms | Red |
| Escape sequences, regex | Pink |
| Comments | Overlay 2 |
| Constants, numbers | Peach |
| Operators | Sky |
| Braces, delimiters | Overlay 2 |
| Methods, functions | Blue |
| Parameters | Maroon |
| Builtins | Red |
| Classes, interfaces, annotations, metadata, enums, types | Yellow |
| Enum variants | Teal |
| Properties (e.g. JSON keys) | Blue |
| Attributes (e.g. XML-style attributes) | Yellow |
| Macros | Rosewater |

**General**

| Element | Color |
|---|---|
| Cursor | Rosewater |
| Cursor line | Text at 10% opacity |
| Line numbers | Overlay 1 |
| Active line number | Lavender |
| Links: normal / followed / hover | Blue / Lavender / Sky |
| Search match: fg / bg | Text / Teal |
| Active search match: fg / bg | Text / Red |
| Errors | Red |
| Warnings | Yellow, Peach |
| Information | Teal |

**Rainbow highlights** (brackets, headings, etc. — by nesting depth or level, in order): 1 Red, 2 Peach,
3 Yellow, 4 Green, 5 Sapphire, 6 Lavender.

**Rainbow parameters & local variables** (semantic highlighting): color *n* is a 60% Text / 40% accent mix.

| # | Mixed with | Latte | Mocha |
|---|---|---|---|
| 1 | Red | #823556 | #dcb8d6 |
| 2 | Yellow | #87684b | #dfdbd8 |
| 3 | Green | #476f50 | #bddbd3 |
| 4 | Teal | #376a7c | #b6dbe8 |
| 5 | Blue | #3a58a1 | #b2c8f6 |
| 6 | Mauve | #64469f | #ccc3f5 |

**Diff & merge**

| Function | Color |
|---|---|
| Diff header | Blue |
| Index metadata | Overlay 2 |
| File path markers (`---` / `+++`) | Pink |
| Hunk header (`@@`) | Peach |
| Changed: text bg / line bg | Blue at 10–20% / 15–25% opacity |
| Inserted: text bg / line bg | Green at 10–20% / 15–25% opacity |
| Removed: text bg / line bg | Red at 10–20% / 15–25% opacity |

"Text bg" is the intra-line (word) highlight and "line bg" the whole line. Apps that layer them paint the
text bg over the line bg; if the target does not layer them, pre-blend the text bg over the line bg so
changed words stay distinguishable.

**Debugging**

| Function | Color |
|---|---|
| Breakpoint icon | Red |
| Breakpoint line | Transparent (no highlight) |
| Breakpoint line during execution (stopped there) | Yellow at 15% opacity |

## Legibility adaptations

Apply these and mention them in the report:

- Text on *solid* pastel fills is illegible: Text on Teal is ≈ 1.0:1 (Mocha) to 2.1:1 (Latte), Text on Red
  ≈ 1.5:1 (Latte) to 1.6:1 (Mocha). For search highlights either keep fg Text over the accent at ~30%
  opacity or pre-blended (≈ 4.2–6.3:1 in both flavors; verify and adjust), or use a solid accent bg with
  on-accent text (Base; Crust where the guide uses Crust in Mocha).
- On accent = Base is legible on every accent in Mocha (≥ 7:1). Latte accents are mid-tones, so no
  on-accent text reaches 4.5:1 except Base on Mauve and Red (≈ 4.8:1; Blue ≈ 4.3:1). In Latte, use
  whichever of Base or Text contrasts more (Text on Rosewater, Flamingo, Pink, Peach, Yellow and Sky),
  keep solid accent fills for short bold labels, badges and icons, and put longer text on a light accent
  tint.
- Aim for ≥ 4.5:1 on body text and ≥ 3:1 for large text, icons and borders (WCAG 2). Comments (Overlay 2)
  and line numbers (Overlay 1) are deliberately subdued — Latte Overlay 1 on Base is ≈ 2.8:1, so never
  demote important content to Overlay colors.

## Derived colors

- **Opacity:** emit native alpha where supported — `#RRGGBBAA`, `rgba()`, or a separate alpha key. Beware
  `#AARRGGBB` targets (Android, XAML/.NET, Qt). Alpha bytes: 10% `1A`, 15% `26`, 20% `33`, 25% `40`,
  30% `4D`.
- **No alpha support:** pre-blend over the color actually underneath (usually Base; Mantle or Crust in
  side panes): per sRGB channel `round(a·fg + (1 − a)·bg)`.
- **"60% Text / X mix":** `round(0.6·Text + 0.4·X)` per sRGB channel (matches the guide's swatches).

Pre-blended over **Base** at the guide's midpoints:

| Use | Source | Latte | Mocha |
|---|---|---|---|
| Selection bg | Overlay 2, 25% | #d2d5dd | #3b3d4f |
| Cursor line | Text, 10% | #dfe1e7 | #303042 |
| Changed text bg | Blue, 15% | #d0dcf5 | #2e354d |
| Changed line bg | Blue, 20% | #c5d5f5 | #333c57 |
| Inserted text bg | Green, 15% | #d5e5d7 | #323c3f |
| Inserted line bg | Green, 20% | #cce1cd | #394545 |
| Removed text bg | Red, 15% | #ebcfd9 | #3e2e40 |
| Removed line bg | Red, 20% | #e9c4cf | #493446 |
| Execution line | Yellow, 15% | #ede2d5 | #3f3b41 |

Compute anything else (other opacities, other backgrounds, contrast) with:

```python
def rgb(h): h = h.lstrip('#'); return [int(h[i:i + 2], 16) for i in (0, 2, 4)]
def mix(fg, bg, a):  # a = opacity, i.e. weight of fg; "60% Text/X mix" = mix(text, x, 0.6)
    return '#' + ''.join(f'{int(a * f + (1 - a) * b + 0.5):02x}' for f, b in zip(rgb(fg), rgb(bg)))
def lum(h):
    c = [v / 255 for v in rgb(h)]
    c = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
def contrast(a, b):
    hi, lo = sorted((lum(a), lum(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)
```

## Gaps — role analogs

Not in the guide; derived from its roles. Flag these as judgement calls in the report.

| Element | Color | Derived from |
|---|---|---|
| Default foreground, variables, plain identifiers | Text | Body copy |
| Main content / editor area, active tab | Base | Background pane |
| Sidebars, panels, status / title / tab bars, inactive tabs | Mantle, Crust | Secondary panes |
| Inputs, buttons, cards, list rows; hover → pressed; scrollbar thumb | Surface 0 → 1 → 2 | Surface elements |
| Popups, menus, tooltips, dialogs | Mantle or Surface 0 fill, Overlay 0 border, Surface 0–1 selected row | Secondary panes, overlays |
| Borders, separators | Overlay 0; Surface 0–1 for faint dividers | Inactive border |
| Placeholders, disabled text, whitespace markers, inlay / ghost text | Overlay 0–1 | Subtle |
| Focus ring, active / selected marker, primary button, toggles, progress, badges | Accent (default Mauve); text on fills Base | On accent |
| Hints, notes | Teal | Information |
| VCS status: added / changed / removed / ignored | Green / Blue / Red / Overlay 1 | Diff & merge, subtle |
| Prompt / statusline segments | Accent fills with on-accent text, or accent fg on Base / Mantle | On accent |
| Categorical series (charts, multi-color tags) | Rainbow order, then the remaining accents | Rainbow highlights |

Some official ports differ in details (e.g. Yellow for modified files); when the target has an official
port, stay consistent with it.

## Workflow

1. **Recon.** Identify the target and version, how it is themed (theme file, config keys, CSS variables,
   ANSI only, escape sequences), its color format (`#rrggbb`, `#rrggbbaa`, `#aarrggbb`, `rgb()`, 0–1
   floats, 256-color indices) and capabilities (alpha, truecolor, separate selection fg, bold-as-bright).
   Read the existing config before changing it, and follow the host project's structure and naming
   conventions (e.g. a dotfiles repo's setup scripts).
2. **Official port first.** Check `github.com/catppuccin/<app-in-kebab-case>` (`gh api
   repos/catppuccin/<app>`), the port index
   `https://raw.githubusercontent.com/catppuccin/catppuccin/main/resources/ports.yml`, and
   `catppuccin/userstyles` for websites. If a port exists, offer to use or vendor it and hand-map only the
   gaps — unless the user wants it built from scratch.
3. **Enumerate** every themeable color key from the target's docs, schema or default theme — not a sample.
4. **Map** each key → role → color using the guide tables, then *Gaps*. Keep this mapping for the report.
5. **Resolve** exact hex values for the chosen flavor(s); compute every derived value with the snippet.
6. **Write** in the target's native format; annotate colors with their Catppuccin names where comments
   are allowed. Reusable themes get both flavors — files named `catppuccin-<flavor>[-<accent>]` (`latte`,
   `mocha`) unless the host project's conventions say otherwise — or a `catppuccin/whiskers` template
   rendered once per flavor with `-f latte` and `-f mocha`. For 16-color-only targets rely on the ANSI
   mapping.
7. **Verify.** Parse or lint the result; reload or preview the target when possible; audit that every hex
   is in the palette or a documented derivation; check contrast of the key fg/bg pairs; fix and re-verify.
8. **Report** concisely: mapping table (element → role → color name → hex), judgement calls and
   legibility deviations with reasons, files changed, and how to switch flavor or accent.

Ask the user only when the flavor or accent cannot be inferred and the choice matters, or before replacing
an existing non-Catppuccin theme destructively.

## Audit mode

When asked to review a theme: extract every color, identify each element's role, and report a table of
(a) off-palette colors with the nearest palette color (perceptual distance, e.g. OKLab), (b) role
mismatches against the guide, (c) contrast failures, and (d) one role rendered in different colors — each
with severity and the exact fix. Don't edit files unless asked.

## Publishing a port (Catppuccin org conventions)

- Start from `catppuccin/template`; repo name is the app name in `lower-kebab-case`; default branch `main`.
- Description `<emoji> Soothing pastel theme for <App Name>`; topics `catppuccin`, `theme`, `<app-name>`.
- Images under `assets/`, preferring `.webp`; the main README preview shows the Latte and Mocha
  screenshots; relative links; uppercase meta files (`README.md`); no org-wide health files
  (`CODE_OF_CONDUCT.md`, `SUPPORT.md`).
- MIT license unless the target's license requires otherwise.
- Process: Port Request discussion while there is no draft → Port Review issue once the draft is done;
  Stylus userstyles go as a PR to `catppuccin/userstyles`. Ports with religious or political context are
  not accepted.
- Tooling: `catppuccin/whiskers` (templating; render with `-f latte` / `-f mocha`), `catppuccin/toolbox`.
