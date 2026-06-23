#import "template2.typ": *

#show: body => slides-setup(
  title: "Filtro de interpolación L=4 — GF180MCU",
  body,
)

#let sim-space(title, caption, height: 4.4cm) = block(
  width: 100%, height: height, fill: c-panel, inset: 12pt,
  radius: 5pt, stroke: 1pt + c-line,
)[
  #align(center)[
    #v(20pt)
    #pill("ESPACIO PARA CAPTURA")
    #v(10pt)
    #text(size: 15pt, weight: "bold", fill: c-fg, title)
    #v(5pt)
    #text(size: 11pt, fill: c-muted, caption)
  ]
]

#let img-card(path, title, caption: none, img-height: 5cm) = block(
  width: 100%, fill: c-panel, inset: 8pt,
  radius: 5pt, stroke: 1pt + c-line,
)[
  #text(size: 12.2pt, weight: "bold", fill: c-accent, title)
  #v(4pt)
  #align(center)[#image(path, width: 100%, height: img-height, fit: "contain")]
  #if caption != none [
    #v(3pt)
    #text(size: 9.8pt, fill: c-muted, caption)
  ]
]

#let ablock(txt, fill: c-accent-soft) = box(
  fill: fill,
  inset: (x: 7pt, y: 5pt),
  radius: 4pt,
  stroke: 0.8pt + c-line,
)[#text(size: 10.4pt, weight: "bold", fill: c-fg, align(center, txt))]

#let arr-small = text(size: 13pt, fill: c-accent)[→]

#let point-divider(point, title) = {
  set page(footer: context [
    #set text(size: 8.5pt, fill: c-muted)
    #grid(columns: (1fr, auto),
      align(left)[Filtro de interpolación L=4 — GF180MCU],
      align(right)[#counter(page).display()],
    )
  ])
  v(3.1cm)
  align(center)[
    #pill(point)
    #v(16pt)
    #text(size: 42pt, weight: "bold", fill: c-fg, point)
    #v(8pt)
    #text(size: 22pt, fill: c-muted, title)
    #v(16pt)
    #line(length: 24%, stroke: 2pt + c-accent)
  ]
  pagebreak(weak: true)
}

// ============================================================
// PORTADA
// ============================================================
#title-slide(
  course: "IEE3753 · Diseño Digital · Proyecto",
  title: "Filtro de interpolación lineal",
  subtitle: "Arquitectura, configuración circuital y simulación transiente · GF180MCU",
  authors: (
    "Mateo de la Cuadra",
    "Vicente Florez",
    "Alonso Rivera",
  ),
  date: "Junio 2026",
)

// ============================================================
// 1. IMPLEMENTACIÓN DEL FILTRO
// ============================================================
#point-divider("Punto 1", "Implementación del filtro propuesta")

#slide(title: "Implementación del filtro propuesta", tag: "PUNTO 1")[
  #grid(columns: (0.95fr, 1.05fr), gutter: 13pt,
    panel(title: "Cuatro fases entre muestras")[
      #phase-card("φ0", [$(3 x_"old" + x_"new") / 4$], "25 %")
      #v(4pt)
      #phase-card("φ1", [$(x_"old" + x_"new") / 2$], "50 %")
      #v(4pt)
      #phase-card("φ2", [$(x_"old" + 3 x_"new") / 4$], "75 %")
      #v(4pt)
      #phase-card("φ3", [$x_"new"$], "100 %")
    ],
    [
      #panel(title: "Formato numérico Q4.2", fill: c-accent-soft, stroke-c: c-accent)[
        La entrada es una muestra sin signo de *4 bits*. La salida usa *6 bits*: cuatro para la parte entera y dos LSB para representar incrementos de $1/2$ y $1/4$.
        #v(7pt)
        #align(center)[#text(size: 18pt, weight: "bold")[[ b5 b4 b3 b2 . b1 b0 ]]]
      ]
      #v(7pt)
      #panel(title: "Implementación sin multiplicadores")[
        Definiendo $S=x_"old"+x_"new"$, el circuito genera los códigos $Y_k=4phi_k$:
        #v(4pt)
        $Y_0=S+2x_"old"$, $Y_1=2S$,
        $Y_2=S+2x_"new"$, $Y_3=4x_"new"$.
        #v(5pt)
        Los factores 2 y 4 se implementan mediante desplazamientos de cableado.
      ]
    ],
  )
  #v(7pt)
  #panel(fill: c-panel)[
    #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
      [*Entrada:* 0 a 15],
      [*Salida representable:* 0 a 63],
      [*Resolución:* $1/4 = 0.25$],
    )
  ]
]

