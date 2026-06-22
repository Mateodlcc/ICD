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
#slide(title: "Diagrama general de la arquitectura", tag: "PUNTO 2")[
  #v(5pt)
  #flow(
    dblock([Entrada#v(1pt)`x[3:0]`]), arr,
    dblock([Núcleo#v(1pt)CLA 4 b + 2×CLA 5 b]), arr,
    dblock([Separación#v(1pt)6 DFF]), arr,
    dblock([Registros de fase#v(1pt)4×6 DFF]), arr,
    dblock([MUX 4:1#v(1pt)6 bits]), arr,
    dblock([Salida#v(1pt)`o_D[5:0]`]),
  )
  #v(14pt)
  #grid(columns: (1.3fr, 0.7fr), gutter: 14pt,
    panel(title: "Camino de datos")[
      1. Se captura la muestra y se conserva la anterior.
      2. El núcleo calcula las cuatro fases en formato Q4.2.
      3. Se registran 6 bits por fase para estabilizar los resultados.
      4. El MUX entrega una fase por ciclo según el estado del contador.
    ],
    panel(title: "Camino de control", fill: c-panel)[
      #align(center)[
        #dblock([Contador 2 bits])
        #v(5pt)
        #text(size: 17pt, fill: c-accent)[↓]
        #v(4pt)
        #dblock([Decoder one-hot])
        #v(5pt)
        #text(size: 17pt, fill: c-accent)[↓]
        #v(4pt)
        #dblock([Selección MUX 4:1])
      ]
    ],
  )
]

// ============================================================
// 3. CONFIGURACIONES CIRCUITALES
// ============================================================
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

#slide(title: "Flip-flop elegido y cuello de botella", tag: "PUNTO 3 · FLIP-FLOPS")[
  #grid(columns: (0.9fr, 1.1fr), gutter: 14pt,
    [
      #kpi("≈ 300 ps", "retardo del DFF tipo D real")
      #v(8pt)
      #kpi("1.45 GHz", "máxima frecuencia aceptada en simulación")
      #v(8pt)
      #panel(fill: c-accent-soft, stroke-c: c-accent)[
        El DFF real es el *cuello de botella actual*. Su retardo consume una fracción importante del período de ≈ 690 ps disponible a 1.45 GHz.
      ]
    ],
    [
      #table(
        columns: (1.45fr, 0.55fr), inset: 7pt, align: (left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Registros del sistema*], [*DFF*],
        [Registros de fase: 4 × 6], [24],
        [Contador de fase], [2],
        [Separación de entrada / estabilización], [6],
        [*Total*], [*32*],
      )
      #v(8pt)
      #panel(title: "Configuración seleccionada")[
        Se mantiene el *DFF tipo D* porque entrega una salida estable y sin ripple dentro del rango aceptado.
      ]
      #v(8pt)
      #pending(title: "Alternativas descartadas")[
        HLFF y SDFF operaron sobre 2 GHz, pero introdujeron ripple. Las capturas comparativas se presentan en el Punto 5.
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
      #text(size: 10.5pt, fill: c-muted)[El total excluye los 32 flip-flops y buffers de entrada/salida.]
    ],
  )
]

// ============================================================
// 4. SIMULACIÓN TRANSIENTE FUNCIONAL
// ============================================================
#slide(title: "Simulación transiente: funcionamiento correcto", tag: "PUNTO 4")[
  #grid(columns: (1.35fr, 0.65fr), gutter: 14pt,
    sim-space(
      "Forma de onda del test funcional",
      "Insertar captura con entrada, contador, selección y salida Q4.2.",
      height: 7.2cm,
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
        El circuito fue verificado primero a *1 GHz* con resultados funcionales satisfactorios.
      ]
    ],
  )
]

// ============================================================
// 5. FRECUENCIA MÁXIMA Y POTENCIA
// ============================================================
#slide(title: "Frecuencia máxima aceptada y potencia", tag: "PUNTO 5")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 14pt,
    sim-space(
      "Simulación del sistema a 1.45 GHz",
      "Insertar captura del último test sin ripple ni errores de fase.",
      height: 7.1cm,
    ),
    [
      #kpi("1.45 GHz", "máxima frecuencia aceptada")
      #v(7pt)
      #kpi("≈ 690 ps", "período de reloj")
      #v(7pt)
      #kpi("≈ 300 ps", "retardo del DFF real")
      #v(7pt)
      #pending(title: "Potencia consumida")[
        *P = [COMPLETAR] mW*
        #v(3pt)
        Incorporar el valor medido en el mismo test a 1.45 GHz, indicando tensión, corner y promedio temporal.
      ]
    ],
  )
]

#slide(title: "Alternativas sobre 2 GHz: ripple no aceptable", tag: "PUNTO 5 · RESPALDO")[
  #grid(columns: (1fr, 1fr), gutter: 13pt,
    sim-space(
      "HLFF a 2 GHz+",
      "Insertar captura destacando el ripple sobre la rampa de salida.",
      height: 5.4cm,
    ),
    sim-space(
      "SDFF a 2 GHz+",
      "Insertar captura destacando las transiciones espurias.",
      height: 5.4cm,
    ),
  )
  #v(9pt)
  #grid(columns: (1.15fr, 0.85fr), gutter: 13pt,
    panel(title: "Resultado de la comparación")[
      HLFF y SDFF permiten una mayor frecuencia y conservan una rampa macroscópicamente correcta. Sin embargo, el ripple introduce múltiples cruces de umbral y puede propagarse como errores digitales.
    ],
    pending(title: "Decisión")[
      Se priorizó integridad de señal sobre frecuencia máxima aparente. El *DFF tipo D* se mantiene como flip-flop del sistema.
    ],
  )
]

// ============================================================
// 6. TABLA RESUMEN
// ============================================================
#slide(title: "Resumen del sistema", tag: "PUNTO 6")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 15pt,
    [
      #table(
        columns: (1.2fr, 1.35fr, 0.65fr), inset: 8pt,
        align: (left, left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Métrica*], [*Composición / condición*], [*Resultado*],
        [Flip-flops], [4 fases × 6 + counter 2 + separación 6], [*32*],
        [Compuertas], [Aritmética 194 + control/MUX 40], [*234*],
        [Frecuencia máxima], [DFF real sin ripple], [*1.45 GHz*],
        [Retardo del DFF], [DFF tipo D seleccionado], [*≈ 300 ps*],
        [Potencia consumida], [Test transiente a 1.45 GHz], [*[PENDIENTE]*],
      )
    ],
    [
      #kpi("32", "flip-flops totales")
      #v(8pt)
      #kpi("1.45 GHz", "frecuencia máxima simulada")
      #v(8pt)
      #kpi("234", "compuertas combinacionales")
    ],
  )
  #v(10pt)
  #panel(fill: c-accent-soft, stroke-c: c-accent)[
    #set text(size: 14pt)
    *Conclusión:* los adders superan individualmente los 2.5 GHz, pero el DFF real limita el sistema completo a 1.45 GHz. Las alternativas más rápidas se descartaron por ripple.
  ]
]
