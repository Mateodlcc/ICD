#import "template2.typ": *

#show: body => slides-setup(
  title: "OTA cascodo plegado — GF180MCU",
  body,
)

#let state-badge(txt, color: c-muted) = text(size: 8.4pt, weight: "bold", fill: color, txt)

// ============================================================
// PORTADA
// ============================================================
#title-slide(
  course: "IEE3433 · Diseño Analógico · Proyecto Parte II",
  title: "OTA cascodo plegado",
  subtitle: "Dimensionamiento, estabilidad y simulaciones en GF180MCU",
  authors: (
    "Mateo de la Cuadra",
    "Vicente Florez",
    "Alonso Rivera",
  ),
  date: "Junio 2026",
)

// ============================================================
// 1. ESQUEMATICO CON ANOTACIONES DC
// ============================================================
#point-divider("Punto 1", "Esquemático del circuito con anotaciones DC")

#slide(title: "Par diferencial", tag: "PUNTO 1 · 1/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito Par diferencial.jpeg", height: 90%, fit: "contain")
  ]
]

#slide(title: "Cascodo plegado", tag: "PUNTO 1 · 2/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito Cascodo plegado.jpeg", height: 90%, fit: "contain")
  ]
]

#slide(title: "CMFB", tag: "PUNTO 1 · 3/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito CMFB.jpeg", height: 90%, fit: "contain")
  ]
]

#slide(title: "Phase generator", tag: "PUNTO 1 · 4/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito Phase Generator.jpeg", height: 90%, fit: "contain")
  ]
]

#slide(title: "Master branch", tag: "PUNTO 1 · 5/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito Master Branch.jpeg", height: 90%, fit: "contain")
  ]
]

#slide(title: "Espejos de corriente", tag: "PUNTO 1 · 6/6")[
  #align(center)[
    #image("imgs_p2/1.- Circuito Espejos de corriente.jpeg", height: 90%, fit: "contain")
  ]
]

// ============================================================
// 2. TABLA DE ESPECIFICACIONES
// ============================================================
#point-divider("Punto 2", "Tabla de especificaciones")