#slide(title: "Datapath aritmético", tag: "PUNTO 1")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    panel(title: "Etapa 1 · pseudo-CLA-NoCin de 4 bits", fill: c-accent-soft, stroke-c: c-accent)[
      #align(center)[
        #dblock([$x_"old"[3:0]$]) #h(5pt) + #h(5pt) #dblock([$x_"new"[3:0]$])
        #v(8pt)
        #text(size: 17pt, fill: c-accent)[↓]
        #v(5pt)
        #dblock([pseudo-CLA 4 b · `Cin = 0`])
        #v(7pt)
        #text(size: 17pt, fill: c-accent)[↓]
        #v(4pt)
        #text(size: 17pt, weight: "bold")[$S[4:0]$]
      ]
    ],
    panel(title: "Etapa 2 · pseudo-CLA-NoCin de 5 bits")[
      - $Y_0=S+(x_"old" << 1)$ → $phi_0$.
      - $Y_2=S+(x_"new" << 1)$ → $phi_2$.
      - $Y_1=S << 1$ → $phi_1$ por cableado.
      - $Y_3=x_"new" << 2$ → $phi_3$ por cableado.
      #v(7pt)
      El carry de salida del adder de 5 bits completa el sexto bit de $Y_0$ y $Y_2$.
      #v(7pt)
      Se mantienen *dos adders de 5 bits*, pues el MUX interno para compartirlos no fue implementado.
    ],
  )
  #v(9pt)
  #flow(
    dblock([Suma compartida#v(1pt)$S$]), arr,
    dblock([$phi_0$#v(1pt)CLA 5 b]), arr,
    dblock([$phi_1$#v(1pt)cableado]), arr,
    dblock([$phi_2$#v(1pt)CLA 5 b]), arr,
    dblock([$phi_3$#v(1pt)cableado]),
  )
]

// ============================================================
// 2. DIAGRAMA GENERAL
// ============================================================
#point-divider("Punto 2", "Diagrama general de arquitectura propuesta")

#slide(title: "Diagrama general de la arquitectura", tag: "PUNTO 2")[
  #grid(columns: (1.55fr, 0.45fr), gutter: 11pt,
    [
      #panel(title: "Camino de datos registrado", fill: c-accent-soft, stroke-c: c-accent)[
        #arch-datapath
      ]
      #v(6pt)
      #panel(title: "Señales calculadas por ciclo")[
        El núcleo calcula $S=x_"old"+x_"new"$ y reutiliza ese resultado para construir $phi_0$ y $phi_2$ con adders de 5 bits. El registro de salida agregado desacopla el MUX de la carga externa y reduce el ripple observado en la salida.
      ]
    ],
    [
      #panel(title: "Camino de control")[
        #arch-control
      ]
      #v(6pt)
      #panel(title: "Orden de salida", fill: c-panel)[
        `00` → $phi_0$ #linebreak()
        `01` → $phi_1$ #linebreak()
        `10` → $phi_2$ #linebreak()
        `11` → $phi_3$
      ]
    ],
  )
]

#slide(title: "Datapath detallado registrado", tag: "PUNTO 2")[
  #align(center)[#arch-datapath-full]
]

// ============================================================
// 3. CONFIGURACIONES CIRCUITALES
// ============================================================
#point-divider("Punto 3", "Configuraciones circuitales elegidas")

#slide(title: "Adders elegidos", tag: "PUNTO 3 · ADDERS")[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), gutter: 8pt, align: horizon,
    panel(title: "RCA inicial")[
      Carry en serie y retardo creciente con el número de bits.
    ],
    arr,
    panel(title: "CLA-NoCin")[
      Celdas específicas de *4 y 5 bits*. `Cin` se eliminó y se fijó a GND.
    ],
    arr,
    panel(title: "pseudo-NMOS")[
      Las NOR del árbol de carry usan carga pseudo-NMOS para reducir el retardo.
    ],
  )
  #v(11pt)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi([$alpha=W_p/W_n=0.9$], "valor seleccionado empíricamente"),
    kpi("3.3 GHz", "pseudo-CLA 4 b · FF ideales"),
    kpi("2.5 GHz", "pseudo-CLA 5 b · FF ideales"),
  )
  #v(9pt)
  #panel(fill: c-panel)[
    La configuración pseudo-NMOS aumentó la frecuencia en la mayoría de las transiciones medidas. Estas cifras caracterizan únicamente los adders; no incluyen el retardo de los flip-flops reales.
  ]
]

