# OmaClock

A simple, minimal desktop clock widget for [Omarchy](https://omarchy.org/)
that renders **behind all of your open windows** on the bottom layer — a clean,
click-through time display living on your desktop like a wallpaper.

- Renders behind every app window on the bottom layer (click-through; desktop
  and wallpaper interactions keep working)
- Fully configurable time format — 12-hour, 24-hour, with seconds, and optional
  AM/PM (e.g. `1:30`, `13:30`, `1:30 PM`, `1:30:05`)
- Bundled **Inter** typeface (OFL-licensed) — no system font install needed;
  override with any installed font
- Adjustable size, weight, letter spacing, color, opacity, and position
- Single `config.json`, hot-reloaded (~2s) on save

## Install

```bash
omarchy plugin add https://github.com/ubeyidah/omaclock
```

Then reload the shell (or it hot-reloads automatically):

```bash
omarchy restart shell
```

## Configure

Edit `~/.config/omarchy/plugins/ubeyidah.omaclock/config.json` and save — the
clock reloads within ~2 seconds.

| Key            | Default     | Description                                                        |
|----------------|-------------|--------------------------------------------------------------------|
| `format`       | `h:mm`      | Qt time format. `h:mm` = 12h, `HH:mm` = 24h, `h:mm AP` = 12h with AM/PM, `h:mm:ss` = with seconds |
| `showSeconds`  | `false`     | Tick every second instead of every minute.                         |
| `fontFamily`   | `""`        | Empty = bundled Inter. Set any installed family to override.       |
| `fontWeight`   | `200`       | Numerals weight (100–900; 200 = thin).                             |
| `fontScale`    | `0.15`      | Font size as a fraction of screen height (0.15 = 15%).            |
| `letterSpacing`| `-3`        | Tightens the numerals for a compact, minimal look.                 |
| `color`        | `#ffffff`   | Clock color (any CSS color).                                       |
| `opacity`      | `0.92`      | Clock opacity.                                                     |
| `position`     | `top`       | `top` / `center` / `bottom` (used when `yRatio` is unset).         |
| `yRatio`       | `0.20`      | Vertical position as a 0–1 ratio of screen height.                 |
| `xRatio`       | `0.5`       | Horizontal position as a 0–1 ratio of screen width.                |

Example — bigger, centered, with seconds:

```json
{
  "format": "h:mm:ss",
  "showSeconds": true,
  "fontScale": 0.22,
  "position": "center"
}
```

## Uninstall

```bash
omarchy plugin remove ubeyidah.omaclock
```

The plugin only ever draws a transparent layer; removing it leaves no trace.

## License

- Plugin code: [MIT](LICENSE)
- Bundled Inter font: [SIL Open Font License 1.1](fonts/OFL.txt)