#slide(title: "Cumplimiento de especificaciones", tag: "PUNTO 2")[
  #set text(size: 7.35pt)
  #table(
    columns: (1.08fr, 1.12fr, 0.9fr, 0.95fr, 0.68fr),
    inset: 3.4pt,
    align: (left, left, right, right, center),
    stroke: 0.5pt + c-line,
    fill: (_, y) => if y == 0 { c-accent-soft },
    [*Especificación*], [*Requerido por el proyecto*], [*Predicción (cálculos a mano)*], [*Simulación (SPICE)*], [*Cumplimiento*],
    [Ganancia de voltaje de lazo abierto], [>= 60 dB], [62.88 dB], [66.08 dB], [#state-badge("Cumple", color: c-accent)],
    [Ancho de banda], [Sin mínimo requerido], [24.58 MHz], [11.67 MHz], [#state-badge("Ref.", color: c-muted)],
    [Producto ganancia-ancho de banda], [GBW >= 20 MHz], [38 MHz], [23.5 MHz], [#state-badge("Cumple", color: c-accent)],
    [Potencia DC], [Minimizar], [51.52 µW], [55.67 µW], [#state-badge("Reportado", color: c-muted)],
    [Excursión de voltaje], [2 V con ganancia DC >= 0.5 kV/V], [2.93 V], [2.51 V], [#state-badge("Cumple", color: c-accent)],
    [CMRR en DC], [>= 60 dB], [41.54 dB (estimación incompleta)], [176.38 dB], [#state-badge("Cumple", color: c-accent)],
    [PSRR en DC], [>= 60 dB], [344.14 dB], [284.48 dB], [#state-badge("Cumple", color: c-accent)],
    [SNR], [>= 60 dB], [44.94 dB], [29.22 dB], [#state-badge("No cumple", color: c-warn)],
    [Margen de fase], [> 60° para $beta=1$], [64.44° (buffer)], [74.35° (buffer)], [#state-badge("Cumple", color: c-accent)],
    [Frecuencia de crossover], [Referencia de estabilidad], [27.2 MHz (buffer)], [20.98 MHz (buffer)], [#state-badge("Ref.", color: c-muted)],
    [Tiempo de subida y caída 10%-90%], [<= 50 ns con escalón diferencial de 1 V y $beta=0.7$], [N/A], [$t_r=30.48$ ns, $t_f=34.7$ ns], [#state-badge("Cumple", color: c-accent)],
    [Capacitancia total del amplificador], [< 10 pF], [N/A], [CMFB 22 fF + realim. 111 fF = 133 fF], [#state-badge("Cumple", color: c-accent)],
    [Resistencia total], [< 100 kΩ], [N/A], [51.66 kΩ], [#state-badge("Cumple", color: c-accent)],
    [Razón de espejos de corriente], [<= 10], [N/A], [3, 2 y 2], [#state-badge("Cumple", color: c-accent)],
  )
  #v(3pt)
  #text(size: 8.4pt, fill: c-muted)[
    La fila de tiempo usa la simulación con CMFB ideal y CMFB real conectado como carga capacitiva.
    La SNR queda bajo la especificación; CMRR y PSRR cumplen con margen amplio.
  ]
]

// ============================================================
// 3. ANALISIS AC EN LAZO ABIERTO
// ============================================================
#point-divider("Punto 3", "Análisis AC en lazo abierto")

#slide(title: "Respuesta AC: lazo abierto", tag: "PUNTO 3")[
  #grid(columns: (1.22fr, 0.78fr), gutter: 12pt,
    img-card(
      "imgs_p2/3.- AC_oc.jpeg",
      "Análisis AC en lazo abierto",
      caption: "Respuesta AC diferencial del OTA.",
      img-height: 7.55cm,
    ),
    [
      #panel(title: "Cálculo de la ganancia", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 13pt)
        #v(3pt)
        $A_(v 0) = g_(m 1) dot (g_(m 2) r_(o 2) (r_(o 1) || r_(o 3)) || g_(m 4) r_(o 4) r_(o 5))$
      ]
      #v(7pt)
      #panel(title: "Polo dominante y GBW")[
        #set text(size: 11pt)
        $tau = R_o C_("eq")$
        #linebreak()
        $f_p = 1 / (2 pi tau)$
        #linebreak()
        $"GBW" approx A_(v 0) f_p$
      ]
      #v(7pt)
      #table(
        columns: (1fr, auto, auto),
        inset: 4pt,
        align: (left, right, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { c-accent-soft },
        [*Métrica*], [*Teórico*], [*SPICE*],
        [$A_(v 0)$], [62.88 dB], [66.08 dB],
        [$f_p$], [27.28 kHz], [11.67 kHz],
        [GBW], [38 MHz], [23.5 MHz],
      )
    ],
  )
]

#slide(title: "Discrepancias entre cálculo y SPICE", tag: "PUNTO 3")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Sobredimensionamiento del par diferencial", fill: c-accent-soft, stroke-c: c-accent)[
      #set text(size: 12pt)
      El par de entrada se sobredimensionó para asegurar margen de $g_m$ y GBW.
      Esto desplaza el punto real respecto del modelo de hoja y aumenta las
      capacitancias asociadas al par.
    ],
    panel(title: "Capacitancias parásitas de salida")[
      #set text(size: 12pt)
      El cálculo manual usa $tau = R_o C_("eq")$ con una capacitancia simplificada.
      En SPICE aparecen $C_("db")$, $C_("gd")$ y capacitancias de interconexión
      en el nodo de salida, que es de alta impedancia.
    ],
  )
  #v(9pt)
  #panel(title: "Lectura del resultado")[
    #set text(size: 12pt)
    La ganancia simulada queda 3.2 dB por sobre la estimación. El GBW simulado
    queda sobre 20 MHz, pero cae respecto del cálculo porque el polo dominante
    se mueve de 27.28 kHz a 11.67 kHz al incluir las parásitas del circuito real.
  ]
]

// ============================================================
// 4. T(S) CON BETA = 0.7
// ============================================================
#point-divider("Punto 4", "T(s) y estabilidad con beta = 0.7")

#slide(title: "Loop gain y estabilidad", tag: "PUNTO 4")[
  #grid(columns: (1.22fr, 0.78fr), gutter: 12pt,
    img-card(
      "imgs_p2/4.- T(s) beta=0.7.jpeg",
      "T(s) con beta=0.7",
      caption: "No fue necesario agregar compensación.",
      img-height: 7.35cm,
    ),
    [
      #panel(title: "Ecuaciones de estabilidad", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11pt)
        $T(s) = beta A(s)$
        #linebreak()
        $f_c: abs(T(j 2 pi f_c)) = 1$
        #linebreak()
        $"PM" = 180 degree + angle T(j 2 pi f_c)$
        #linebreak()
        $"GM" = 1 / abs(T(j 2 pi f_(180)))$
      ]
      #v(7pt)
      #panel(title: "Resultado de diseño")[
        #set text(size: 11.4pt)
        La estabilidad se logra con el OTA tal como fue dimensionado. La carga
        capacitiva y los polos internos entregan margen suficiente para el lazo
        evaluado, por lo que no se incorporó red de compensación adicional.
      ]
    ],
  )
]

