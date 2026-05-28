#import "template.typ": *

#show: body => slides-setup(
  title: "Filtro de interpolación L=4 — GF180MCU",
  body,
)

// ============================================================
// 0. PORTADA
// ============================================================
#title-slide(
  course: "IEE3753 · Diseño Digital · Proyecto Parte I",
  title: "Filtro de interpolación lineal (L = 4)",
  subtitle: "Diseño transistor-level en GF180MCU · 3.3 V · corner TT",
  authors: (
    "Mateo de la Cuadra",
    "Vicente Flores",
    "Alonso Rivera"
  ),
  date: "Mayo 2026",
)

// ============================================================
// 1. DISCLAIMER / ESTADO DEL AVANCE
// ============================================================
#slide(title: "Estado de este avance", tag: "DISCLAIMER")[
  #panel(title: "Primer avance — la arquitectura aún cambiará")[
    #set text(size: 13pt)
    Esta presentación documenta un *baseline funcional de 6 bits* ya construido y simulado en LTSpice. Durante el desarrollo identificamos dos decisiones que reestructuran el diseño hacia una versión más óptima:
  ]
  #v(5pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Hecho", fill: c-panel)[
      - Datapath completo de las 4 fases (φ0–φ3).
      - Migración de sumadores *RCA $->$ CLA*.
      - Caracterización de delays (TT, 3.3 V, 25 °C).
    ],
    panel(title: "En curso", fill: c-panel, stroke-c: c-accent)[
      - Muestras de entrada *6 b $->$ 4 b* (menos compuertas y delay).
      - Mejoras de timing: MUX 3:1, FF intermedios, *pipeline* del CLA, *DFF pulsed*.
    ],
  )
  #v(4pt)
  #text(size: 11.5pt, fill: c-muted)[
    Los conteos y frecuencias que siguen corresponden al baseline de 6 b; la sección final cuantifica el impacto esperado de las mejoras.
  ]
]

// ============================================================
// PUNTO 1 — IMPLEMENTACIÓN PROPUESTA
// ============================================================
#section-slide("1", "Implementación del filtro propuesta")

#slide(title: "Interpolación lineal de factor 4", tag: "PUNTO 1")[
  #grid(columns: (1.15fr, 1fr), gutter: 16pt,
    [
      Sobremuestreo $L=4$ + FIR. La especificación formal es:
      #v(4pt)
      #align(center, text(size: 13pt)[
        $y[n] = u[n] + 3/4(u[n-1]+u[n+1]) + 1/2(u[n-2]+u[n+2]) + 1/4(u[n-3]+u[n+3])$
      ])
      #v(4pt)
      Equivale a *trazar una recta* entre dos muestras consecutivas
      $x_"old"$, $x_"new"$ y emitir 4 valores equiespaciados. No implementamos
      el FIR literal: generamos directamente las 4 fases.
    ],
    panel(title: "Las 4 fases de salida")[
      #set text(size: 12.5pt)
      $phi_0 = x_"old"$ #h(6pt)\
      $phi_1 = (3 x_"old" + x_"new") \/ 4$ \
      $phi_2 = (x_"old" + x_"new") \/ 2$ \
      $phi_3 = (x_"old" + 3 x_"new") \/ 4$
    ],
  )
  #v(3pt)
  #panel(title: "Truco aritmético: un solo sumador compartido")[
    #set text(size: 12.5pt)
    Definimos $S = x_"old" + x_"new"$ (ADD1) y reutilizamos $S$ en todas las fases:
    $phi_1 = (S + 2x_"old") >> 2$, $phi_2 = (S+1) >> 1$, $phi_3 = (S + 2x_"new") >> 2$.
    El *redondeo* ($+1$, $+2$) se *pliega en el carry-in* (0 sumadores extra); los $2x$ son shifts (cableado).
  ]
]

// ============================================================
// PUNTO 2 — DIAGRAMA GENERAL
// ============================================================
#section-slide("2", "Diagrama general de la arquitectura")

