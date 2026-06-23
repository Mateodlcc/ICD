// Plantilla clara 16:9 para la segunda presentación.
// Paleta deliberadamente reducida: tinta, petróleo y grises.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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

// ============================================================
// Diagramas de arquitectura (fletcher) — slide 6
// ============================================================

// Caja-nodo de proceso con el estilo del deck (rectángulo uniforme).
#let dnode(pos, body, name: none, fill: c-accent-soft) = node(
  pos,
  align(center, text(size: 9pt, fill: c-fg, body)),
  name: name,
  shape: fletcher.shapes.rect,
  fill: fill,
  stroke: 0.9pt + c-line,
  corner-radius: 4pt,
  inset: 5pt,
)

// Extremo de arista (entrada/salida) en mono, sin caja.
#let ionode(pos, t, name: none) = node(
  pos, text(size: 9pt, fill: c-muted, raw(t)), name: name, outset: 0pt,
)

// Etiqueta pequeña de bus para las aristas.
#let elabel(t) = text(size: 7.5pt, fill: c-muted, t)

// Datapath: pipeline horizontal de 5 etapas. La entrada x[3:0] y la
// salida o_D[5:0] son extremos de arista (ghost nodes sin caja). El
// fondo de las etiquetas iguala al del panel para que se lean nítidas.
#let arch-datapath = align(center, diagram(
  spacing: (8mm, 6mm),
  edge-stroke: 1pt + c-accent,
  node-outset: 0pt,
  {
    let de(a, b, t) = edge(a, b, elabel(t), "->", label-fill: c-accent-soft)
    ionode((-1, 0), "x[3:0]", name: <in>)
    dnode((0, 0), [Reg. ent.\ 4 FF],      name: <reg>)
    dnode((1, 0), [Núcleo\ CLA4+2×CLA5],  name: <core>)
    dnode((2, 0), [Fases\ 4×6 FF],        name: <fases>)
    dnode((3, 0), [MUX 4:1\ 6 b],         name: <mux>)
    dnode((4, 0), [Reg. sal.\ 6 FF],      name: <regout>)
    ionode((5, 0), "o_D[5:0]", name: <out>)
    de(<in>,    <reg>,    [4 b])
    de(<reg>,   <core>,   [2×4 b])
    de(<core>,  <fases>,  [4×6 b])
    de(<fases>, <mux>,    [6 b])
    de(<mux>,   <regout>, [6 b])
    de(<regout>, <out>,   [6 b])
  },
))

// Control: flujo vertical de 3 nodos. La selección alimenta el MUX 4:1
// del datapath (queda explícito en el nombre del último nodo).
#let arch-control = align(center, diagram(
  spacing: (6mm, 7mm),
  edge-stroke: 1pt + c-accent,
  node-outset: 0pt,
  {
    let ce(a, b, t) = edge(a, b, elabel(t), "->", label-fill: white)
    dnode((0, 0), [Contador\ 2 FF],       name: <cnt>)
    dnode((0, 1), [Decoder\ one-hot],     name: <dec>)
    dnode((0, 2), [Sel. MUX 4:1\ φ0..φ3], name: <sel>)
    ce(<cnt>, <dec>, [2 b])
    ce(<dec>, <sel>, [one-hot ×4])
  },
))