// ============================================================
// 5. TRANSIENTE ESCALON DIFERENCIAL
// ============================================================
#point-divider("Punto 5", "Transiente con escalón diferencial")

#slide(title: "Escalón diferencial: respuesta completa", tag: "PUNTO 5")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    img-card(
      "imgs_p2/5.- Simulación transiente y escalón diferencial.jpeg",
      "Transiente con escalón diferencial",
      img-height: 6.4cm,
    ),
    img-card(
      "imgs_p2/5.- Simulación transiente y escalón diferencial (zoom).jpeg",
      "Zoom de la transición",
      img-height: 6.4cm,
    ),
  )
  #v(6pt)
  #panel(fill: c-panel)[
    Simulación del OTA realimentado con $beta=0.7$ y escalón diferencial de entrada.
  ]
]

#slide(title: "Escalón diferencial con CMFB ideal", tag: "PUNTO 5")[
  #grid(columns: (1.22fr, 0.78fr), gutter: 12pt,
    img-card(
      "imgs_p2/5.- Simulación transiente y escalón diferencial (CMFB ideal).jpeg",
      "CMFB ideal con CMFB real como carga capacitiva",
      img-height: 7.25cm,
    ),
    [
      #kpi("30.48 ns", "tiempo de subida 10%-90%")
      #v(8pt)
      #kpi("34.7 ns", "tiempo de bajada 10%-90%")
      #v(8pt)
      #panel(title: "Comparación con especificación", fill: c-accent-soft, stroke-c: c-accent)[
        Ambos tiempos quedan bajo el límite de *50 ns* para escalón diferencial
        de 1 V y $beta=0.7$.
      ]
    ],
  )
]

// ============================================================
// 6. TRANSIENTE SINUSOIDAL
// ============================================================
#point-divider("Punto 6", "Transiente sinusoidal y excursión máxima")

#slide(title: "Sinusoide diferencial: excursión de salida", tag: "PUNTO 6")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    img-card(
      "imgs_p2/6.- Simulación transiente y sinusoide diferencial.jpeg",
      "Transiente con sinusoide diferencial",
      img-height: 6.4cm,
    ),
    img-card(
      "imgs_p2/6.- Simulación transiente y sinusoide diferencial (zoom).jpeg",
      "Zoom de la sinusoide",
      img-height: 6.4cm,
    ),
  )
  #v(6pt)
  #panel(fill: c-panel)[
    Esta simulación se usa para determinar la excursión máxima antes de distorsión
    o recorte visible en la salida.
  ]
]

#slide(title: "Sinusoide con CMFB ideal", tag: "PUNTO 6")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 12pt,
    img-card(
      "imgs_p2/6.- Simulación transiente y sinusoide diferencial (CMFB ideal).jpeg",
      "Sinusoide diferencial con CMFB ideal",
      caption: "CMFB real conectado como carga capacitiva.",
      img-height: 7.25cm,
    ),
    panel(title: "Uso del resultado", fill: c-accent-soft, stroke-c: c-accent)[
      Esta corrida separa el efecto dinámico del CMFB real de la carga capacitiva
      que introduce sobre el OTA. Sirve como referencia para estimar la excursión
      máxima de salida sin que el lazo de modo común limite la comparación.
    ],
  )
]

// ============================================================
// 7. CONSIDERACIONES DE DISEÑO
// ============================================================
#point-divider("Punto 7", "Consideraciones de diseño")

