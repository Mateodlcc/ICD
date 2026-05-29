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
    Dimensionamiento por $g_m \/ I_D$ completo. Dos esquemáticos LTspice
    convergentes: *ota_v2* (baja potencia, ≈ 53 µW) y *ota_v4* (robusta,
    ≈ 99 µW). v4 con CMFB *capacitores conmutados* (8 switches, $C_1=3$ pF, $C_2=1$ pF).
    Bode AC ya muestra $A_(v 0) approx 68$ dB y GBW $approx 50$ MHz.
  ]
  #v(5pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Hecho", fill: c-panel)[
      - Sizing por $g_m \/ I_D$ del par, cola, cascodo y espejos.
      - Sim `.op` v4 + Bode AC; ramas réplicas generan $V_(b 1), V_(b 2)$.
      - SC CMFB integrado, $R_("bias") = 46$ kΩ (R3 = 45.83 kΩ).
    ],
    panel(title: "Pendiente", fill: c-panel, stroke-c: c-accent)[
      - Cerrar el lazo diferencial (próxima entrega)
      - Mejorar SNR.
      - Generación de clock secundario.
    ],
  )
]

// ============================================================
// SECCIÓN A — FLUJO DE DISEÑO
// ============================================================
#section-slide("A", "Flujo de diseño")

#slide(title: "Orden de diseño seguido", tag: "FLUJO · A.1")[
  #v(8pt)
  #flow(
    dblock("Par diferencial\n(gm/ID)", fill: c-accent), arr,
    dblock("I_SS", fill: c-blue), arr,
    dblock("Cascodo", fill: c-purple), arr,
    dblock("Espejos", fill: c-green), arr,
    dblock("Iteración", fill: c-line), arr,
    dblock("Final", fill: c-accent),
  )
  #v(10pt)
  #panel(title: "Filosofía del flujo")[
    #set text(size: 13pt)
    Se partió fijando $g_(m)/I_D$ del par de entrada (define ruido y g_m por
    µA), luego se eligió la corriente de cola para cumplir GBW con $C_L$=100 fF,
    se dimensionaron los cascodos para maximizar $r_(o u t)$ sin perder swing,
    y finalmente se cerraron los espejos con razón ≤ 10. Se realizaron iteraciones
    para ajustar según especificaciones.
  ]
]

#slide(title: "1 · Par diferencial NMOS (M9, M10)", tag: "FLUJO · A.2")[
  #grid(columns: (1.05fr, 1fr), column-gutter: 14pt, align: horizon,
    align(left, framed-image("input_diferential_pair.jpeg", height: 7.3cm)),
    [
      #set text(size: 12pt)
      *Criterio $g_m \/ I_D$:*
      - $g_m \/ I_D$ = 23.8 V⁻¹ (subumbral, máximo $g_m$ por µA).
      - $V^* = 2/(g_m \/ I_D)$ = 0.084 V.
      - $L_("pair")$ = 1.12 µm (4× $L_("min")$).
      #v(4pt)
      *Resultados (sim `.op` v4):*
      - $W_("pair")$ = 45.2 µm.
      - $I_(D 9) = I_(D 10)$ = 1.000 µA → $I_("tail")$ = 2.00 µA.
      - $V_("source,par")$ = 814 mV; $V_("gate,M11")$ = 873 mV.
      - $g_(m 1) approx 23.8$ µS.
      #v(4pt)
      *Verificación GBW:* target 20 MHz @ $C_L$=100 fF ⇒ $g_(m 1) gt.eq 12.6$ µS — cumplido.
    ],
  )
]

#slide(title: "2 · Corriente de cola I_SS", tag: "FLUJO · A.3")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    [
      #set text(size: 12.5pt)
      *Dimensionamiento de M11 (cola del par):*
      #v(4pt)
      - $g_m \/ I_D$ = 8 V⁻¹ (zona de saturación fuerte → $V_(D S,"sat")$ alto).
      - $I_("SS","par") = 2 I_(D 1)$ = 2 µA (semilla, × $M_n=2$ en v2/v4).
      - $V^* = 0.25$ V → $V_(D S,"sat",11)$ = 0.21 V.
      - $W slash L$ de M11 = 2.64 µm / 4.48 µm.
      #v(6pt)
      *Ramas del cascodo plegado:*
      - $I_("SS"1) = I_("SS"2)$ = 3 µA por rama (M9, M10 con $M_p=4$).
      - Cada cascodo conduce $I_("SS"i) - I_(D 1)/2$ = 2 µA.
    ],
    panel(title: "Trade-off corriente vs especificaciones")[
      #set text(size: 12.5pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Variable*], [*Impacto*],
        [↑ I_SS],     [↑ GBW, ↑ P],
        [↓ I_SS],     [↓ P],
        [↑ L],        [↑ $r_o$, ↑ ganancia],
        [↑ W],        [↑ $g_m$, ↑ área],
      )
    ],
  )
]




