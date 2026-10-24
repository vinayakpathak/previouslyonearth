# Fonts

The book is typeset only with the fonts in this folder, so it looks the same on any machine. Typst finds them through `--font-path fonts`, which the Makefile passes, and the VS Code Tinymist extension finds them through `.vscode/settings.json`. All three were copied from TeX Live 2025.

## EB Garamond: body text

`eb-garamond/`. Regular, Medium, SemiBold and Bold, each with its italic, in OpenType. These include small capitals, old-style figures and polytonic Greek.

Georg Duffner drew the Regular and Italic after the Egenolff–Berner specimen (Frankfurt, 1592), which shows Claude Garamont's roman and Robert Granjon's italic. Octavio Pardo drew the heavier weights. The upstream project is [octaviopardo/EBGaramond12](https://github.com/octaviopardo/EBGaramond12), and the files come from TeX Live's `ebgaramond` package.

Licensed under the SIL Open Font License 1.1 (`eb-garamond/OFL.txt`; authors in `AUTHORS.txt`).

## Cormorant Garamond: titles and chapter numerals

`cormorant-garamond/`. Light, Light Italic, Regular and Italic, in TrueType. Designed by Christian Thalmann; the upstream project is [CatharsisFonts/Cormorant](https://github.com/CatharsisFonts/Cormorant). The files come from TeX Live's `cormorantgaramond` package.

Licensed under the SIL Open Font License 1.1 (`cormorant-garamond/OFL.txt`).

## Zallman Caps PoE: decorated initials and the rosette ornament

`zallman-caps/ZallmanCapsPoE.otf` is a modified version of **Zallman Caps**. The original's own notice reads: "Copyright (c) Typographer Mediengestaltung, 2000. All rights reserved. Zallman-Caps © 1991 by D. Rakowski."

The original came as `Zallman.pfb` in TeX Live's `initials` package. That package collects decorative initials made by Dieter Steffmann, who gave permission for them to be redistributed and modified under the LaTeX Project Public License. The licence text is in `zallman-caps/LPPL.txt`.

`zallman-caps/build.py` produced this version from `Zallman.pfb` with the following changes:

1. Converted from Type 1 to OpenType (CFF), because Typst cannot read Type 1 fonts. Letter outlines and widths are unchanged.
2. The original X and Y are placeholders reading "Sorry, no X" and "Sorry, no Y". They are replaced by ornament-only glyphs made from the vines of V. The template sets an EB Garamond capital into them; see `template/initials.typ`.
3. The flower above V's arms is added on its own at U+2766 (❦). It serves as the book's ornament.
4. Only the capitals A–Z are kept. Lowercase letters map to them.
5. The font is renamed "Zallman Caps PoE" so it cannot be mistaken for the original.

To rebuild it (needs `pip install fonttools`):

```sh
python3 -I fonts/zallman-caps/build.py \
  /usr/local/texlive/2025/texmf-dist/fonts/type1/public/initials/Zallman.pfb \
  fonts/zallman-caps/ZallmanCapsPoE.otf
```
