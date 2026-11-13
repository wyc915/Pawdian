"""Builds assets/fonts/NotoSansTC-Subset.ttf for the vet report PDF.

The full Noto Sans TC (7 MB) is kept in tool/font_source/ and is not bundled.
The subset covers every character in Big5 (all Traditional Chinese in common
use, 13,000+ characters), the most common Simplified Chinese characters, Latin, punctuation,
Bopomofo and Japanese kana, which keeps the PDF readable for almost any text
while roughly halving the app size cost of the font.

Run from the project root:  python tool/subset_font.py
Requires: pip install fonttools
"""

from pathlib import Path

from fontTools import subset

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "tool" / "font_source" / "NotoSansTC-Regular.ttf"
TARGET = ROOT / "assets" / "fonts" / "NotoSansTC-Subset.ttf"


def codepoints_of(encoding: str, lead: range, trail: list[int]) -> set[int]:
    out = set()
    for a in lead:
        for b in trail:
            try:
                out.update(ord(c) for c in bytes([a, b]).decode(encoding))
            except UnicodeDecodeError:
                pass
    return out


def main() -> None:
    cps: set[int] = set()
    # Big5: lead 0xA1-0xF9, trail 0x40-0x7E and 0xA1-0xFE.
    cps |= codepoints_of(
        "big5", range(0xA1, 0xFA), list(range(0x40, 0x7F)) + list(range(0xA1, 0xFF))
    )
    # Simplified Chinese: the 3,755 most common characters (GB2312 level 1).
    cps |= codepoints_of("gb2312", range(0xB0, 0xD8), list(range(0xA1, 0xFF)))
    ranges = [
        (0x20, 0x7E),  # ASCII
        (0xA0, 0x24F),  # Latin-1 and Latin Extended
        (0x2000, 0x206F),  # General punctuation
        (0x2190, 0x21FF),  # Arrows
        (0x2460, 0x24FF),  # Enclosed numbers
        (0x2500, 0x257F),  # Box drawing
        (0x25A0, 0x25FF),  # Geometric shapes
        (0x2700, 0x27BF),  # Dingbats (check mark)
        (0x3000, 0x303F),  # CJK symbols and punctuation
        (0x3040, 0x30FF),  # Hiragana, Katakana
        (0x3100, 0x312F),  # Bopomofo
        (0x31A0, 0x31BF),  # Bopomofo extended
        (0xFF00, 0xFFEF),  # Full-width forms
    ]
    for lo, hi in ranges:
        cps.update(range(lo, hi + 1))

    options = subset.Options()
    # The pdf package does no shaping, so OpenType layout tables are not needed.
    options.layout_features = []
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    options.hinting = False
    font = subset.load_font(str(SOURCE), options)
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=sorted(cps))
    subsetter.subset(font)
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    subset.save_font(font, str(TARGET), options)
    print(f"{len(cps)} code points -> {TARGET} ({TARGET.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
