// Plantilla clara 16:9 para la segunda presentación.
// Paleta deliberadamente reducida: tinta, petróleo y grises.

#let c-bg = rgb("#ffffff")
#let c-fg = rgb("#172033")
#let c-muted = rgb("#5f6b7a")
#let c-accent = rgb("#0f6173")
#let c-accent-soft = rgb("#e8f1f3")
#let c-panel = rgb("#f5f7f9")
#let c-line = rgb("#d6dde4")
#let c-warn = rgb("#a75b20")
#let c-warn-soft = rgb("#fff3e8")

#let deck-title = state("deck-title-v2", "")
#let set-deck-title(t) = deck-title.update(t)

#let slides-setup(title: "", body) = {
  set document(title: title)
  set page(
    width: 25.4cm,
    height: 14.29cm,
    margin: (x: 0.95cm, top: 0.72cm, bottom: 0.62cm),
    fill: c-bg,
  )
  set text(
    font: "Arial",
    size: 14pt,
    fill: c-fg,
  )
  set par(justify: false, leading: 0.57em, spacing: 0.55em)
  set block(breakable: false, spacing: 0.52em)
  set grid(gutter: 10pt)
  show list: set block(spacing: 0.42em)
  show heading: set text(fill: c-fg)
  set-deck-title(title)
  body
}

#let pill(txt, fill: c-accent-soft, color: c-accent) = box(
  fill: fill,
  inset: (x: 7pt, y: 3pt),
  radius: 3pt,
  text(size: 10.5pt, weight: "bold", fill: color, txt),
)

#let slide(title: none, tag: none, body) = {
  set page(footer: context [
    #set text(size: 8.5pt, fill: c-muted)
    #grid(columns: (1fr, auto),
      align(left)[#deck-title.get()],
      align(right)[#counter(page).display()],
    )
  ])
  block(width: 100%)[
    #grid(columns: (1fr, auto), align: (left, right + horizon),
      if title != none { text(size: 22pt, weight: "bold", fill: c-fg, title) },
      if tag != none { pill(tag) },
    )
    #v(1pt)
    #line(length: 100%, stroke: 1.2pt + c-accent)
  ]
  v(5pt)
  set text(size: 14pt)
  body
  pagebreak(weak: true)
}

#let title-slide(title: "", subtitle: "", authors: (), course: "", date: "") = {
  set page(footer: none)
  set align(horizon)
  grid(columns: (1.35fr, 0.65fr), gutter: 24pt, align: horizon,
    [
      #pill(course)
      #v(13pt)
      #text(size: 35pt, weight: "bold", fill: c-fg, title)
      #v(5pt)
      #text(size: 18pt, fill: c-muted, subtitle)
      #v(16pt)
      #line(length: 38%, stroke: 2pt + c-accent)
      #v(10pt)
      #for a in authors [#text(size: 14pt, fill: c-fg)[#a] #linebreak()]
      #v(5pt)
      #text(size: 12pt, fill: c-muted, date)
    ],
    align(center, block(
      width: 100%, fill: c-accent-soft, inset: 18pt, radius: 8pt,
      stroke: 1pt + c-line,
    )[
      #align(center)[
        #text(size: 13pt, fill: c-muted)[Entrada]
        #text(size: 31pt, weight: "bold", fill: c-accent)[4 bits]
        #v(11pt)
        #text(size: 13pt, fill: c-muted)[Interpolación]
        #text(size: 31pt, weight: "bold", fill: c-accent)[L = 4]
        #v(11pt)
        #text(size: 13pt, fill: c-muted)[Salida]
        #text(size: 31pt, weight: "bold", fill: c-accent)[6 bits]
      ]
    ]),
  )
  pagebreak(weak: true)
}

#let panel(title: none, fill: white, stroke-c: c-line, body) = block(
  width: 100%,
  fill: fill,
  inset: 9pt,
  radius: 5pt,
  stroke: 0.8pt + stroke-c,
)[
  #if title != none [
    #text(weight: "bold", fill: c-accent, size: 13pt, title)
    #v(3pt)
  ]
  #set text(size: 12.4pt)
  #body
]

#let pending(title: none, body) = panel(
  title: title,
  fill: c-warn-soft,
  stroke-c: c-warn,
  body,
)

#let dblock(txt, fill: c-accent-soft, color: c-fg) = box(
  fill: fill,
  inset: (x: 10pt, y: 8pt),
  radius: 5pt,
  stroke: 0.9pt + c-line,
)[#text(size: 12pt, weight: "bold", fill: color, align(center, txt))]

#let arr = text(size: 17pt, fill: c-accent, baseline: 0pt)[→]

#let flow(..items) = align(center, grid(
  columns: items.pos().len() * (auto,),
  align: horizon,
  column-gutter: 6pt,
  ..items.pos(),
))

#let kpi(value, label, color: c-accent) = block(
  width: 100%, fill: c-panel, inset: 9pt, radius: 5pt,
  stroke: 0.8pt + c-line,
)[
  #align(center)[
    #text(size: 24pt, weight: "bold", fill: color, value)
    #v(2pt)
    #text(size: 10.5pt, fill: c-muted, label)
  ]
]

#let phase-card(name, formula, note) = panel()[
  #grid(columns: (auto, 1fr), gutter: 8pt, align: horizon,
    pill(name),
    [#text(size: 14pt, weight: "bold")[#formula] #h(5pt) #text(size: 10.5pt, fill: c-muted)[#note]],
  )
]
