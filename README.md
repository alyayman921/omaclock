# OmaClock

A simple, minimal desktop clock widget for [Omarchy](https://omarchy.org/) that
renders **behind all of your open windows** on the bottom layer — a clean,
click-through time display living on your desktop like a wallpaper.

## Features

- Renders behind every app window on the bottom layer (click-through; desktop
  and wallpaper interactions keep working).
- Fully configurable time format — 12-hour, 24-hour, with seconds, and optional
  AM/PM (e.g. `1:30`, `13:30`, `1:30 PM`, `1:30:05`).
- **Theme-aware color** by default: a softened version of your active Omarchy
  theme's accent (blended toward the theme foreground) that recolors live when
  you switch themes. Set a fixed CSS color to override.
- Bundled **Inter** typeface (OFL) as the default font — no system install
  needed. Also bundles **Plus Jakarta Sans** (OFL) as an optional Apple-like
  alternative, and you can use any installed system font.
- Adjustable size, weight, letter spacing, opacity, and on-screen position.
- A single `config.json`, hot-reloaded (~2s) on save.

## Install

```bash
omarchy plugin add https://github.com/ubeyidah/omaclock
omarchy restart shell
```

## Configure

The clock reads `~/.config/omaclock/config.json`. If the file does not exist or
a key is missing, built-in defaults are used. Edit and save — the clock reloads
within ~2 seconds.

### Options

| Key             | Default             | Description                                                                 |
|-----------------|---------------------|-----------------------------------------------------------------------------|
| `format`        | `h:mm`              | Qt time format. `h:mm` = 12h, `HH:mm` = 24h, `h:mm AP` = 12h with AM/PM, `h:mm:ss` = with seconds. |
| `showSeconds`   | `false`             | Tick every second instead of every minute.                                  |
| `fontFamily`    | `""`                | Font: `""` = bundled **Inter** (default); `"system"` = platform default font; any other name = that family (e.g. `"Plus Jakarta Sans"`). |
| `fontWeight`    | `200`               | Numerals weight, 100–900 (200 = thin, 400 = regular).                      |
| `fontScale`     | `0.15`              | Font size as a fraction of screen height (0.15 = 15%).                     |
| `letterSpacing` | `-3`                | Extra spacing between numerals (negative tightens them).                   |
| `color`         | `""`                | Clock color. `""` follows a softened version of the active theme's accent and recolors on theme switch; any CSS color (e.g. `#ffffff`) overrides it. |
| `opacity`       | `0.92`              | Clock opacity, 0–1.                                                         |
| `position`      | `top`               | Vertical anchor used when `yRatio` is not set: `top` / `center` / `bottom`. |
| `yRatio`        | `0.20`              | Vertical position as a 0–1 ratio of screen height (overrides `position`).   |
| `xRatio`        | `0.5`               | Horizontal position as a 0–1 ratio of screen width.                        |
| `namespace`     | `ubeyidah.omaclock` | Layer namespace (advanced; normally leave unchanged).                       |

### Color & theming

With `color` left empty, the clock uses a softened accent derived from your
active Omarchy theme, so it always harmonizes with your setup and updates the
moment you switch themes (`omarchy theme set …`). To pin a specific color, set
`color` to any CSS color string.

### Fonts

- `""` (default) → bundled **Inter**.
- `"system"` → your platform's default UI font.
- Any other value → that font family, if installed (the bundled **Plus Jakarta
  Sans** is available as `"Plus Jakarta Sans"`).

## Examples

Bigger, centered, with seconds:

```json
{
  "format": "h:mm:ss",
  "showSeconds": true,
  "fontScale": 0.22,
  "position": "center"
}
```

Soft theme accent, Inter, lower on the screen:

```json
{
  "color": "",
  "fontFamily": "",
  "yRatio": 0.80
}
```

Use the system font with a fixed white color:

```json
{
  "fontFamily": "system",
  "color": "#ffffff"
}
```

## Uninstall

```bash
omarchy plugin remove ubeyidah.omaclock
```

The plugin only ever draws a transparent layer; removing it leaves no trace.
You can also delete `~/.config/omaclock/config.json` if you no longer want it.

## License

- Plugin code: [MIT](LICENSE)
- Bundled Inter font: [SIL Open Font License 1.1](fonts/OFL.txt)
- Bundled Plus Jakarta Sans font: [SIL Open Font License 1.1](fonts/PlusJakartaSans-OFL.txt)