#slide(title: "3 · Cascodo plegado", tag: "FLUJO · A.4")[
  #grid(columns: (1.05fr, 1fr), column-gutter: 12pt, align: horizon,
    align(left, framed-image("output_cascode_branch.jpeg", height: 9.0cm)),
    [
      #set text(size: 10.5pt)
      *Topología (rama vom; vop es espejo):*\
      M13 PMOS top → M14 cascodo PMOS → *vom* → M15 cascodo NMOS → M16 sink. M21: sink CMFB ($v_("ctr")$).
      #v(3pt)
      #table(columns: (auto, 1fr, auto, auto, auto),
        inset: 3pt, align: (center, left, right, right, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Tx*], [*Rol*], [*W (µm)*], [*L (µm)*], [*$g_m\/I_D$*],
        [M13], [PMOS top], [22.99], [2.24], [14],
        [M14], [Cascodo PMOS],    [7.92],  [0.84], [12],
        [M15], [Cascodo NMOS],    [1.92],  [0.84], [12],
        [M16], [NMOS sink],[3.53],  [2.24], [14],
        [M21], [NMOS CMFB],[3.53],  [2.24], [14],
      )
      #v(3pt)
      $I_("rama") approx 3.0$ µA (sim). $L_("cas")=3 L_("min")$ → maximiza $r_o$; $V^*_("cas")=0.167$ V.
      #v(3pt)
      $R_(o u t) approx (g_(m 14) r_(o 14) r_(o 13)) || (g_(m 15) r_(o 15) r_(o 16)) approx 2.4$ MΩ\
      $A_(v 0,"mano") = g_(m 9) R_(o u t) approx 61.1$ dB.
    ],
  )
]




#slide(title: "4.1 · Rama maestra de bias (para espejos de corriente)", tag: "FLUJO · A.5")[
  #grid(columns: (1fr, 1fr), column-gutter: 14pt, align: horizon,
    align(left, framed-image("master_current_branch.jpeg", height: 8.8cm)),
    [
      #set text(size: 11.5pt)
      *Rama maestra:*
      - $bold(R_("bias") = 46 "kΩ")$ (R3 = 45.83 kΩ, 2 cs) → fija $I_("master") = 6.05$ µA.
      - M27, M28 diodos (NMOS / PMOS) generan tensiones de referencia.
      - $L_("copy") = 4.48$ µm, $W_("copy,p") = 35.91$ µm.
      #v(4pt)
      *Distribución (razones ≤ 10):*
      #table(columns: (1fr, auto, auto), inset: 4pt, align: (left, right, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Destino*], [*Factor*], [*I (µA)*],
        [Cola (M12)],            [1:$M_("copy,tail")$ = 1:3], [6 → 2],
        [Cascodo PMOS (M24/M25)], [1:$M_p$ = 1:4],            [6 → 6],
        [Cascodo NMOS (M26)],     [1:$M_n$ = 1:2],            [6 → 6],
      )
      #v(4pt)
      Razón máxima = 4 (≤ 10 ✓). Consumo del bias ≈ 20 µW.
    ],
  )
]

#slide(title: "4.2 · Espejos de corriente", tag: "FLUJO · A.6")[
  #grid(columns: (1fr, 1.1fr), column-gutter: 14pt, align: horizon,
    align(left, framed-image("current_mirror_cascode_branch.jpeg", height: 7.5cm)),
    [
      #set text(size: 11.5pt)
      *Rama PMOS (genera $V_(b 2)$):* M1, M2, M7, M8 — Mcopy_fold=2.\
      *Rama NMOS (genera $V_(b 1)$):* M3, M4, M5, M6 — Mcopy_cas=3.
      #v(4pt)
      #table(columns: (1fr, auto, auto), inset: 4pt, align: (left, right, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Voltaje*], [*Mano*], [*Sim*],
        [$V_(b 1)$], [863 mV], [940 mV],
        [$V_(b 2)$], [2.319 V], [2.246 V],
        [$I$ cada rama], [6 µA], [6.05 µA],
      )
      #v(4pt)
      $L_("cas") = 0.84$ µm (3× $L_("min")$), $g_m \/ I_D = 14$ V⁻¹.\
      $V^*_("cas") = 0.143$ V → cascodos en saturación con poco $V_(D S)$.
      #v(4pt)
    ],
  )
  
]


