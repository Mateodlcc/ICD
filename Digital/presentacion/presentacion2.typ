#import "template2.typ": *

#show: body => slides-setup(
  title: "Filtro de interpolación L=4 — GF180MCU",
  body,
)

// ============================================================
// PORTADA
// ============================================================
#title-slide(
  course: "IEE3753 · Diseño Digital · Proyecto",
  title: "Filtro de interpolación lineal",
  subtitle: "Arquitectura actualizada y validación a nivel de transistor · GF180MCU",
  authors: (
    "Mateo de la Cuadra",
    "Vicente Florez",
    "Alonso Rivera",
  ),
  date: "Junio 2026",
)

// ============================================================
// ESTADO DEL PROYECTO
// ============================================================
#slide(title: "Qué cambió desde el avance anterior", tag: "ESTADO ACTUAL")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    panel(title: "Arquitectura aplicada")[
      - Entrada muestreada de *4 bits*.
      - Dos bits fraccionales en la salida.
      - Cuatro fases de interpolación.
      - Reutilización de $S=x_"old"+x_"new"$.
    ],
    panel(title: "Circuitos validados")[
      - CLA de *4 y 5 bits* sin `Cin`.
      - NOR en lógica *pseudo-NMOS*.
      - DFF tipo D reales.
      - Operación funcional a *1 GHz*.
    ],
    pending(title: "Aún pendiente")[
      - MUX interno entre los caminos $phi_0/phi_2$.
      - Desacople temporal entre etapas.
      - Conteo final de flip-flops.
      - Sign-off de frecuencia máxima.
    ],
  )
  #v(7pt)
  #panel(fill: c-panel)[
    #set text(size: 13.5pt)
    Esta presentación usa únicamente resultados de la arquitectura actual. Las cifras proyectadas se distinguen de las mediciones ya verificadas.
  ]
]

// ============================================================
// PUNTO 1 — IMPLEMENTACIÓN
// ============================================================
#slide(title: "Interpolación lineal con cuatro fases", tag: "PUNTO 1")[
  #grid(columns: (0.95fr, 1.05fr), gutter: 13pt,
    [
      #panel(title: "Secuencia emitida entre dos muestras")[
        #phase-card("φ0", [$(3 x_"old" + x_"new") / 4$], "25 %")
        #v(4pt)
        #phase-card("φ1", [$(x_"old" + x_"new") / 2$], "50 %")
        #v(4pt)
        #phase-card("φ2", [$(x_"old" + 3 x_"new") / 4$], "75 %")
        #v(4pt)
        #phase-card("φ3", [$x_"new"$], "100 %")
      ]
    ],
    [
      #panel(title: "Formato numérico: salida Q4.2", fill: c-accent-soft, stroke-c: c-accent)[
        La entrada es un entero sin signo de 4 bits. La salida conserva esos 4 bits y agrega *2 LSB fraccionales*: cada código representa cuartos de unidad.
        #v(6pt)
        #align(center)[
          #text(size: 17pt, weight: "bold")[[ b5 b4 b3 b2 . b1 b0 ]]
        ]
      ]
      #v(6pt)
      #panel(title: "Consecuencia de implementación")[
        El hardware genera directamente $Y_k=4 phi_k$:
        #v(3pt)
        $Y_0=S+2x_"old"$, $Y_1=2S$,
        $Y_2=S+2x_"new"$, $Y_3=4x_"new"$.
        #v(5pt)
        Los factores 2 y 4 se logran con shifts (desplazamientos de los cables) y no requieren multiplicadores ni divisores.
      ]
    ],
  )
  #v(7pt)
  #panel(fill: c-panel)[
    #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
      [*Entrada:* 0 a 15 (4 bits)],
      [*Código de salida:* 0 a 63 (Q4.2)],
      [*Resolución:* $1/4 = 0.25$],
    )
  ]
]

