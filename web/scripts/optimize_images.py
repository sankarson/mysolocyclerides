#!/usr/bin/env python3
"""Generate responsive WebP variants of the photobook pages.

For every <book>/<Prefix>-Page-N.jpg this writes:
  <book>/webp/<Prefix>-Page-N-<width>.webp   (one per entry in WIDTHS)
  <book>/thumbnails/<Prefix>-Page-N.webp     (from the existing JPEG thumbnail)

photobook.js serves these via <picture>/srcset, keeping the JPEGs as fallback.
Re-run after adding or replacing pages:  python3 scripts/optimize_images.py
Requires Pillow (pip install pillow).
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
BOOKS = ["greece", "spain", "v4", "japan"]
WIDTHS = [800, 1600, 2400]
MAIN_QUALITY = 80
THUMB_QUALITY = 75


def save_webp(img, dest, quality):
    img.save(dest, "WEBP", quality=quality, method=6)


def up_to_date(src, dest):
    return dest.exists() and dest.stat().st_mtime >= src.stat().st_mtime


def main():
    for book in BOOKS:
        book_dir = ROOT / book
        out_dir = book_dir / "webp"
        out_dir.mkdir(exist_ok=True)
        for src in sorted(book_dir.glob("*-Page-*.jpg")):
            targets = [(w, out_dir / f"{src.stem}-{w}.webp") for w in WIDTHS]
            if not all(up_to_date(src, d) for _, d in targets):
                with Image.open(src) as img:
                    img = img.convert("RGB")
                    for width, dest in targets:
                        w = min(width, img.width)
                        h = round(img.height * w / img.width)
                        save_webp(img.resize((w, h), Image.LANCZOS), dest, MAIN_QUALITY)
            thumb = book_dir / "thumbnails" / src.name
            thumb_dest = thumb.with_suffix(".webp")
            if thumb.exists() and not up_to_date(thumb, thumb_dest):
                with Image.open(thumb) as img:
                    save_webp(img.convert("RGB"), thumb_dest, THUMB_QUALITY)
            print(f"{book}/{src.name}")


if __name__ == "__main__":
    main()