#slide(title: "Compensación, realimentación y bias", tag: "PUNTO 7")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    kpi("sin red", "compensación adicional"),
    kpi([$beta=0.7$], "realimentación capacitiva"),
    kpi("3 · 2 · 2", "factores de espejos"),
  )
  #v(8pt)
  #grid(columns: (1.1fr, 0.9fr), gutter: 12pt,
    panel(title: "Red de realimentación", fill: c-accent-soft, stroke-c: c-accent)[
      #set text(size: 12pt)
      $beta = C_f / (C_f + C_s + C_("in"))$
      #v(6pt)
      #table(
        columns: (1fr, auto),
        inset: 5pt,
        align: (left, right),
        stroke: 0.5pt + c-line,
        fill: (_, y) => if y == 0 { white },
        [*Parámetro*], [*Valor*],
        [$C_f$], [91 fF],
        [$C_s$], [20 fF],
        [$C_("in")$ considerado], [incluido en el cálculo],
        [$beta$ objetivo], [0.7],
      )
    ],
    [
      #panel(title: "Compensación")[
        #set text(size: 11.2pt)
        No se utilizó compensación adicional. La estabilidad se obtuvo con la
        topología, la carga y la red de realimentación dimensionada.
      ]
      #v(7pt)
      #panel(title: "Generación de polarización")[
        #set text(size: 11.2pt)
        Se usaron baterías mágicas para cerrar los voltajes de bias. Las ramas
        copian la corriente de la *master current branch* con factor 2, y los
        espejos internos usan factores 3, 2 y 2.
      ]
    ],
  )
]

// ============================================================
// 8. OTROS RESULTADOS IMPORTANTES
// ============================================================
#point-divider("Punto 8", "Otros resultados importantes")

#slide(title: "Excursión de salida", tag: "PUNTO 8 · 1/3")[
  #align(center)[
    #image("imgs_p2/8.- Excursión de salida.jpeg", width: 100%, height: 8.7cm, fit: "contain")
  ]
]

#slide(title: "Ruido integrado de salida", tag: "PUNTO 8 · 2/3")[
  #grid(columns: (1.25fr, 0.75fr), gutter: 12pt,
    img-card(
      "imgs_p2/8.- Ruido.jpeg",
      "Ruido de salida",
      caption: "Integración de ruido desde 1 kHz hasta 100 MHz.",
      img-height: 7.25cm,
    ),
    [
      #kpi("61.4 mV", "ruido RMS integrado")
      #v(8pt)
      #panel(title: "Resultado SPICE", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11.2pt)
        `vnoise_rms: INTEG(v(onoise)) = 0.0613966`
        #v(4pt)
        Intervalo de integración: *1 kHz* a *100 MHz*.
      ]
      #v(8pt)
      #panel(title: "Intento de mejora")[
        Se probó la propuesta de aumentar el $g_m$ de los transistores de entrada
        para mejorar el SNR, pero no se obtuvo una mejora efectiva.
      ]
    ],
  )
]

#slide(title: "CMFB con capacitores conmutados", tag: "PUNTO 8 · 3/3")[
  #grid(columns: (1.2fr, 0.8fr), gutter: 12pt,
    img-card(
      "imgs_p2/1.- Circuito CMFB.jpeg",
      "Circuito CMFB",
      img-height: 7.25cm,
    ),
    [
      #panel(title: "Topología Choksi-Carley", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11.2pt)
        Se aprovechó la topología de Choksi y Carley para implementar el CMFB
        con capacitores conmutados sin variar la capacitancia vista por la salida
        durante el cambio de fase.
      ]
      #v(8pt)
      #panel(title: "Capacitancia constante")[
        #set text(size: 11.2pt)
        Al conmutar se selecciona el $C_1$ a utilizar, mientras $C_2$ permanece
        activo en todo momento. Así, la salida percibe una carga constante:
        #v(5pt)
        #align(center)[#text(size: 15pt, weight: "bold")[$C_("out,CMFB") = C_1 + C_2 = 22$ fF]]
      ]
    ],
  )
]

// ============================================================
// ANEXO — CÁLCULOS TEÓRICOS
// ============================================================
#point-divider("Anexo", "Cálculos teóricos de métricas")