// ============================================================
// PUNTO 2 — ARQUITECTURA GENERAL
// ============================================================
#slide(title: "Arquitectura general implementada", tag: "PUNTO 2")[
  #v(5pt)
  #flow(
    dblock([Entrada#v(1pt)`x[3:0]`]), arr,
    dblock([Registro#v(1pt)$x_"old" / x_"new"$]), arr,
    dblock([Núcleo aritmético#v(1pt)CLA 4 b + CLA 5 b]), arr,
    dblock([MUX 4:1#v(1pt)6 bits]), arr,
    dblock([DFF salida#v(1pt)`o_D[5:0]`]),
  )
  #v(15pt)
  #grid(columns: (1.35fr, 0.65fr), gutter: 14pt,
    panel(title: "Camino de datos")[
      1. Se captura la muestra nueva y se conserva la anterior.
      2. El CLA de 4 bits calcula $S=x_"old"+x_"new"$.
      3. La segunda etapa obtiene $phi_0$ y $phi_2$; $phi_1$ y $phi_3$ salen por cableado.
      4. El MUX presenta una fase por ciclo en el registro de salida.
    ],
    panel(title: "Camino de control", fill: c-panel)[
      *Contador de 4 fases*
      #v(4pt)
      #text(size: 17pt, fill: c-accent)[↓]
      #v(4pt)
      *Decoder one-hot*
      #v(4pt)
      #text(size: 17pt, fill: c-accent)[↓]
      #v(4pt)
      Selección del MUX y muestreo de la fase correcta.
    ],
  )
]

// ============================================================
// PUNTO 3 — JUSTIFICACIÓN Y DATAPATH
// ============================================================
#slide(title: "Datapath: una suma compartida", tag: "PUNTOS 3 Y 7")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 13pt,
    [
      #panel(title: "Etapa 1 · CLA-NoCin de 4 bits", fill: c-accent-soft, stroke-c: c-accent)[
        #align(center)[
          #dblock([$x_"old"[3:0]$]) #h(5pt) + #h(5pt) #dblock([$x_"new"[3:0]$])
          #v(7pt)
          #text(size: 17pt, fill: c-accent)[↓]
          #v(5pt)
          #dblock([CLA 4 b · `(Cin = 0)`])
          #v(6pt)
          #text(size: 17pt, fill: c-accent)[↓]
          #v(4pt)
          #text(size: 16pt, weight: "bold")[$S[4:0]$]
        ]
      ]
    ],
    [
      #panel(title: "Etapa 2 · CLA-NoCin de 5 bits")[
        - $Y_0=S+(x_"old" << 1)$ → 6 bits.
        - $Y_2=S+(x_"new" << 1)$ → 6 bits.
        - $Y_1=S << 1$ → solo cableado.
        - $Y_3=x_"new" << 2$ → solo cableado.
        #v(5pt)
        El carry de salida del CLA de 5 bits completa el sexto bit.
      ]
      #v(6pt)
      #pending(title: "Optimización no implementada")[
        Compartir un único CLA de 5 bits mediante un MUX entre $2x_"old"$ y $2x_"new"$. Por ahora, $phi_0$ y $phi_2$ mantienen caminos separados.
      ]
    ],
  )
  #v(7pt)
  #grid(columns: (1fr, 1fr, 1fr, 1fr), gutter: 8pt,
    panel(title: "φ0")[CLA 5 b · camino crítico],
    panel(title: "φ1")[Shift de $S$ · cableado],
    panel(title: "φ2")[CLA 5 b · segundo camino],
    panel(title: "φ3")[Shift de $x_"new"$ · cableado],
  )
]

