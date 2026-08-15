# OmaClock

A large, Apple-style desktop clock for [Omarchy](https://omarchy.org/) that
renders **behind all of your open windows** on the bottom layer — like a
wallpaper clock you can't click through.

- 12-hour display with **no AM/PM** clutter (e.g. `12:43`, `1:30`, `11:59`)
- Bundled **Inter** typeface (OFL-licensed) — no system font install needed
- Thin, tall numerals sized as a fraction of your screen height
- Fully configurable from a single `config.json`
- Click-through: desktop and wallpaper interactions keep working

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
| `format`       | `h:mm`      | Time format. `h:mm` = 12h no AM/PM, `HH:mm` = 24h, `h:mm:ss` = secs |
| `showSeconds`  | `false`     | Tick every second instead of every minute.                         |
| `fontFamily`   | `""`        | Empty = bundled Inter. Set any installed family to override.       |
| `fontWeight`   | `200`       | Numerals weight (100–900; 200 = thin).                             |
| `fontScale`    | `0.15`      | Font size as a fraction of screen height (0.15 = 15%).            |
| `letterSpacing`| `-3`        | Tightens the numerals for an Apple-like look.                      |
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