#slide(title: "Flip-flops evaluados y registros del sistema", tag: "PUNTO 3 · FLIP-FLOPS")[
  #grid(columns: (0.9fr, 1.1fr), gutter: 14pt,
    [
      #kpi("≈ 300 ps", "retardo del DFF real")
      #v(8pt)
      #kpi("≈ 130 ps", "retardo del SDFF_improved aislado")
      #v(8pt)
      #panel(fill: c-accent-soft, stroke-c: c-accent)[
        El DFF real limita la versión original a *1.46 GHz*. Al agregar un registro de salida, la alternativa *SDFF_improved* se vuelve viable porque el ripple queda desacoplado de la salida observada.
      ]
    ],
    [
      #table(
        columns: (1.45fr, 0.55fr), inset: 7pt, align: (left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Registros del sistema*], [*FF*],
        [Entrada registrada], [4],
        [Registros de fase: 4 × 6], [24],
        [Salida registrada], [6],
        [Contador de fase], [2],
        [*Total implementado*], [*36*],
      )
      #v(8pt)
      #panel(title: "Configuración seleccionada")[
        La versión final usa el arreglo de salida para estabilizar la respuesta. Con esto se acepta la implementación con *SDFF_improved* a 1.8 GHz.
      ]
      #v(8pt)
      #pending(title: "Optimización pendiente")[
        Bastaría con *33 FF*: $phi_3$ no requiere bits de resolución extra y $phi_1$ solo necesita un bit fraccional para representar $1/2$.
      ]
    ],
  )
]

#slide(title: "MUX, contador y decoder", tag: "PUNTO 3 · CONTROL")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 14pt,
    [
      #table(
        columns: (0.55fr, 0.55fr, 0.85fr, 1.2fr), inset: 7pt,
        align: (center, center, center, left),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Counter*], [*Fase*], [*Posición*], [*Código seleccionado*],
        [`00`], [$phi_0$], [25 %], [$S+2x_"old"$],
        [`01`], [$phi_1$], [50 %], [$2S$],
        [`10`], [$phi_2$], [75 %], [$S+2x_"new"$],
        [`11`], [$phi_3$], [100 %], [$4x_"new"$],
      )
      #v(11pt)
      #flow(
        dblock([Contador#v(1pt)2 bits]), arr,
        dblock([Decoder#v(1pt)one-hot]), arr,
        dblock([MUX 4:1#v(1pt)6 bits]), arr,
        dblock([Salida]),
      )
    ],
    [
      #kpi("28", "compuertas · MUX 4:1")
      #v(7pt)
      #kpi("3", "compuertas · contador 2 b")
      #v(7pt)
      #kpi("9", "compuertas · decoder")
      #v(7pt)
      #text(size: 10.5pt, fill: c-muted)[Las transmission gates del MUX se contabilizan como compuertas.]
    ],
  )
]

#slide(title: "Conteo total de compuertas", tag: "PUNTO 3 · ÁREA")[
  #grid(columns: (1.05fr, 0.95fr), gutter: 15pt,
    [
      #table(
        columns: (1.45fr, 0.55fr), inset: 7pt, align: (left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Bloque combinacional*], [*Compuertas*],
        [1× pseudo-CLA-NoCin de 4 bits], [48],
        [2× pseudo-CLA-NoCin de 5 bits], [146],
        [Contador de 2 bits], [3],
        [Decoder], [9],
        [MUX 4:1 de 6 bits], [28],
        [*Total*], [*234*],
      )
    ],
    [
      #kpi("194", "compuertas · núcleo aritmético")
      #v(8pt)
      #kpi("40", "compuertas · MUX y control")
      #v(8pt)
      #panel(title: "Detalle del pseudo-CLA de 4 bits")[
        14 NAND + 3 NOR pseudo-NMOS + 7 XNOR + 24 INVx1 = *48 compuertas*.
      ]
      #v(7pt)
      #text(size: 10.5pt, fill: c-muted)[El total excluye los 36 flip-flops y buffers de entrada/salida.]
    ],
  )
]

