---
name: python-pil-assets
scope: project
description: Generating and verifying image assets (logos, social cards, Mastodon/LinkedIn/Product Hunt images) with Python PIL — exact sizes, color checks, and safe script patterns.
---

# Python / PIL Asset Generation

Used for outreach assets: logos, Mastodon cards, LinkedIn banners, Product
Hunt images. PIL scripts must produce the exact required dimensions and pass
a verification pass before delivery.

## Required sizes (common targets)

- Mastodon post card: 1200×630 (or 1600×900)
- Mastodon square: 1080×1080
- LinkedIn company logo: 300×300
- LinkedIn banner: 1584×396
- Product Hunt: 1024×1024 logo + 1600×900 gallery
- App favicon: 32×32 / 512×512

## Script pattern

```python
from PIL import Image, ImageDraw, ImageFont
# draw...
im.save(path)
```

- Prefer `RGB` for JPEG/PNG web output; keep `RGBA` only where transparency
  is needed (favicons). Convert before saving to avoid palette surprises.
- Fonts: use a bundled TTF (e.g. DejaVuSans, or a brand font in the assets
  folder) — never rely on a font that only exists on one machine, that breaks
  portability.

## Always verify the output

```python
from PIL import Image
im = Image.open(path)
print(path, im.size, im.mode)   # size + mode must match the target spec
```

Also visually inspect via a rendered preview (HTML contact sheet or opening
the image) before shipping — dimensions being right does not mean the layout
is right.

## Portability rules

- Scripts must run with a plain `python3` + Pillow (no project venv
  required) unless the skill doc says otherwise.
- No hard-coded absolute paths — use a path relative to the script or
  `$HOME`.
- Keep source scripts next to their outputs in the same assets folder.

## Verification

- `python3 -m py_compile script.py` before running.
- Confirm final images at the exact target size + mode.
- If the user reports a visual issue (e.g. "too much whitespace", "letters
  too low"), adjust the draw coordinates and re-verify, don't just resize.