#slide(title: "Arquitectura general (top-level)", tag: "PUNTO 2")[
  #grid(columns: (auto, 1fr), column-gutter: 22pt, align: horizon,
    align(left, framed-image("diag1_toplevel.jpg", height: 8.6cm)),
    [
      #set text(size: 12.5pt)
      *Flujo de datos:*
      #v(4pt)
      - #dblock("Registro de muestras", fill: c-blue) — captura $x_"old"$, $x_"new"$ (`load_en`).
      #v(3pt)
      - #dblock("Núcleo de interpolación", fill: c-accent) — genera φ0–φ3.
      #v(3pt)
      - #dblock("MUX 4:1 (6 b)", fill: c-green) — fase = `cuenta[1:0]`.
      #v(3pt)
      - #dblock("Registro de salida", fill: c-blue) — 6 FF → `o_D[5:0]`.
      #v(6pt)
      *Control:* contador 2 b + decoder (desde `i_CK`/`i_rstb`). El núcleo corre 1× y el MUX recorre las 4 fases a 4× la tasa de entrada.
    ],
  )
]

// ============================================================
// PUNTO 3 — JUSTIFICACIÓN
// ============================================================
#section-slide("3", "Justificación de la arquitectura")

#slide(title: "Por qué esta arquitectura", tag: "PUNTO 3")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "1 · Time-multiplexing (1 datapath, no 4)")[
      #set text(size: 12.5pt)
      En vez de 4 caminos en paralelo, *un solo núcleo* calcula las 4 fases y un
      MUX 4:1 las emite secuencialmente a 4× `i_CK`. Cuesta compuertas ↓↓ a cambio
      de exigir velocidad al núcleo → de ahí la importancia del CLA.
    ],
    panel(title: "2 · Sumador compartido + φ0 gratis")[
      #set text(size: 12.5pt)
      $S = x_"old"+x_"new"$ se calcula una vez; las 4 fases reutilizan $S$.
      $phi_0 = x_"old"$ es *cable* (0 compuertas). Redondeo plegado en carry-in.
    ],
  )
  #v(5pt)
  #panel(title: "3 · Migración RCA → CLA (decisión clave de timing)", stroke-c: c-accent)[
    #set text(size: 12.5pt)
    El primer baseline usó *ripple-carry (RCA)*: el carry recorre todos los bits en
    serie → retardo *lineal* O(n) con muchas compuertas en serie. Lo reemplazamos por
    *carry-lookahead (CLA)*: el carry se calcula en paralelo → retardo ~*logarítmico*,
    camino crítico mucho más corto. Esto es lo que permite cumplir/superar la
    frecuencia con margen (ver Punto 6).
  ]
]

// ============================================================
// PUNTO 4 — COMPUERTAS
// ============================================================
#section-slide("4", "Número de compuertas lógicas")

#slide(title: "Conteo de compuertas (excl. flip-flops)", tag: "PUNTO 4")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    [
      *CLA de 4 bits* (unidad base del datapath):
      #v(4pt)
      #table(columns: (1fr, auto), inset: 7pt, align: (left, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Compuerta*], [*N°*],
        [NAND (2 entradas)], [24],
        [NOR  (2 entradas)], [10],
        [XNOR2x1 (suma)], [8],
        [INVx1], [42],
        [*Total CLA-4b*], [*84*],
      )
      #v(4pt)
      #text(size: 13pt, fill: c-muted)[
        Estructura jerárquica: 4× PG + árbol de carry (NAND/NOR multi-entrada) + 4× XNOR.
      ]
    ],
    panel(title: "Escalado al datapath")[
      #set text(size: 12.5pt)
      El núcleo usa 1× ADD1 + 2× ADD (fases φ1/φ3) sobre sumadores tipo CLA, más el
      MUX 4:1 (TGATE) y buffers INVX1/INVX8 obligatorios.
      #v(6pt)
      Minimización lograda por: sumador *compartido*, φ0 = cable, redondeo sin
      hardware y *time-multiplexing* (no replicar 4 datapaths).
      #v(6pt)
      #text(size: 13pt, fill: c-muted)[
        El MUX 4:1 de 6 b se construye con compuertas de transmisión (24X6MUC = 4× 6X6TG),
        no con lógica AND/OR → menos transistores.
      ]
    ],
  )
]