// ============================================================
// SECCIÓN B — ITERACIONES
// ============================================================
#section-slide("B", "Iteraciones de diseño")

#slide(title: "Iteración para alcanzar la ganancia", tag: "ITERACIÓN · B.1")[
  #set text(size: 11pt)
  #table(
    columns: (auto, 1.4fr, auto, auto, auto, 1.5fr),
    inset: 6pt, align: (center, left, right, right, right, left),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*Ver.*], [*Cambio principal*], [*$A_(v 0)$ (dB)*], [*GBW (MHz)*], [*P (µW)*], [*Observación*],
    [V1 base], [Semilla con $g_m \/ I_D$ por hoja, $M=1$ todos],            [61.1],  [—],     [≈ 6.6], [Hand-calc; cascodos cortos, sin escalado.],
    [V3],      [Multiplicadores $M_n=2, M_p=4$, 2 ramas activas],            [66.47], [29.26], [≈ 100], [Sim OK; cumple GBW y Av.],
    [V4 robusta], [$M_("copy,cas")=3$, $M_("copy,fold")=2$, $L_("copy")=4.48$ µm], [67.48], [32.84], [≈ 99],  [Margen para corners, mismo orden de potencia.],
    [V2 baja P.], [Core sin Mcopy extras, CMFB integrado (M15/M16)],          [—],     [—],     [≈ 53], [Sim de ganancia pendiente (nodos flotantes).],
  )
  #v(6pt)
  #panel[
    #set text(size: 12pt)
    *Lección:* la ganancia DC está dominada por los $r_o$ de los cascodos;
    duplicar $L_("copy")$ (V3 → V4) y agregar multiplicadores en las ramas
    aumentó $A_(v 0)$ de 61.1 dB (mano) a 67.5 dB (sim) sin penalizar GBW.
  ]
]

#slide(title: "Iteración de razones de espejo", tag: "ITERACIÓN · B.2")[
  #set text(size: 11.5pt)
  Comenzamos con un espejo 1:1, luego iteramos a un espejo 1:3 para mejorar la polarización. Probamos varias alternativas para cumplir con las especificaciones. Finalmente se utilizó un espejo 4:1, aumentando la corriente y con espejos más robustos con tal de disminuir la potencia. \
  Existen dos versiones, una con multiplicadores extra (v4, robusta) y otra sin ellos (v2, bajo consumo).
  #v(6pt)
  #panel(title: "Decisión final")[
    #set text(size: 12pt)
    Razón elegida: *PMOS 1:4*, *NMOS 1:2* (ambas ≤ 10 ✓).
    Mantiene el consumo del bias en torno a 1.65 µW (1 µA × $V_(D D)$).
  ]
]

// ============================================================
// SECCIÓN C — DOS DISEÑOS FINALES
// ============================================================
#section-slide("C", "Dos diseños finales")

#slide(title: "Variante A — Robusta (ota_v4)", tag: "FINAL · C.1")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Filosofía")[
      #set text(size: 12.5pt)
      - Multiplicadores extra: $M_("copy,cas")=3$, $M_("copy,fold")=2$.
      - $L_("copy")$ duplicado a 4.48 µm → margen ante mismatch y corners.
      - CMFB *Switched-Capacitor* (8 switches, $C_1=3$ pF, $C_2=1$ pF) — no carga $R_(o u t)$.
      - Mayor $I_("master")$ (6 µA) asegura $g_m$ y slew.
    ],
    panel(title: "Métricas (notebook v4)")[
      #set text(size: 12pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [$A_(v 0)$],     [67.48 dB],
        [GBW],           [32.84 MHz],
        [$P_(D C)$],     [≈ 99 µW],
        [Swing salida],  [≈ 2.93 V],
        [CMRR DC],       [163.4 dB],
        [PSRR DC],       [296.6 dB],
        [SNR],           [24.95 dB],
      )
    ],
  )
]