// ============================================================
// 4. SIMULACIÓN TRANSIENTE FUNCIONAL
// ============================================================
#point-divider("Punto 4", "Simulación transiente: funcionamiento correcto")

#slide(title: "Simulación transiente: funcionamiento correcto", tag: "PUNTO 4")[
  #grid(columns: (1.35fr, 0.65fr), gutter: 14pt,
    img-card(
      "imgs/Resultados finales/1.46G Nominal.jpeg",
      "DFF original · 1.46 GHz nominal",
      caption: "Test funcional usado como referencia: fases ordenadas y salida Q4.2 correcta.",
      img-height: 6.8cm,
    ),
    [
      #panel(title: "Qué debe observarse")[
        - Cuatro fases ordenadas por cada par de muestras.
        - Valores intermedios $phi_0$, $phi_1$ y $phi_2$.
        - $phi_3=x_"new"$.
        - Dos LSB representando cuartos de unidad.
        - Sin selecciones duplicadas ni fases omitidas.
      ]
      #v(8pt)
      #panel(title: "Punto de operación nominal", fill: c-accent-soft, stroke-c: c-accent)[
        Se deja como simulación funcional base la versión con *DFF real* operando a *1.46 GHz*.
        #v(4pt)
        *Potencia medida:* 34.99 mW.
      ]
    ],
  )
]

// ============================================================
// 5. FRECUENCIA MÁXIMA Y POTENCIA
// ============================================================
#point-divider("Punto 5", "Máxima frecuencia de operación y potencia")

#slide(title: "Frecuencia máxima aceptada y potencia", tag: "PUNTO 5")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 14pt,
    img-card(
      "imgs/Resultados finales/1.8G FF real (+ideal).jpeg",
      "SDFF_improved · 1.8 GHz",
      caption: "Máxima frecuencia aceptada con onda completa correcta en la salida.",
      img-height: 6.8cm,
    ),
    [
      #kpi("1.8 GHz", "máxima frecuencia aceptada")
      #v(7pt)
      #kpi("≈ 556 ps", "período de reloj")
      #v(7pt)
      #kpi("≈ 130 ps", "retardo del SDFF_improved aislado")
      #v(7pt)
      #panel(title: "Potencia consumida", fill: c-accent-soft, stroke-c: c-accent)[
        *P = 45.75 mW*
        #v(3pt)
        Valor medido para la simulación transiente final a 1.8 GHz.
      ]
    ],
  )
]

#slide(title: "Respaldo de mejora: salida ideal a 2 GHz", tag: "PUNTO 5 · RESPALDO")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 14pt,
    img-card(
      "imgs/Resultados finales/2G FF ideal.jpeg",
      "Referencia con FF ideal solo a la salida · 2.0 GHz",
      caption: "Muestra que el datapath puede sostener 2 GHz si el desacople final no introduce retardo real.",
      img-height: 5.6cm,
    ),
    [
      #panel(title: "Lectura del resultado")[
        El arreglo de salida redujo el ripple y permitió que *SDFF_improved* fuera una alternativa viable. Con FF real se aceptó 1.8 GHz; con un FF ideal solo a la salida se observa operación a 2 GHz.
      ]
      #v(8pt)
      #panel(title: "Comparación de alternativas", fill: c-panel)[
        HLFF y SDFF fueron evaluados para aumentar frecuencia. Se retiene *SDFF_improved*. La variante de 2 GHz queda como respaldo, porque depende de un FF ideal en la salida.
      ]
    ],
  )
]

// ============================================================
// 6. TABLA RESUMEN
// ============================================================
#point-divider("Punto 6", "Tabla resumen del sistema")