// ============================================================
// PUNTO 5 — FLIP-FLOPS
// ============================================================
#section-slide("5", "Número de flip-flops")

#slide(title: "Conteo de flip-flops (mandatorio)", tag: "PUNTO 5")[
  #grid(columns: (1fr, 1.1fr), gutter: 14pt,
    [
      #table(columns: (1fr, auto), inset: 7pt, align: (left, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Registro*], [*FF*],
        [Muestras $x_"old"$ (6 b)], [6],
        [Muestras $x_"new"$ (6 b)], [6],
        [Salida $o\_D$ (6 b)], [6],
        [Contador de fase (2 b)], [2],
        [*Total*], [*20*],
      )
    ],
    panel(title: "Justificación")[
      #set text(size: 12.5pt)
      - FF de *entrada y salida* son exigidos por la especificación.
      - El registro de muestras retiene $x_"old"$ y $x_"new"$ durante las 4 fases
        de un período de entrada.
      - El *contador 2 b* (2 DFF + XOR) genera `cuenta[1:0]` que recorre las fases.
      #v(6pt)
      Cada DFF es maestro-esclavo con compuertas de transmisión
      (#text(fill: c-muted)[4× TGATE + 7× INVx1]).
      #v(4pt)
      #text(size: 13pt, fill: c-muted)[
        Con muestras de 4 b (versión final) los registros de muestras bajan a 4+4 FF.
      ]
    ],
  )
]

// ============================================================
// PUNTO 6 — FRECUENCIA
// ============================================================
#section-slide("6", "Estimación de frecuencia de operación")

#slide(title: "Frecuencia de operación", tag: "PUNTO 6")[
  #grid(columns: (3fr, 2fr), gutter: 14pt,
    [
      *Camino crítico* (corner TT, 3.3 V, 25 °C) — propagación a través de las etapas de sumadores CLA encadenadas más el flop de captura (sin considerar bloques como MUX o FF):
      #v(4pt)
      #table(columns: (1fr, auto), inset: 6pt, align: (left, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Tramo*], [*Delay [ps]*],
        [4 b CLA → 4 b CLA], [394],
        [4 b CLA → 2×8 b CLA], [487],
        [4 b CLA → flops], [306],
        [DFF (interno)], [394],
        [*Σ camino crítico*], [*≈ 1582*],
      )
      #v(3pt)
      #text(size: 11.5pt, fill: c-muted)[
        clk→q medido: $t_(c q,"rise")=299$ ps, $t_(c q,"fall")=272$ ps.
      ]
    ],
    [
      #kpi("≈ 632 MHz", "4 * fc = f_op = 1 / 1.582 ns", color: c-green)
      #v(4pt)
      #kpi("100 MHz", "mínimo exigido por el spec", color: c-muted)
      #v(4pt)
      #panel[
        #set text(size: 11.5pt)
        Margen *>6×* sobre el mínimo. El CLA habilita este margen; con RCA el carry en serie reduciría f_op drásticamente.
      ]
    ],
  )
]

// ============================================================
// PUNTO 7 — DIAGRAMA DETALLADO (<= 5 slides)
// ============================================================
#section-slide("7", "Diagrama detallado de la arquitectura")

#slide(title: "Datapath detallado de las 4 fases", tag: "PUNTO 7 · 1/5")[
  #grid(columns: (auto, 1fr), column-gutter: 22pt, align: horizon,
    align(left, framed-image("diag2_baseline.jpg", height: 8.7cm)),
    [
      #set text(size: 13pt)
      - *ADD1*: $S = x_"old" + x_"new"$ (7 b), compartido.
      - *ADD2*: $S + 2 x_"old"$ → `+2 >>2` → φ1.
      - *>>1*: $(S+1) >> 1$ → φ2.
      - *ADD3*: $S + 2 x_"new"$ → `+2 >>2` → φ3.
      - φ0 = $x_"old"$ (cable directo, 0 compuertas).
      #v(8pt)
      Los `2·x` son shifts (cableado); el `+2` de redondeo entra por el carry-in del
      sumador, sin sumador adicional.
    ],
  )
]