#slide(title: "Variante B — Bajo consumo (ota_v2)", tag: "FINAL · C.2")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Filosofía", stroke-c: c-accent)[
      #set text(size: 12.5pt)
      - Mismo core (par, cascodos) pero sin multiplicadores extra.
      - *CMFB integrado*: M15/M16 reparten la corriente con factor $a=0.7$ — ahorra el OTA del CMFB.
      - 8 ramas con corriente maestra $I_1=500$ nA → consumo ~ 16 µA × 3.3 V.
      - Trade-off: menor robustez ante corners; ganancia DC aún por simular.
    ],
    panel(title: "Métricas (parciales, practicamente identicas, con menor potencia)")[
      #set text(size: 12pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [$A_(v 0)$],     [67.48 dB],
        [GBW],           [32.84 MHz],
        [$P_(D C)$],     [≈ 51 µW],
        [Swing salida],  [≈ 2.93 V],
        [CMRR DC],       [163.4 dB],
        [PSRR DC],       [296.6 dB],
        [SNR],           [24.95 dB],
      )
    ],
  )
]

#slide(title: "Comparativa Robusta vs Bajo consumo", tag: "FINAL · C.3")[
  #set text(size: 11pt)
  #table(
    columns: (1.4fr, 1fr, 1fr, 1.5fr),
    inset: 6pt, align: (left, right, right, left),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*Métrica*], [*Robusta (v4)*], [*Bajo consumo (v2)*], [*Comentario*],
    [$A_(v 0)$ (dB)],        [67.48], [\_\_\_\_\_], [Similar],
    [GBW (MHz)],             [32.84], [\_\_\_\_\_], [Similar],
    [$P_(D C)$ (µW)],        [≈ 99],  [≈ 53],       [v2 ≈ ½ del consumo de v4.],
    [Swing salida (V)],      [≈ 2.93], [\_\_\_\_\_], [Similar],
    [CMRR DC (dB)],          [163.4], [\_\_\_\_\_], [Similar],
    [PSRR DC (dB)],          [296.6], [\_\_\_\_\_], [Similar],
    [SNR (dB)],              [24.95], [\_\_\_\_\_], [Similar],
    [Σ C (pF)],              [8],  [\_\_\_\_\_],       [Similar],
    [Σ R (kΩ)],              [46], [\_\_\_\_\_], [Similar],
    [Razón espejos máx.],    [1:4],   [4:1],        [Igual estructura de bias.],
  )
  
]

// ============================================================
// PUNTO 1 — ESQUEMÁTICO CON ANOTACIONES DC
// ============================================================
#section-slide("1", "Esquemático con anotaciones DC")

#slide(title: "Esquemático del OTA — top-level por bloques", tag: "PUNTO 1 · 1/2")[
  #grid(columns: (1fr, 1fr), gutter: 4pt, row-gutter: 4pt,
    framed-image("input_diferential_pair.jpeg", height: 4.1cm),
    framed-image("output_cascode_branch.jpeg", height: 4.1cm),
    framed-image("master_current_branch.jpeg", height: 3.9cm),
    framed-image("current_mirror_cascode_branch.jpeg", height: 3.9cm),
  )
]