#slide(title: "Evolución del sumador", tag: "PUNTO 3")[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), gutter: 8pt, align: horizon,
    panel(title: "1 · RCA inicial")[
      El carry se propagaba en serie. Era simple, pero el retardo crecía con cada bit y limitaba la frecuencia.
    ],
    arr,
    panel(title: "2 · CLA-NoCin")[
      Se diseñaron celdas específicas de *4 y 5 bits*. `Cin` se eliminó y se fijó implícitamente a GND.
    ],
    arr,
    panel(title: "3 · Pseudo-NMOS")[
      Las NOR del árbol de carry se reemplazaron por versiones pseudo-NMOS para reducir retardo.
    ],
  )
  #v(10pt)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi([$alpha = W_p/W_n = 0.9$], "seleccionado empíricamente"),
    kpi("3.3 GHz", "máximo del CLA 4 b · FF ideales"),
    kpi("2.5 GHz", "máximo del CLA 5 b · FF ideales"),
  )
  #v(8pt)
  #panel(fill: c-panel)[
    La mejora aumentó la frecuencia en la mayoría de los casos medidos, tanto para transiciones de subida como de bajada. La selección de $alpha$ es empírica y corresponde al mejor compromiso observado.
  ]
]

// ============================================================
// PUNTO 4 — COMPUERTAS
// ============================================================
#slide(title: "Conteo de compuertas de los CLA", tag: "PUNTO 4")[
  #grid(columns: (1.1fr, 0.9fr), gutter: 15pt,
    [
      #table(
        columns: (1.45fr, 0.55fr), inset: 8pt, align: (left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*pseudo-CLA-NoCin de 4 bits*], [*Cantidad*],
        [NAND], [14],
        [NOR pseudo-NMOS (2, 3 y 4 entradas)], [3],
        [XNOR], [7],
        [INVx1], [24],
        [*Total*], [*48*],
      )
      #v(7pt)
      #panel(fill: c-panel)[
        El pseudo-CLA de 4 bits bajó de *84 a 48 compuertas*: una reducción de *36 compuertas* (≈ 43 %).
      ]
    ],
    [
      #kpi("73", "compuertas por pseudo-CLA-NoCin de 5 bits")
      #v(7pt)
      #panel(title: "Extensión de 4 a 5 bits")[
        Se agregan las funciones asociadas a:
        - 1 celda PG adicional.
        - 1 celda de suma adicional.
        - Generación de $C_4$.
        #v(4pt)
        Incremento total: *25 compuertas*.
      ]
      #v(7pt)
      #panel(title: "Aritmética actualmente duplicada")[
        Con 1× pseudo-CLA-4b y 2× pseudo-CLA-5b para $phi_0/phi_2$:
        #align(center)[#text(size: 19pt, weight: "bold", fill: c-accent)[48 + 2·73 = 194]]
        #text(size: 10.5pt, fill: c-muted)[No incluye MUX, control ni DFF.]
      ]
    ],
  )
]

// ============================================================
// PUNTO 5 — FLIP-FLOPS
// ============================================================
#slide(title: "Flip-flops reales y desacople", tag: "PUNTO 5")[
  #grid(columns: (1.05fr, 0.95fr), gutter: 14pt,
    [
      #table(
        columns: (1.45fr, 0.55fr), inset: 7pt, align: (left, right),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Registro estructural*], [*DFF*],
        [$x_"old"$ (4 bits)], [4],
        [$x_"new"$ (4 bits)], [4],
        [Salida Q4.2 (6 bits)], [6],
        [Contador de fase (2 bits)], [2],
        [*Subtotal sin pipeline*], [*16*],
      )
      #v(7pt)
      #pending(title: "Conteo final pendiente")[
        Deben sumarse los DFF de desacople entre etapas. Su cantidad depende de la partición temporal definitiva y no se reporta aún como total cerrado.
      ]
    ],
    [
      #kpi("≈ 300 ps", "retardo adicional del DFF real")
      #v(7pt)
      #panel(title: "Alternativas evaluadas")[
        Se probaron flip-flops pulsados y SDFF. Ambos presentaron ripple que produjo errores funcionales, por lo que se mantuvo el *DFF tipo D* convencional.
      ]
      #v(7pt)
      #panel(title: "Implicancia de timing", fill: c-panel)[
        La frecuencia del adder con FF ideales no representa la frecuencia del sistema. El retardo `clk→Q`, la lógica combinacional, el MUX y el setup del registro deben cerrar dentro del período disponible.
      ]
    ],
  )
  #v(7pt)
  #panel(fill: c-panel)[
    #align(center)[
      #text(size: 15pt, weight: "bold")[$N_"DFF,total" = 16 + N_"desacople"$]
      #h(10pt)
      #text(size: 11.5pt, fill: c-muted)[El segundo término se cerrará junto con la partición del pipeline.]
    ]
  ]
]

