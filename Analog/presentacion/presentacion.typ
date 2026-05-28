#import "template.typ": *

#show: body => slides-setup(
  title: "OTA cascodo plegado — GF180MCU",
  body,
)

// ============================================================
// 0. PORTADA
// ============================================================
#title-slide(
  course: "IEE3433 · Diseño Analógico · Proyecto Parte I",
  title: "OTA cascodo plegado en GF180",
  subtitle: "Amplificador diferencial de una sola etapa con CMFB",
  authors: (
    "Mateo de la Cuadra",
    "Vicente Florez",
    "Alonso Rivera",
  ),
  date: "Mayo 2026",
)

// ============================================================
// DISCLAIMER / ESTADO DEL AVANCE (opcional)
// ============================================================
#slide(title: "Estado de este avance", tag: "DISCLAIMER")[
  #panel(title: "Resumen del avance")[
    #set text(size: 13pt)
    // TODO: describir estado actual del diseño (dimensionamiento, AC, CMFB, bias)
    \_\_\_\_\_
  ]
  #v(5pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Hecho", fill: c-panel)[
      - // TODO: punto hecho
      - // TODO: punto hecho
    ],
    panel(title: "Pendiente", fill: c-panel, stroke-c: c-accent)[
      - // TODO: punto pendiente
      - // TODO: punto pendiente
    ],
  )
]

// ============================================================
// PUNTO 1 — ESQUEMÁTICO CON ANOTACIONES DC
// ============================================================
#section-slide("1", "Esquemático con anotaciones DC")

#slide(title: "Esquemático del OTA cascodo plegado", tag: "PUNTO 1 · 1/2")[
  #grid(columns: (1.1fr, 1fr), column-gutter: 16pt, align: horizon,
    // TODO: agregar imagen del esquemático con anotaciones I_D, V_GS, V_DS, gm/ID
    align(left, framed-image("esquematico.svg", height: 9.2cm)),
    [
      #set text(size: 12.5pt)
      *Topología:*
      - Par diferencial de entrada NMOS (M1, M2).
      - Cascodo plegado PMOS (M3, M4) / NMOS (M7, M8).
      - Fuentes de corriente: M5,6 (PMOS top) y M9,10 (NMOS bottom).
      - Bias interno: M_b1..M_b3 con espejos (razón ≤ 10).
      #v(6pt)
      *Convenciones:*
      - V_DD = 3.3 V, V_in,CM = V_out,CM = 1.65 V.
      - Anotaciones DC en el esquemático: I_D, V_GS, V_DS, g_m/I_D, W, L.
    ],
  )
]

#slide(title: "Dimensionamiento y polarización de transistores", tag: "PUNTO 1 · 2/2")[
  #set text(size: 11pt)
  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
    inset: 5pt, align: (left, right, right, right, right, right, right, right, right),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*M*], [*W [µm]*], [*L [µm]*], [*I_D [µA]*], [*V_GS [V]*], [*V_DS [V]*], [*g_m/I_D [1/V]*], [*g_m [µS]*], [*r_o [kΩ]*],
    [M1],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M2],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M3],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M4],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M5],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M6],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M7],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M8],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M9],  [—], [—], [—], [—], [—], [—], [—], [—],
    [M10], [—], [—], [—], [—], [—], [—], [—], [—],
    [M11], [—], [—], [—], [—], [—], [—], [—], [—],
    [M_b1], [—], [—], [—], [—], [—], [—], [—], [—],
    [M_b2], [—], [—], [—], [—], [—], [—], [—], [—],
    [M_b3], [—], [—], [—], [—], [—], [—], [—], [—],
  )
  #v(3pt)
  #text(size: 11pt, fill: c-muted)[
    // TODO: reemplazar — con valores del .op de LTspice.
  ]
]

// ============================================================
// PUNTO 2 — TABLA DE ESPECIFICACIONES
// ============================================================
#section-slide("2", "Tabla de especificaciones")