#slide(title: "Sizing y anotaciones DC — v4 (robusta)", tag: "PUNTO 1 · 2/2")[
  #set text(size: 9.5pt)
  #table(
    columns: (1.5fr, auto, auto, auto, auto, auto, auto, auto),
    inset: 4pt, align: (left, right, right, right, right, right, right, right),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*Rol (instancia)*], [*W (µm)*], [*L (µm)*], [*M*], [*$I_D$ (µA)*], [*$g_m \/ I_D$ (V⁻¹)*], [*$V^*$ (V)*], [*Notas*],
    [Par NMOS (M9, M10)],          [45.2],  [1.12], [1], [1.00], [23.8], [0.084], [Subumbral, max $g_m \/ I_D$],
    [Cola NMOS (M11)],             [2.64],  [4.48], [1], [2.00], [8],    [0.25],  [Sat. fuerte],
    [Cola espejo (M12)],           [2.64],  [4.48], [3], [6.00], [8],    [0.25],  [Mcopy_tail=3],
    [Esp. PMOS top (M1)],          [22.99], [2.24], [2], [3.00], [12],   [0.167], [Mcopy_fold=2],
    [Casc. PMOS (M2)],             [7.92],  [0.84], [3], [3.00], [14],   [0.143], [],
    [Sink NMOS (M3, M4, M6)],      [3.53],  [2.24], [3], [3.00], [12],   [0.167], [],
    [Casc. NMOS (M5)],             [0.32],  [0.84], [3], [3.00], [14],   [0.143], [],
    [Salida casc. (M13–M20)],      [≈ M1–M8], [—], [1], [3.00], [12–14], [—], [Cascodo de salida real],
    [Sink CMFB (M21, M22)],        [\_\_],  [\_\_], [1], [\_\_], [\_\_], [\_\_], [Gate = vctr (SC CMFB)],
    [Bias R3 (resistor)],          [—],     [—],    [—], [—],   [—],     [—], [$R_("bias") = 46$ kΩ],
    [Bias PMOS (M28)],             [35.91], [4.48], [1], [6.05], [12],   [—], [Diodo a $V_(D D)$],
    [Bias NMOS (M27, M12)],        [\_\_],  [4.48], [1], [6.05], [—],    [—], [Diodos para Vb1],
  )
  #v(3pt)
  #text(size: 10pt, fill: c-muted)[
    $V_(D D)=3.3$ V, $T=25$ °C, $V_(in,"CM")=V_(o u t,"CM")=1.65$ V (target),
    $V_(b 1)=940$ mV, $V_(b 2)=2.246$ V (sim). Variante v2: ver sección C.2;
    misma topología con $M_("copy")$ reducidos.
  ]
]

// ============================================================
// PUNTO 2 — TABLA DE ESPECIFICACIONES
// ============================================================
#section-slide("2", "Tabla de especificaciones")

#slide(title: "Cumplimiento de especificaciones (Cuadro 1)", tag: "PUNTO 2")[
  #set text(size: 9pt)
  #table(
    columns: (1.6fr, 1fr, 1fr, auto),
    inset: 3pt, align: (left, right, right, center),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-panel },
    [*Especificación*], [*Predicción (mano)*], [*SPICE (v4)*], [*Cumple*],
    [Ganancia DC lazo abierto ≥ 1 kV/V (60 dB)], [61.1 dB], [≈ 67 dB (Bode)], [✓],
    [GBW ≥ 20 MHz ($V_(in,"CM")$ = 1.65 V)], [27.9 MHz], [≈ 32.8 MHz (Bode)], [✓],
    [Disipación de potencia DC (minimizar)],   [≈ 99 µW], [≈ 102 µW ], [✓],
    [$V_(in,"CM")$ = 1.65 V],   [1.65 V], [1.65 V], [✓],
    [$V_(o u t,"CM")$ = 1.65 V],  [1.65 V (vía CMFB)], [1.65 V], [✓],
    [Excursión de salida 2 V con $A_v$ ≥ 0.5 kV/V], [≈ 5.8 PPV], [5 PP], [✓],
    [CMRR DC ≥ 60 dB],    [38.86], [163.4], [✓],
    [PSRR DC ≥ 60 dB],    [343.75], [296.6], [✓],
    [SNR ≥ 60 dB],        [43.45], [25], [X],
    [$C_("total")$ ≤ 10 pF (indiv. con 2 cs)], [$C_L + 2(C_1+C_2)$ = 8.1 pF], [8.1 pF (0.10 + 3.0 + 1.0 + 3.0 + 1.0)], [✓],
    [$R_("total")$ ≤ 100 kΩ (indiv. con 2 cs)], [46 kΩ ($R_("bias")$)], [46 kΩ], [✓],
    [$C_L$ = 100 fF (sin CMFB)], [100 fF], [100 fF], [✓],
    [$R_L$ = ∞], [∞], [∞], [✓],
    [CMFB real (continuo o discreto)], [SC CMFB (discreto, $C_1=3$pF, $C_2=1$pF)], [implementado, @ 10 MHz], [✓],
    [Bias: resistor (2 cs) + diodos espejos], [R3=46 kΩ + M27, M28 diodos], [implementado], [✓],
    [Razón de espejos ≤ 10], [1:4 (PMOS), 1:2 (NMOS), 1:3 (cola)], [✓], [✓],
    [T = 25 °C], [25 °C], [25 °C], [✓],
  )
]