// ============================================================
// PUNTO 7 — CONTROL Y MUX
// ============================================================
#slide(title: "MUX 4:1 y secuencia de control", tag: "PUNTO 7 · DETALLE")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 14pt,
    [
      #table(
        columns: (0.6fr, 0.55fr, 0.85fr, 1.15fr), inset: 7pt,
        align: (center, center, center, left),
        stroke: 0.6pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Contador*], [*Fase*], [*Posición*], [*Código de salida*],
        [`00`], [$phi_0$], [25 %], [$S + 2x_"old"$],
        [`01`], [$phi_1$], [50 %], [$2S$],
        [`10`], [$phi_2$], [75 %], [$S + 2x_"new"$],
        [`11`], [$phi_3$], [100 %], [$4x_"new"$],
      )
      #v(10pt)
      #flow(
        dblock([Contador#v(1pt)2 bits]), arr,
        dblock([Decoder#v(1pt)one-hot]), arr,
        dblock([MUX 4:1#v(1pt)6 bits]), arr,
        dblock([DFF#v(1pt)salida]),
      )
    ],
    [
      #panel(title: "Función del decoder")[
        Convierte el estado del contador en la habilitación de la fase que debe muestrearse en cada ciclo.
      ]
      #v(7pt)
      #panel(title: "Ajuste necesario al pipeline", fill: c-panel)[
        Si se insertan DFF de desacople, la selección debe retardarse la misma cantidad de ciclos para conservar la correspondencia entre dato y fase.
      ]
    ],
  )
]

// ============================================================
// PUNTO 6 — FRECUENCIA
// ============================================================
#slide(title: "Camino crítico y frecuencia", tag: "PUNTO 6")[
  #grid(columns: (1.12fr, 0.88fr), gutter: 14pt,
    [
      #panel(title: "Peor camino observado", fill: c-accent-soft, stroke-c: c-accent)[
        #flow(
          dblock([$x_"old", x_"new"$]), arr,
          dblock([CLA 4 b#v(1pt)$S$]), arr,
          dblock([CLA 5 b#v(1pt)$phi_0$]), arr,
          dblock([captura]),
        )
        #v(6pt)
        $phi_0=(3x_"old"+x_"new")/4$ requiere primero $S$ y luego la segunda suma. Por eso define el camino crítico actual.
      ]
      #v(8pt)
      #panel(title: "Objetivo de desacople")[
        Introducir un desfase entre el cálculo de $S$ y la segunda suma para que ambos retardos no deban cerrarse como una sola etapa combinacional. Esto agrega latencia y DFF, pero protege la frecuencia.
      ]
    ],
    [
      #kpi("1.0 GHz", "verificado con resultados satisfactorios")
      #v(7pt)
      #kpi("≈ 1.667 GHz", "proyección · 600 ps por fase")
      #v(7pt)
      #panel(title: "Relación de tasas", fill: c-panel)[
        Se emite una fase por ciclo y una muestra de entrada por cada cuatro fases:
        $f_"in" = f_"fase"/4$.
      ]
      #v(7pt)
      #pending(title: "Interpretación correcta")[
        1.667 GHz es un objetivo teórico condicionado al desfase y al cierre con DFF, MUX y setup reales. Aún no es una frecuencia máxima validada del sistema completo.
      ]
    ],
  )
]