#slide(title: "Anexo: potencia DC", tag: "ANEXO")[
  #grid(columns: (1.1fr, 0.9fr), gutter: 12pt,
    panel(title: "Modelo usado", fill: c-accent-soft, stroke-c: c-accent)[
      #set text(size: 13pt)
      $P = V_("DD") (I_("OTA") + I_("espejos") + f_("ck,CMFB") (C_("CMFB") + C_L))$
      #v(8pt)
      El modelo suma la corriente del OTA, la corriente de espejos y el término
      dinámico asociado al CMFB conmutado.
    ],
    [
      #kpi("51.52 µW", "predicción teórica")
      #v(8pt)
      #kpi("55.67 µW", "resultado SPICE")
    ],
  )
]

#slide(title: "Anexo: excursión de salida", tag: "ANEXO")[
  #grid(columns: (1.1fr, 0.9fr), gutter: 12pt,
    panel(title: "Headroom de salida", fill: c-accent-soft, stroke-c: c-accent)[
      #set text(size: 12.2pt)
      $V_("o,min") = V_("ov,M9") + V_("ov,M7")$
      #linebreak()
      $V_("o,max") = V_("DD") - ("abs"(V_("ov,M5")) + "abs"(V_("ov,M3")))$
      #linebreak()
      $V_("swing") = V_("o,max") - V_("o,min")$
    ],
    [
      #kpi("2.93 V", "predicción teórica")
      #v(8pt)
      #kpi("2.51 V", "resultado SPICE")
      #v(8pt)
      #panel(title: "Criterio")[
        Se compara contra la especificación de 2 V con ganancia DC mayor o igual
        a 0.5 kV/V.
      ]
    ],
  )
]

#slide(title: "Anexo: CMRR", tag: "ANEXO")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 12pt,
    [
      #panel(title: "Estimación usada", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 12.2pt)
        $A_("cm") = R_o / (2 r_("tail"))$
        #linebreak()
        $"CMRR" = 20 log_10(A_("v,teorico")) - 20 log_10(A_("cm"))$
      ]
      #v(8pt)
      #panel(title: "Limitación del cálculo")[
        Este cálculo no considera correctamente el largo del transistor de cola.
        Justamente se usó $L=4.48$ µm para aumentar $r_("tail")$, por lo que la
        estimación queda penalizada.
      ]
    ],
    [
      #kpi("41.54 dB", "predicción teórica")
      #v(8pt)
    ],
  )
]

#slide(title: "Anexo: PSRR", tag: "ANEXO")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 12pt,
    [
      #panel(title: [Estimación de $A_("vdd")$], fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 10.4pt)
        `Rcas = gm4*ro4*ro5`
        #linebreak()
        `Avdd = (1/ro3) * par(Rcas, par(Rcas,ro2) * par(ro1,ro2) * gm2)**-1`
      ]
      #v(8pt)
      #panel(title: "Cálculo de rechazo")[
        #set text(size: 12.2pt)
        $"PSRR" = 20 log_10(A_("v,teorico")) - 20 log_10(A_("vdd"))$
      ]
    ],
    [
      #kpi("344.14 dB", "predicción teórica")
      #v(8pt)
    ],
  )
]

#slide(title: "Anexo: SNR", tag: "ANEXO")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 12pt,
    [
      #panel(title: "Ruido referido a entrada", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 10.8pt)
        $i_("n,in") = (4 k T gamma / g_(m 1)) (1 + g_(m 3)/g_(m 1) + g_(m 5)/g_(m 1))$
        #v(4pt)
        $v_("n,out,rms") = sqrt(i_("n,in") A_("v,teorico")^2 (pi/2) f_p)$
      ]
      #v(8pt)
      #panel(title: "Relación señal/ruido")[
        #set text(size: 12pt)
        $"SNR" = 20 log_10((V_("swing") / sqrt(2)) / v_("n,out,rms"))$
      ]
    ],
    [
      #kpi("44.94 dB", "predicción teórica")
      #v(8pt)
      #panel(title: "Desde el notebook")[
        La estructura corresponde a `inoise_folded_cas` y
        `onoise_rms_folded_cas` de `ota_LP.ipynb`.
      ]
    ],
  )
]