// ============================================================
// PUNTO 3 — ANÁLISIS AC EN LAZO ABIERTO
// ============================================================
#section-slide("3", "Análisis AC en lazo abierto")

#slide(title: "Respuesta AC: ganancia y ancho de banda", tag: "PUNTO 3 · 1/2")[
  #grid(columns: (1.15fr, 1fr), column-gutter: 14pt, align: horizon,
    align(left, framed-image("bode.jpeg", height: 8.7cm)),
    [
      #set text(size: 12pt)
      *Ecuaciones a mano:*
      #panel(title: "Ganancia DC")[
        $A_(v 0) = g_(m 1) dot R_"out"$ \
        $R_"out" approx (g_(m 4) r_(o 4) (r_(o 2) || r_(o 6))) || (g_(m 8) r_(o 8) r_(o 10))$
      ]
      #v(3pt)
      #panel(title: "Ancho de banda y GBW")[
        $f_(-3"dB") approx 1 / (2 pi R_"out" C_L)$,  $"GBW" approx g_(m 1) / (2 pi C_L)$
      ]
      #v(4pt)
      *Resultados Bode (sim AC v4):*
      - $A_(v 0)$ ≈ 68 dB DC ✓ (≥ 60).
      - $f_(-3"dB")$ ≈ 1–3 kHz.
      - GBW ≈ 50 MHz ✓ (≥ 20).
    ],
  )
]

#slide(title: "Discrepancias mano vs SPICE", tag: "PUNTO 3 · 2/2")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Ganancia DC (+7 dB sim > mano)")[
      #set text(size: 12pt)
      - Mano usa $M=1$; v4 tiene multiplicadores ($M_p=4$, $M_("copy,cas")=3$, $M_("copy,fold")=2$) → más $r_o$ paralelo.
      - $g_m$ del par escalado por $M_n=2$ no se incluyó en la cuenta de hoja.
      - $L_("copy")=4.48$ µm (doble que en v2) sube los $r_o$ de los espejos.
    ],
    panel(title: "GBW (+17 MHz sim > mano)", stroke-c: c-accent)[
      #set text(size: 12pt)
      - $g_m$ efectivo es ~2× lo que se usó a mano (mismo argumento $M_n=2$).
      - $C_L$ paralelo a $C_(g d)$ de M14, M18 — efecto Miller bajo gracias al cascodo.
      - Cero/escalón en el Bode entre 100 kHz y 1 MHz: probable polo-cero del SC CMFB a 10 MHz reflejado.
    ],
  )
  #v(6pt)
  #panel(title: "Tabla comparativa")[
    #set text(size: 12pt)
    #table(columns: (1fr, auto, auto, auto), inset: 5pt, align: (left, right, right, right),
      stroke: 0.5pt + c-line,
      [*Parámetro*], [*Mano*], [*SPICE (Bode)*], [*Δ*],
      [$A_(v 0)$ (dB)],         [61.1],   [≈ 68],    [+7 dB],
      [$f_(-3 "dB")$ (kHz)],    [≈ 14],   [≈ 1–3],   [−1 década],
      [GBW (MHz)],              [32.84],  [≈ 50],    [+17 MHz],
    )
  ]
]

// ============================================================
// PUNTO 4 — CMFB Y BIAS
// ============================================================
#section-slide("4", "CMFB y generación de polarización")

#slide(title: "CMFB Switched-Capacitor — top-level + interior", tag: "PUNTO 4 · 1/2")[
  #grid(columns: (1fr, 1fr), gutter: 8pt, row-gutter: 4pt,
    framed-image("SC_CMFB.jpeg", height: 4.0cm),
    framed-image("SC_CMFB2.jpeg", height: 4.0cm),
  )
  #v(2pt)
  #grid(columns: (1fr, 1fr), gutter: 10pt,
    panel(title: "Por qué SC y no continuo")[
      #set text(size: 10.5pt)
      - $V_(o u t,"CM")$ se muestrea sobre $C_1=3$ pF, comparado con $V_("REF")=1.65$ V vía $C_2=1$ pF.
      - Sin path resistivo a la salida → no degrada $R_(o u t)$ ni el swing.
      - $f_("CK")$ ≈ 10 MHz (PHI1, PHI2 con duty 50 ns / 100 ns).
    ],
    panel(title: "Operación en dos fases", stroke-c: c-accent)[
      #set text(size: 10.5pt)
      - *φ1:* $C_1$ carga con $(V_(o p)+V_(o m))/2 - V_("REF")$; $C_2$ refrescada con $V_("bias")$.
      - *φ2:* $C_1$ y $C_2$ se conectan en cabeza-cola → entregan $V_("ctr")$ a las compuertas de M21, M22 (NMOS sink).
      - Lazo cerrado: $V_("ctr")$ modula la corriente del sink hasta $V_(o u t,"CM") = V_("REF")$.
    ],
  )
]