#slide(title: "Plan de desacople temporal", tag: "PUNTO 7 · DETALLE")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    panel(title: "Sin desacople · camino actual")[
      #flow(
        dblock([DFF#v(1pt)entrada]), arr,
        dblock([CLA#v(1pt)4 b]), arr,
        dblock([CLA#v(1pt)5 b]), arr,
        dblock([DFF#v(1pt)salida]),
      )
      #v(8pt)
      Un ciclo contiene las dos sumas encadenadas; el margen se reduce al incluir los retardos del registro y la selección.
    ],
    panel(title: "Con desfase · propuesta")[
      #flow(
        dblock([CLA#v(1pt)4 b]), arr,
        dblock([DFF#v(1pt)intermedio]), arr,
        dblock([CLA#v(1pt)5 b]),
      )
      #v(8pt)
      Se corta el camino crítico y se desplaza la fase de control. La latencia aumenta, pero el throughput puede mantenerse en una fase por ciclo.
    ],
  )
  #v(9pt)
  #pending(title: "Trabajo necesario antes de cerrar la arquitectura")[
    Definir la frontera exacta del registro, añadir sus bits de validez/selección, actualizar el decoder y volver a medir el circuito completo. Solo entonces puede cerrarse el conteo de FF y la frecuencia máxima.
  ]
  #v(8pt)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 9pt,
    kpi("1 fase/ciclo", "throughput esperado"),
    kpi("+1 ciclo", "latencia por registro intermedio"),
    kpi("+1 ciclo", "desfase del control y la selección"),
  )
]

// ============================================================
// PUNTO 8 — RESULTADOS Y CIERRE
// ============================================================
#slide(title: "Resultados actuales", tag: "PUNTO 8")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    panel(title: "Conseguido")[
      - Arquitectura ajustada a entrada de 4 bits y salida Q4.2.
      - CLA-NoCin específicos de 4 y 5 bits.
      - Reducción del CLA-4b de 84 a 48 compuertas.
      - NOR pseudo-NMOS con $alpha=0.9$.
      - DFF reales seleccionados tras descartar alternativas con ripple.
      - MUX 4:1, contador y decoder integrados.
      - Funcionamiento satisfactorio a 1 GHz.
    ],
    pending(title: "Por completar")[
      - Implementar y evaluar el MUX interno $phi_0/phi_2$.
      - Insertar el desacople entre etapas.
      - Recontar DFF y compuertas del circuito completo.
      - Medir timing incluyendo DFF, MUX, decoder y carga real.
      - Validar la proyección de ≈ 1.667 GHz.
      - Verificar todas las transiciones y corners requeridos.
    ],
  )
  #v(10pt)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi("48", "compuertas · CLA 4 b"),
    kpi("73", "compuertas · CLA 5 b"),
    kpi("1 GHz", "sistema verificado"),
  )
]

#slide(title: "Conclusión", tag: "CIERRE")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 16pt,
    [
      #text(size: 21pt, weight: "bold", fill: c-fg)[
        La arquitectura ya cumple la función de interpolación y opera correctamente a 1 GHz.
      ]
      #v(12pt)
      #text(size: 15pt)[
        El principal avance fue reemplazar el datapath de 6 bits por una solución de entrada de 4 bits y salida Q4.2, junto con CLA sin `Cin` y NOR pseudo-NMOS. El límite actual no está en la función lógica, sino en cerrar el camino `CLA4 → CLA5` con flip-flops reales.
      ]
      #v(10pt)
      #panel(fill: c-accent-soft, stroke-c: c-accent)[
        Próxima decisión de diseño: fijar el desacople temporal y medir el sistema completo antes de afirmar la frecuencia máxima y el conteo final de FF.
      ]
    ],
    [
      #kpi("4 → 6 bits", "entrada entera → salida con 2 bits fraccionales")
      #v(9pt)
      #kpi("≈ 43 %", "reducción de compuertas en CLA 4 b")
      #v(9pt)
      #kpi("600 ps", "período objetivo por fase")
    ],
  )
]
