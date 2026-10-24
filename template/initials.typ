// Decorated initials for chapter openings.
//
// The first paragraph of every chapter begins with a large ornamented capital
// in the manner of old printed books, followed by a few words in small caps.
// Text flows around the capital using the droplet package.

#import "@preview/droplet:0.3.1": dropcap

// Zallman Caps, converted for Typst (see fonts/README.md).
#let initials-font = "Zallman Caps PoE"

// Zallman's capitals stand 769 units tall, EB Garamond's 650. A Garamond
// letter set into a Zallman ornament is scaled by this much to match.
#let letter-scale = 769 / 650

#let space = [ ].func()
#let sequence = [].func()

// The decorated form of one capital, drawn at the current text size.
//
// Zallman has no X or Y of its own, only their ornaments, so for those two a
// bold Garamond capital is set into the ornament. Characters the font lacks
// entirely (digits, accented capitals) fall back to a plain capital.
#let ornate(letter) = {
  set text(top-edge: "bounds", bottom-edge: "bounds")
  if letter in ("X", "Y") {
    box({
      hide(text(font: initials-font, letter))
      place(top + left, text(font: initials-font, letter))
      place(bottom + center, text(
        font: "EB Garamond", weight: "semibold", size: letter-scale * 1em, letter,
      ))
    })
  } else if regex("^[A-Z]$") in letter {
    text(font: initials-font, letter)
  } else {
    text(font: "Cormorant Garamond", weight: "regular", letter)
  }
}

// The text of a small piece of content, with smart quotes as opening quotes.
#let plain(it) = {
  if type(it) == str { it }
  else if it.has("text") { it.text }
  else if it.func() == smartquote { if it.double { "“" } else { "‘" } }
  else if it.has("children") { it.children.map(plain).join() }
  else if it.has("body") { plain(it.body) }
  else { "" }
}

// droplet hands over the first letter together with any punctuation around
// it, such as an opening quotation mark. The punctuation hangs in the margin
// at text size, so that only the letter itself is enlarged.
#let initial(letter, text-size) = {
  let m = plain(letter).match(regex("^(\W*)(\w)\W*$"))
  if m == none { return ornate(plain(letter)) }
  let (before, ch) = m.captures
  box({
    if before != "" {
      let mark = text(size: text-size, top-edge: "cap-height", before)
      place(top + left, dx: -measure(mark).width - 0.2 * text-size, mark)
    }
    ornate(upper(ch))
  })
}

// When a paragraph opens with a straight quotation mark, droplet moves that
// mark into the margin beside the initial. Its partner is then left alone in
// the paragraph and Typst would curl it the wrong way, so the partner is set
// explicitly as a closing mark.
#let close-opening-quote(children) = {
  let start = children.position(c => c.func() != space)
  if start == none or children.at(start).func() != smartquote { return children }
  let double = children.at(start).at("double", default: true)
  let offset = children.slice(start + 1).position(c => (
    c.func() == smartquote and c.at("double", default: true) == double
  ))
  if offset == none { return children }
  let i = start + 1 + offset
  children.slice(0, i) + (text(if double { "”" } else { "’" }),) + children.slice(i + 1)
}

// Sets the first few words of a paragraph in small caps, the customary
// lead-in after a decorated initial. Only plain text is converted; the
// lead-in stops early at anything else, such as emphasis or a footnote.
#let lead-in(body, words: 3) = {
  let children = if body.func() == sequence { body.children } else { (body,) }
  children = close-opening-quote(children)
  let taken = ()
  let count = 0
  let i = 0
  while i < children.len() and count < words {
    let child = children.at(i)
    if child.func() == text {
      let parts = child.text.split(" ")
      let need = words - count
      if parts.len() > need {
        taken.push(parts.slice(0, need).join(" "))
        let rest = (text(parts.slice(need).join(" ")),)
        return (
          smallcaps(text(tracking: 0.04em, taken.join()))
            + [ ] + (rest + children.slice(i + 1)).join()
        )
      }
      taken.push(child.text)
      count += parts.len()
    } else if child.func() in (space, smartquote) {
      taken.push(child)
    } else {
      break
    }
    i += 1
  }
  if taken.len() == 0 { return children.join() }
  smallcaps(text(tracking: 0.04em, taken.join())) + children.slice(i).join()
}

// A paragraph opened by a decorated initial spanning `lines` lines.
#let dropped(body, lines: 4, fill: black, words: 3) = context {
  let size = text.size
  dropcap(
    height: lines,
    gap: 0.45em,
    justify: true,
    fill: fill,
    transform: letter => initial(letter, size),
    lead-in(body, words: words),
  )
}