#slide(title: "Cumplimiento de especificaciones (Cuadro 1)", tag: "PUNTO 2")[
  #set text(size: 10.5pt)
  #table(
    columns: (1.6fr, 1fr, 1fr, auto),
    inset: 5pt, align: (left, right, right, center),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*Especificación*], [*Predicción (mano)*], [*SPICE*], [*Cumple*],
    [Ganancia DC lazo abierto ≥ 1 kV/V (60 dB)], [—], [—], [—],
    [GBW ≥ 20 MHz (V_in,CM = 1.65 V)], [—], [—], [—],
    [Disipación de potencia DC (minimizar)],   [—], [—], [—],
    [V_in,CM = 1.65 V],   [—], [—], [—],
    [V_out,CM = 1.65 V],  [—], [—], [—],
    [Excursión de salida 2 V con A_v ≥ 0.5 kV/V], [—], [—], [—],
    [CMRR DC ≥ 60 dB],    [—], [—], [—],
    [PSRR DC ≥ 60 dB],    [—], [—], [—],
    [SNR ≥ 60 dB],        [—], [—], [—],
    [C_total ≤ 10 pF (individuales con 2 cs)], [—], [—], [—],
    [R_total ≤ 100 kΩ (individuales con 2 cs)], [—], [—], [—],
    [C_L = 100 fF (sin CMFB)], [100 fF], [100 fF], [✓],
    [R_L = ∞], [∞], [∞], [✓],
    [CMFB real (continuo o discreto)], [—], [—], [—],
    [Bias: resistor (2 cs) + diodos espejos], [—], [—], [—],
    [Razón de espejos ≤ 10], [—], [—], [—],
    [T = 25 °C], [25 °C], [25 °C], [✓],
  )
]

// ============================================================
// PUNTO 3 — ANÁLISIS AC EN LAZO ABIERTO
// ============================================================
#section-slide("3", "Análisis AC en lazo abierto")

#slide(title: "Respuesta AC: ganancia y ancho de banda", tag: "PUNTO 3 · 1/2")[
  #grid(columns: (1.1fr, 1fr), column-gutter: 16pt, align: horizon,
    // TODO: reemplazar por bode plot (|H| y fase vs frecuencia)
    align(left, framed-image("bode_ac.svg", height: 8.7cm)),
    [
      #set text(size: 12.5pt)
      *Estimaciones a mano:*
      #v(4pt)
      #panel(title: "Ganancia DC")[
        $R_"out" approx (g_(m 4) r_(o 4) (r_(o 2) || r_(o 6))) || (g_(m 8) r_(o 8) r_(o 10))$ \
        $A_(v 0) = g_(m 1) dot R_"out"$
      ]
      #v(4pt)
      #panel(title: "Ancho de banda y GBW")[
        $f_(-3"dB") approx 1 / (2 pi R_"out" C_L)$ \
        $"GBW" approx g_(m 1) / (2 pi C_L)$
      ]
      #v(4pt)
      *Valores:* $A_(v 0)$ = \_\_\_\_\_ dB,  $f_(-3 "dB")$ = \_\_\_\_\_ Hz,  GBW = \_\_\_\_\_ MHz.
    ],
  )
]

#slide(title: "Discrepancias mano vs SPICE", tag: "PUNTO 3 · 2/2")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Ganancia DC")[
      #set text(size: 12.5pt)
      - // TODO: efecto de canal corto (λ) en r_o.
      - // TODO: degradación del cascodo por g_mb (body effect).
      - // TODO: tolerancia del bias real vs ideal.
    ],
    panel(title: "GBW / polos no dominantes", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      - // TODO: C_gd y C_db parásitas no consideradas en cálculo de mano.
      - // TODO: polo en el nodo de fuente del cascodo.
      - // TODO: cero por C_gd de M1,2.
    ],
  )
  #v(6pt)
  #panel(title: "Tabla comparativa")[
    #set text(size: 12pt)
    #table(columns: (1fr, auto, auto, auto), inset: 5pt, align: (left, right, right, right),
      stroke: 0.5pt + c-line,
      [*Parámetro*], [*Mano*], [*SPICE*], [*Δ*],
      [A_v0 [dB]],       [—], [—], [—],
      [$f_(-3 "dB")$ [Hz]], [—], [—], [—],
      [GBW [MHz]],       [—], [—], [—],
      [Margen de fase [°]], [—], [—], [—],
    )
  ]
]

// ============================================================
// PUNTO 4 — CMFB Y BIAS
// ============================================================
#section-slide("4", "CMFB y generación de polarización")

#slide(title: "Realimentación de modo común (CMFB)", tag: "PUNTO 4 · 1/2")[
  #grid(columns: (1fr, 1fr), column-gutter: 16pt, align: horizon,
    // TODO: agregar diagrama del CMFB elegido
    align(left, framed-image("cmfb.svg", height: 8.5cm)),
    [
      #set text(size: 12.5pt)
      *Topología CMFB:*  \_\_\_\_\_   // TODO: continuo / discreto / 5T-OTA / otro
      #v(4pt)
      #panel(title: "Sensado del modo común")[
        $V_(o u t,"CM") = V_"CM" + (R_N |V_("GSP")| - R_P V_("GSN")) / (R_P + R_N)$
      ]
      #v(4pt)
      *Parámetros elegidos:*
      - R_P = \_\_\_\_\_ kΩ, R_N = \_\_\_\_\_ kΩ.
      - I_SS1 = I_SS2 = \_\_\_\_\_ µA.
      - V_REF = 1.65 V.
      #v(4pt)
      *Lazo de corrección:* error V_out,CM − V_REF actúa sobre el gate de
      M9/M10 hasta restablecer 1.65 V sin perturbar el modo diferencial.
    ],
  )
]