#slide(title: "Resumen del sistema", tag: "PUNTO 6")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 15pt,
    [
      #table(
        columns: (1.08fr, 1.45fr, 0.72fr), inset: 7pt,
        align: (left, left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Métrica*], [*Composición / condición*], [*Resultado*],
        [Flip-flops], [36 implementados; 33 mínimos optimizando $phi_3$ y $phi_1$], [*36 / 33*],
        [Compuertas], [Aritmética 194 + control/MUX 40], [*234*],
        [Funcional base], [DFF real original], [*1.46 GHz*],
        [Frecuencia máxima], [SDFF_improved con salida estable], [*1.8 GHz*],
        [Referencia ideal], [FF ideal solo a la salida], [*2.0 GHz*],
        [Retardos FF], [DFF real / SDFF_improved aislado], [*≈300 / ≈130 ps*],
        [Potencia], [DFF 1.46 GHz / SDFF 1.8 GHz], [*34.99 / 45.75 mW*],
      )
    ],
    [
      #kpi("36", "flip-flops implementados")
      #v(7pt)
      #kpi("1.8 GHz", "frecuencia máxima final")
      #v(7pt)
      #kpi("234", "compuertas combinacionales")
      #v(7pt)
      #kpi("33", "FF mínimos con optimización")
    ],
  )
]

// ============================================================
// 7. OTROS RESULTADOS / MEJORAS
// ============================================================
#point-divider("Punto 7", "Mejoras posibles y resultados de respaldo")

#slide(title: "Mejoras posibles a implementar", tag: "PUNTO 7")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 12pt,
    panel(title: "Reducir compuertas")[
      Implementar un MUX interno que entregue a un único CLA de 5 bits las entradas $S$ y $x_"old"$ o $x_"new"$ según la fase. Esto permitiría reemplazar los dos CLA5 actuales por uno compartido.
    ],
    panel(title: "Aumentar velocidad por dispositivo")[
      Ajustar el voltaje de base para reducir $V_"th"$ efectivo de los transistores. La ventaja esperada es menor delay; el costo debe evaluarse en potencia, robustez y variación de proceso.
    ],
    panel(title: "Optimizar MUX de salida")[
      Con SDFF_improved, el MUX pasa a ser un cuello de botella relevante. Buscar una celda MUX más rápida podría aumentar la frecuencia máxima sin cambiar el filtro.
    ],
  )
  #v(12pt)
  #panel(fill: c-panel)[
    Estas mejoras apuntan a dos frentes distintos: menor área combinacional mediante reutilización del CLA5, y mayor frecuencia mediante reducción de delays en celdas críticas.
  ]
]

// ============================================================
// CIERRE
// ============================================================
#{
  set page(footer: none)
  set align(center + horizon)
  block(width: 100%)[
    #align(center)[
      #pill("Fin")
      #v(14pt)
      #text(size: 44pt, weight: "bold", fill: c-fg)[Gracias]
      #v(16pt)
      #line(length: 28%, stroke: 2pt + c-accent)
      #v(16pt)po
    ]

    #align(center)[
      #text(size: 13pt, fill: c-muted)[Mateo de la Cuadra · Vicente Florez · Alonso Rivera]
    ]
  ]
  pagebreak(weak: true)
}

// ============================================================
// ANEXOS
// ============================================================
#slide(title: "Anexo: barrido de alpha en pseudo-CLA", tag: "ANEXO")[
  #grid(columns: (1fr, 1fr), gutter: 13pt,
    img-card(
      "imgs/Salida CLA para diferentes valores de alpha.jpeg",
      "Salida CLA para diferentes valores de alpha",
      img-height: 5.9cm,
    ),
    img-card(
      "imgs/Delays para diferentes alpha.jpeg",
      "Delays para diferentes alpha",
      img-height: 5.9cm,
    ),
  )
  #v(7pt)
  #panel(fill: c-panel)[
    El valor seleccionado fue $alpha=W_p/W_n=0.9$, elegido empíricamente por entregar mejores tiempos en la mayoría de las transiciones evaluadas.
  ]
]

#slide(title: "Anexo: adders con DFF real", tag: "ANEXO")[
  #grid(columns: (1fr, 1fr), gutter: 13pt,
    img-card(
      "imgs/CLA 4bit con DFF real.jpeg",
      "CLA 4bit con DFF real",
      img-height: 5.9cm,
    ),
    img-card(
      "imgs/CLA 5bit con DFF real.jpeg",
      "CLA 5bit con DFF real",
      img-height: 5.9cm,
    ),
  )
]