#slide(title: "Interior del CLA de 4 bits", tag: "PUNTO 7 · 2/5")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Estructura")[
      #set text(size: 12.5pt)
      + *PG*: genera $g_i = a_i b_i$, $p_i = a_i ⊕ b_i$ (4× celda PG).
      + *Árbol de carry*: red de NAND/NOR multi-entrada (3/4/5) calcula
        $c_1..c_4$ *en paralelo* (lookahead).
      + *Suma*: $s_i = p_i ⊕ c_i$ (4× XNOR2x1).
    ],
    panel(title: "Camino crítico", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      *14 compuertas en serie* (CLA-4b):
      #v(3pt)
      #align(center)[PG → C0_3 (4-NAND → 5-NOR) → SUM]
      #v(6pt)
      Encadenando a 8 b el peor caso ≈ *28 compuertas* cuando cambia el carry-in.
      Aún así, muy por debajo del ripple de un RCA equivalente.
    ],
  )
  #v(6pt)
  #text(size: 13pt, fill: c-muted)[
    Celdas: `PG`, `3/4/5-NAND`, `3/4/5-NOR`, `XNOR2x1`, `INVx1` en `Components/CLA/`.
  ]
]

#slide(title: "RCA vs CLA — por qué migramos", tag: "PUNTO 7 · 3/5")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Ripple-Carry (baseline inicial)")[
      #set text(size: 12.5pt)
      - `FAX1` encadenados (`8RCAX1` = 8× FAX1 + 16× INVx1).
      - Carry *en serie*: $c_(i+1)$ depende de $c_i$.
      - Retardo *O(n)* → camino crítico largo.
      - Pocas compuertas, pero lento.
    ],
    panel(title: "Carry-Lookahead (actual)", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      - Carry calculado *en paralelo* vía PG + árbol NAND/NOR.
      - Retardo ~*O(log n)* en profundidad lógica.
      - Más compuertas, pero *mucho más rápido*.
      - Habilita el time-multiplexing a 4× sin perder f_op.
    ],
  )
  #v(5pt)
  #align(center, panel(fill: c-panel)[
    #set text(size: 15pt)
    *Conclusión:* en una arquitectura time-multiplexed el cuello de botella es el
    sumador. El CLA cambia compuertas por velocidad — el trade-off correcto aquí.
  ])
]

#slide(title: "MUX 4:1 y control de fase", tag: "PUNTO 7 · 4/5")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "MUX 4:1 · 6 bits (TGATE)")[
      #set text(size: 12.5pt)
      - `24X6MUC` = 4× `6X6TG` (compuertas de transmisión).
      - Selecciona φ0..φ3 con `sel = cuenta[1:0]`.
      - Sin lógica AND/OR → menor cuenta de transistores y baja capacitancia.
    ],
    panel(title: "PhaseSelector")[
      #set text(size: 12.5pt)
      - `2bCOUNT` (2× DFF + XORX1) → `cuenta[1:0]`.
      - `DECODER` genera las señales `one-hot` de selección.
      - Recorre las 4 fases por cada período de entrada.
    ],
  )
  #v(5pt)
  #flow(
    dblock("φ0..φ3 (6b ×4)", fill: c-purple), arr,
    dblock("MUX 4:1", fill: c-green), arr,
    dblock("Reg. salida", fill: c-blue), arr,
    dblock("o_D[5:0]", fill: c-line),
  )
  #v(4pt)
  #align(center, text(size: 13pt, fill: c-muted)[
    `cuenta[1:0]` (de PhaseSelector) controla la selección del MUX.
  ])
]