#slide(title: "Generación interna de polarización", tag: "PUNTO 4 · 2/2")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Árbol de corrientes de referencia")[
      #set text(size: 12.5pt)
      - I_REF1 = \_\_\_\_\_ µA → polariza par de entrada (vía M_b1, M11).
      - I_REF2 = \_\_\_\_\_ µA → polariza M5,6 (vía M_b2).
      - I_REF3 = \_\_\_\_\_ µA → polariza M9,10 + genera V_b1 (vía M_b3 y M7,8).
      #v(4pt)
      *Resistor del bias:* R_bias = \_\_\_\_\_ kΩ (2 cs).
      #v(4pt)
      *Razón de espejos máx.:* \_\_\_\_\_ (≤ 10).
    ],
    panel(title: "Generación de V_b2 (interna)", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      // TODO: describir cómo se genera V_b2 internamente
      (e.g. rama auxiliar con diodo + cascodo replicado para fijar
      V_b2 sobre los gates de M3,4).
      #v(4pt)
      *V_b1 = \_\_\_\_\_ V,  V_b2 = \_\_\_\_\_ V.*
    ],
  )
  #v(6pt)
  #panel[
    #set text(size: 11.5pt)
    *Justificación:* la configuración elegida minimiza la cuenta de
    componentes pasivos manteniendo la razón de espejos ≤ 10 y los
    voltajes de overdrive necesarios para mantener todos los transistores
    en saturación bajo V_DD = 3.3 V.
  ]
]

// ============================================================
// PUNTO 5 — OTROS RESULTADOS RELEVANTES (máx. 3 slides)
// ============================================================
#section-slide("5", "Otros resultados relevantes")

#slide(title: "Métricas de potencia y área pasiva", tag: "PUNTO 5 · 1/3")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi("— mW", "Disipación DC total", color: c-accent),
    kpi("— pF",  "Σ capacitancias (≤ 10 pF)", color: c-blue),
    kpi("— kΩ",  "Σ resistencias (≤ 100 kΩ)", color: c-green),
  )
  #v(10pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Desglose de capacitancias")[
      #set text(size: 12pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [*Capacitor*], [*Valor [pF]*],
        [C_comp / C_C], [—],
        [C_CMFB],       [—],
        [C_L (carga)],  [0.10],
        [*Total*],      [*—*],
      )
    ],
    panel(title: "Desglose de resistencias")[
      #set text(size: 12pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [*Resistor*], [*Valor [kΩ]*],
        [R_bias],       [—],
        [R_P (CMFB)],   [—],
        [R_N (CMFB)],   [—],
        [*Total*],      [*—*],
      )
    ],
  )
]

#slide(title: "CMRR, PSRR y ruido", tag: "PUNTO 5 · 2/3")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Rechazo")[
      #set text(size: 12.5pt)
      #table(columns: (1fr, auto, auto), inset: 5pt, align: (left, right, right),
        stroke: 0.5pt + c-line,
        [*Métrica*], [*DC [dB]*], [*@ 1 MHz [dB]*],
        [CMRR],     [—], [—],
        [PSRR+],    [—], [—],
        [PSRR−],    [—], [—],
      )
    ],
    panel(title: "Ruido / SNR", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      - v_n,in (integrado, 1 Hz – 100 MHz): \_\_\_\_\_ µV_rms.
      - V_signal,rms (swing 2 Vpp diff): \_\_\_\_\_ V_rms.
      - SNR = \_\_\_\_\_ dB.
      #v(4pt)
      // TODO: comentario sobre 1/f vs térmico
    ],
  )
  #v(6pt)
  #panel[
    #set text(size: 11.5pt)
    Mediciones tomadas con V_in,CM = 1.65 V, TT, 25 °C.
  ]
]

#slide(title: "Limitaciones y trabajo futuro (Parte 2)", tag: "PUNTO 5 · 3/3")[
  #panel(title: "Roadmap a la Parte 2")[
    + // TODO: limitación principal observada (e.g. margen de fase en lazo cerrado).
    + // TODO: optimización pendiente (compensación, sizing, layout).
    + // TODO: validación en corners (FF/SS/FS/SF) y barrido de temperatura.
    + // TODO: integración del CMFB con el OTA en lazo cerrado.
  ]
  #v(10pt)
  #grid(columns: (1fr, 1fr), gutter: 10pt,
    kpi("— V/V", "A_v0 final", color: c-green),
    kpi("— MHz", "GBW final",  color: c-accent),
  )
]
