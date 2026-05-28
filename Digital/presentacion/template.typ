// ============================================================
//  Plantilla de slides autocontenida (sin paquetes externos)
//  IEE3753 - Proyecto P1 - Filtro de interpolacion
//  Compilar:  typst compile presentacion.typ
// ============================================================

// ---------- Paleta ----------
#let c-bg      = rgb("#0e1116")
#let c-img-bg  = rgb("#121212")
#let c-fg      = rgb("#e8edf2")
#let c-muted   = rgb("#9aa7b4")
#let c-accent  = rgb("#e0820a")   // naranja (nucleo de interpolacion)
#let c-blue    = rgb("#3b6ea5")   // registros
#let c-green   = rgb("#4f9d57")   // mux
#let c-purple  = rgb("#7d6bb0")   // control / fases
#let c-panel   = rgb("#161c24")
#let c-line    = rgb("#2a333d")

// ---------- Estado global para numeracion / footer ----------
#let deck-title = state("deck-title", "")
#let set-deck-title(t) = deck-title.update(t)

// ---------- Configuracion de pagina (16:9) ----------
#let slides-setup(title: "", body) = {
  set document(title: title)
  set page(
    width: 25.4cm, height: 14.29cm,
    margin: (x: 1.2cm, top: 1.1cm, bottom: 0.85cm),
    fill: c-bg,
  )
  set text(font: ("Noto Sans", "Liberation Sans", "DejaVu Sans"), size: 15pt, fill: c-fg)
  set par(justify: false, leading: 0.6em, spacing: 0.65em)
  set block(breakable: false, spacing: 0.65em)
  set grid(gutter: 10pt)
  show list: set block(spacing: 0.5em)
  show heading: set text(fill: c-fg)
  set-deck-title(title)
  body
}

// ---------- Pildora / etiqueta ----------
#let pill(txt, fill: c-accent) = box(
  fill: fill, inset: (x: 7pt, y: 3pt), radius: 4pt,
  text(size: 12pt, weight: "bold", fill: white, txt),
)

// ---------- Slide de contenido ----------
#let slide(title: none, tag: none, body) = {
  set page(footer: context [
    #set text(size: 10pt, fill: c-muted)
    #grid(columns: (1fr, auto),
      align(left)[#deck-title.get()],
      align(right)[#counter(page).display()],
    )
  ])
  block(width: 100%)[
    #if tag != none [ #pill(tag) #v(1pt) ]
    #if title != none [
      #text(size: 22pt, weight: "bold", fill: c-fg, title)
      #v(-3pt)
      #line(length: 100%, stroke: 1.5pt + c-accent)
    ]
  ]
  v(4pt)
  set text(size: 15pt)
  body
  pagebreak(weak: true)
}

// ---------- Slide de seccion ----------
#let section-slide(num, title) = {
  set page(footer: none)
  set align(horizon)
  block(width: 100%)[
    #text(size: 15pt, fill: c-accent, weight: "bold")[PUNTO #num]
    #v(4pt)
    #text(size: 34pt, weight: "bold", fill: c-fg, title)
  ]
  pagebreak(weak: true)
}

// ---------- Portada ----------
#let title-slide(title: "", subtitle: "", authors: (), course: "", date: "") = {
  set page(footer: none)
  set align(horizon)
  block(width: 100%)[
    #text(size: 14pt, fill: c-accent, weight: "bold")[#course]
    #v(10pt)
    #text(size: 34pt, weight: "bold", fill: c-fg, title)
    #v(2pt)
    #text(size: 18pt, fill: c-muted, subtitle)
    #v(14pt)
    #line(length: 38%, stroke: 1.5pt + c-accent)
    #v(10pt)
    #for a in authors [ #text(size: 15pt, fill: c-fg)[#a] #linebreak() ]
    #v(4pt)
    #text(size: 14pt, fill: c-muted, date)
  ]
  pagebreak(weak: true)
}

// ---------- Caja de panel (para notas / destacados) ----------
#let panel(title: none, fill: c-panel, stroke-c: c-line, body) = block(
  width: 100%, fill: fill, inset: 8pt, radius: 6pt,
  stroke: 1pt + stroke-c,
)[
  #if title != none [ #text(weight: "bold", fill: c-accent, size: 13.5pt, title) #v(2pt) ]
  #set text(size: 13pt)
  #body
]

// ---------- Caja de bloque tipo "diagrama" ----------
#let dblock(txt, fill: c-blue) = box(
  fill: fill.lighten(0%), inset: (x: 10pt, y: 8pt), radius: 6pt,
  stroke: 1pt + fill.lighten(25%),
)[#text(size: 14pt, weight: "bold", fill: white, align(center, txt))]

// ---------- Cadena de bloques (flujo) ----------
// Flecha de conexión, centrada verticalmente con los bloques.
#let arr = text(size: 17pt, fill: c-muted, baseline: 0pt)[→]

// Coloca dblocks y flechas alineados al centro vertical.
#let flow(..items) = align(center, grid(
  columns: items.pos().len() * (auto,),
  align: horizon, column-gutter: 7pt,
  ..items.pos(),
))

// ---------- Imagen enmarcada ----------
// Marco exterior del color del fondo (esquinas redondeadas) + borde de acento menor.
#let framed-image(path, height: auto) = box(
  fill: c-img-bg, radius: 9pt, inset: 10pt, stroke: 1pt + c-accent,
)[
  #image(path, height: height)
]

// ---------- KPI grande ----------
#let kpi(value, label, color: c-accent) = block(
  width: 100%, fill: c-panel, inset: 9pt, radius: 6pt, stroke: 1pt + c-line,
)[
  #align(center)[
    #text(size: 26pt, weight: "bold", fill: color, value) #v(2pt)
    #text(size: 12pt, fill: c-muted, label)
  ]
]