#slide(title: "Flip-flop maestro-esclavo (TGATE)", tag: "PUNTO 7 · 5/5")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Estructura del DFF")[
      #set text(size: 12.5pt)
      - 4× `TGATE` + 7× `INVx1` por flip-flop.
      - Latch maestro y latch esclavo conmutados por `i_CK` / #overline[`i_CK`].
      - Usado en registro de muestras, salida y contador.
    ],
    panel(title: "Red de reloj")[
      #set text(size: 12.5pt)
      - `i_CK` e `i_rstb` distribuidos globalmente a todos los flip-flops.
      - Buffers `INVX1` (entrada) / `INVX8` (salida) por especificación.
    ],
  )
  #v(5pt)

]

// ============================================================
// PUNTO 8 — OTROS RESULTADOS (<= 3 slides)
// ============================================================
#section-slide("8", "Otros resultados relevantes")

#slide(title: "Resultados de la migración RCA → CLA", tag: "PUNTO 8 · 1/3")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    [
      Tras reemplazar los sumadores RCA por CLA, el camino crítico de los sumadores
      (entrada → salida, sin MUX ni flops) quedó en:
      #v(6pt)
      #kpi("1.582 ns", "Σ retardo de sumadores CLA encadenados", color: c-accent)
      #v(6pt)
      #text(size: 14pt)[
        Profundidad lógica del peor caso: 14 compuertas (CLA-4b) / 28 (CLA-8b),
        frente al ripple O(n) del RCA.
      ]
    ],
    panel(title: "Mediciones LTSpice (TT, 3.3 V)")[
      #set text(size: 13.5pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [4b→4b CLA], [394 ps],
        [4b→2×8b CLA], [487 ps],
        [4b→flops], [306 ps],
        [$t_(c q,"rise")$], [299 ps],
        [$t_(c q,"fall")$], [272 ps],
      )
      #v(4pt)
      #text(size: 12pt, fill: c-muted)[
        Medido con `.measure tran` al cruce de Vdd/2 = 1.65 V.
      ]
    ],
  )
]

#slide(title: "Mejoras propuestas (versión final)", tag: "PUNTO 8 · 2/3")[
  #grid(columns: (1fr, 1fr), gutter: 10pt, row-gutter: 10pt,
    panel(title: "① Muestras 6 b → 4 b")[
      #set text(size: 13.5pt)
      Reduce anchos de sumadores y MUX → *menos compuertas y menor delay*. Registros
      de muestras 6+6 → 4+4 FF.
    ],
    panel(title: "② MUX 3:1 en etapa rápida")[
      #set text(size: 13.5pt)
      Un MUX 3:1 entre ADD2/ADD3 reduce transistores; a evaluar su impacto en el
      delay del camino rápido.
    ],
    panel(title: "③ FF entre parte rápida y lenta")[
      #set text(size: 13.5pt)
      Desacopla los dominios y acorta el camino crítico combinacional (mejor f_op a
      costa de latencia).
    ],
    panel(title: "④ Pipeline del CLA + ⑤ DFF pulsed")[
      #set text(size: 13.5pt)
      FF intermedio en el CLA (pipeline) sube f_op; el *DFF pulsed* mejora el
      $t_"setup"$ del registro.
    ],
  )
]

#slide(title: "Próximos pasos", tag: "PUNTO 8 · 3/3")[
  #panel(title: "Roadmap hacia la entrega final")[
    + Reimplementar el datapath con *muestras de 4 b* y recontar compuertas/FF.
    + Insertar *FF de pipeline* (CLA y frontera rápida/lenta) y volver a medir f_op.
    + Evaluar *MUX 3:1* y *DFF pulsed*; comparar área (transistores) vs velocidad.
    + Re-simular en corner TT y validar margen sobre los 100 MHz con la nueva estructura.
  ]
  #v(10pt)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi("20 → ~14", "flip-flops (con muestras 4 b)", color: c-blue),
    kpi("632 MHz", "f_op baseline actual", color: c-green),
    kpi("> 6×", "margen sobre el mínimo", color: c-accent),
  )
]
