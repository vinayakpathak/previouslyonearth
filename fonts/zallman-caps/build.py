"""Build ZallmanCapsPoE.otf, the decorated initials used at chapter openings.

Source: Zallman Caps by Dieter Steffmann, as distributed in TeX Live's
`initials` package (fonts/type1/public/initials/Zallman.pfb) under the LPPL.

Changes from the original:
  1. Converted from Type 1 to CFF OpenType, which Typst can read. Outlines
     and advance widths are copied unchanged.
  2. The original X and Y are placeholder glyphs that read "Sorry, no X" and
     "Sorry, no Y". They are replaced by ornament-only glyphs: Y takes the
     vines of V (everything except the letter body), and X takes the flower
     above V's arms, repeated upside down beneath them. The book template sets
     a plain letter into these ornaments (see template/initials.typ).
  3. The flower above V's arms is also added on its own, at U+2766 (❦), as
     a fleuron for section breaks and the title page.
  4. Renamed to "Zallman Caps PoE" so it cannot be mistaken for the original.

usage: python3 -I fonts/build-zallman.py <Zallman.pfb> fonts/ZallmanCapsPoE.otf
Requires fontTools (pip install fonttools).
"""

import sys

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.areaPen import AreaPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.pens.transformPen import TransformPen
from fontTools.t1Lib import T1Font

FAMILY = "Zallman Caps PoE"
PS_NAME = "ZallmanCapsPoE"


def contours(recording):
    out, cur = [], []
    for op, args in recording.value:
        cur.append((op, args))
        if op in ("closePath", "endPath"):
            out.append(cur)
            cur = []
    return out


def stats(contour):
    area, bounds = AreaPen(), BoundsPen(None)
    for op, args in contour:
        getattr(area, op)(*args)
        getattr(bounds, op)(*args)
    return area.value, bounds.bounds


def replay(contour_list, pen):
    for contour in contour_list:
        for op, args in contour:
            getattr(pen, op)(*args)


def main(src, dst):
    t1 = T1Font(src, encoding="latin-1")
    t1.parse()
    font = t1.font
    charstrings = font["CharStrings"]
    upm = round(1 / font.get("FontMatrix", [0.001])[0])

    outlines, widths = {}, {}
    for name in charstrings.keys():
        rec = RecordingPen()
        charstrings[name].draw(rec)
        outlines[name] = contours(rec)
        widths[name] = round(charstrings[name].width)

    # The ornament of V: every contour but the letter body (the largest one).
    v = outlines["V"]
    body = max(range(len(v)), key=lambda i: abs(stats(v[i])[0]))
    v_ornament = [c for i, c in enumerate(v) if i != body]

    # The flower that sits above V's arms: contours centred in the upper
    # middle of the glyph, above where the arms of an X would cross.
    v_width = widths["V"]
    flower = []
    for c in v_ornament:
        _, (x0, y0, x1, y1) = stats(c)
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        if abs(cx - v_width / 2) < v_width * 0.2 and cy > 540:
            flower.append(c)

    # Each glyph is drawn once into a recording, from which both its outline
    # and its bounds are taken.
    drawings = {}

    # Only the capitals are kept; lowercase code points map to them below.
    keep = [n for n in charstrings.keys() if len(n) == 1 and "A" <= n <= "Z"]
    for name in keep:
        rec = RecordingPen()
        if name == "Y":
            widths[name] = v_width
            replay(v_ornament, rec)
        elif name == "X":
            widths[name] = v_width
            replay(flower, rec)
            # The same flower turned upside down, beneath the crossing.
            replay(flower, TransformPen(rec, (-1, 0, 0, -1, v_width, 769)))
        else:
            replay(outlines[name], rec)
        drawings[name] = rec

    # The flower alone, sitting on the baseline with a little room each side.
    flower_bounds = BoundsPen(None)
    replay(flower, flower_bounds)
    fx0, fy0, fx1, fy1 = flower_bounds.bounds
    side = 40
    widths["fleuron"] = round(fx1 - fx0) + 2 * side
    rec = RecordingPen()
    replay(flower, TransformPen(rec, (1, 0, 0, 1, side - fx0, -fy0)))
    drawings["fleuron"] = rec

    drawings[".notdef"] = RecordingPen()
    widths[".notdef"] = upm // 2
    order = [".notdef"] + keep + ["fleuron"]

    glyphs, metrics = {}, {}
    for name in order:
        pen = T2CharStringPen(widths[name], None)
        drawings[name].replay(pen)
        glyphs[name] = pen.getCharString()
        bounds = BoundsPen(None)
        drawings[name].replay(bounds)
        metrics[name] = (widths[name], round(bounds.bounds[0]) if bounds.bounds else 0)

    cmap = {0x2766: "fleuron"}
    for name in keep:
        cmap[ord(name)] = name
        cmap[ord(name.lower())] = name

    ymin, ymax = -10, 780
    fb = FontBuilder(upm, isTTF=False)
    fb.setupGlyphOrder(order)
    fb.setupCharacterMap(cmap)
    fb.setupCFF(PS_NAME, {"FullName": FAMILY, "FamilyName": FAMILY, "Weight": "Regular"}, glyphs, {})
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=ymax, descent=ymin)
    fb.setupNameTable({
        "copyright": "Zallman Caps by Dieter Steffmann. Distributed under the LaTeX Project Public License.",
        "familyName": FAMILY,
        "styleName": "Regular",
        "uniqueFontIdentifier": f"{PS_NAME}-1.000",
        "fullName": FAMILY,
        "psName": PS_NAME,
        "version": "Version 1.000",
        "description": "Modified version of Zallman Caps: converted to OpenType, "
                       "and the placeholder X and Y replaced by ornament-only glyphs "
                       "derived from V. See fonts/README.md.",
        "licenseDescription": "LaTeX Project Public License (LPPL)",
    })
    fb.setupOS2(
        sTypoAscender=ymax, sTypoDescender=ymin, sTypoLineGap=0,
        usWinAscent=ymax, usWinDescent=-ymin,
        sxHeight=500, sCapHeight=769,
    )
    fb.setupPost()
    fb.save(dst)
    print(f"wrote {dst}: {len(order)} glyphs, flower contours for X: {len(flower)}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