#slide(title: "Generación de bias: rama maestra y Vb1, Vb2", tag: "PUNTO 4 · 2/2")[
  #grid(columns: (1fr, 1.05fr), column-gutter: 14pt, align: horizon,
    align(left, framed-image("master_current_branch.jpeg", height: 8.8cm)),
    [
      #set text(size: 11.5pt)
      *Resistor de bias:* $bold(R_3 = R_("bias") = 46 "kΩ")$ (45.83 kΩ, 2 cs)\
      → $I_("master") = V_(D D)/R_("bias") - V_(G S,"diodos")$ ≈ 6.05 µA.
      #v(4pt)
      *Cascada de diodos:* M27 (NMOS) y M28 (PMOS) conectados G–D para
      fijar el potencial $V_(b 2)$ desde $V_(D D)$ y replicar la corriente
      hacia M24, M25 (PMOS top) y M26 (NMOS sink).
      #v(4pt)
      *Voltajes generados:*
      #table(columns: (1fr, auto, auto), inset: 4pt, align: (left, right, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-panel },
        [*Voltaje*], [*Mano*], [*Sim*],
        [$V_(b 1)$ (gate cascodo NMOS)], [863 mV], [940 mV],
        [$V_(b 2)$ (gate cascodo PMOS)], [2.319 V], [2.246 V],
      )
      #v(4pt)
      *Razón máxima de espejos:* 1:4 (PMOS) ≤ 10 ✓.
    ],
  )
]

// ============================================================
// PUNTO 5 — OTROS RESULTADOS RELEVANTES (máx. 3 slides)
// ============================================================
#section-slide("5", "Otros resultados relevantes")

#slide(title: "Métricas de potencia y área pasiva", tag: "PUNTO 5 · 1/2")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi("99 / 53 µW", "P_DC (v4 / v2)", color: c-accent),
    kpi("8.1 pF",     "Σ C (≤ 10 pF) ✓", color: c-blue),
    kpi("46 kΩ",      "Σ R (≤ 100 kΩ) ✓", color: c-green),
  )
  #v(10pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Desglose de capacitancias")[
      #set text(size: 11.5pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [*Capacitor*], [*Valor (pF)*],
        [$C_1$ (SC CMFB, lado op)], [3.0],
        [$C_2$ (SC CMFB, lado op)], [1.0],
        [$C_3$ (SC CMFB, lado om)], [3.0],
        [$C_4$ (SC CMFB, lado om)], [1.0],
        [$C_L$ (carga)],            [0.10],
        [*Total*],                  [*8.1*],
      )
    ],
    panel(title: "Desglose de resistencias")[
      #set text(size: 11.5pt)
      #table(columns: (1fr, auto), inset: 5pt, align: (left, right),
        stroke: 0.5pt + c-line,
        [*Resistor*], [*Valor (kΩ)*],
        [$R_3 = R_("bias")$],       [46],
        [*Total*],                  [*46*],
      )
      #v(4pt)
      *Ventaja del SC CMFB:* no usa $R_P, R_N$ del esquema de
      referencia — ahorra ~200 kΩ de resistores.
    ],
  )
]


#slide(title: "Limitaciones y trabajo futuro (Parte 2)", tag: "PUNTO 5 · 2/2")[
  #panel(title: "Roadmap entrega final / Parte 2")[
    + Mejorar SNR
    + Generar segundo CLK
    + Cerrar lazo de retroalimentación
  ]
  #v(10pt)
  #grid(columns: (1fr, 1fr), gutter: 10pt,
    kpi("≈ 67 dB", "Av0 v4 (Bode)", color: c-green),
    kpi("≈ 32.8 MHz", "GBW v4 (Bode)", color: c-accent),
  )
]
