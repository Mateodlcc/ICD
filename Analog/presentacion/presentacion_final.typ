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
// FLUJO GENERAL DE DISEÑO
// ============================================================
#point-divider("Diseño", "Flujo general seguido")

#slide(title: "Flujo general de diseño del sistema", tag: "FLUJO DE DISEÑO")[
  #set text(size: 11.5pt)

  #flow(
    dblock("Especificaciones"), arr,
    dblock([$g_m / I_D$ del par]), arr,
    dblock("Corrientes"), arr,
    dblock("Cascodo plegado"),
  )
  #v(8pt)
  #align(center)[#text(size: 17pt, fill: c-accent)[↓]]
  #v(5pt)
  #flow(
    dblock("Bias y espejos"), arr,
    dblock("CMFB y realimentación"), arr,
    dblock("Verificación SPICE"), arr,
    dblock("Iteración y cierre"),
  )

  #v(11pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Dimensionamiento del OTA", fill: c-accent-soft, stroke-c: c-accent)[
      Se partió de las especificaciones y del nivel de inversión del par de
      entrada. Luego se fijaron las corrientes según los compromisos de
      transconductancia, ancho de banda y potencia, y se dimensionó el cascodo
      plegado buscando ganancia sin perder excursión de salida.
    ],
    panel(title: "Integración y cierre del diseño")[
      Las corrientes se distribuyeron mediante la rama maestra y los espejos.
      Después se incorporaron el CMFB y la red de realimentación, y se verificó
      el sistema mediante análisis DC, AC, estabilidad, transiente y ruido.
      Los resultados SPICE guiaron las iteraciones hasta el circuito final.
    ],
  )
  #v(6pt)
  #align(center)[
    #text(size: 9.5pt, fill: c-muted)[
      Los esquemáticos de la sección siguiente contienen los valores finales de diseño.
    ]
  ]
]

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
    [CMRR en DC], [>= 60 dB], [41.54 dB (estimación incompleta)], [304.08 dB ($A_("v,CM")=-238$ dB)], [#state-badge("Cumple", color: c-accent)],
    [PSRR en DC], [>= 60 dB], [344.14 dB], [268.08 dB ($A_("v,VDD")=-202$ dB)], [#state-badge("Cumple", color: c-accent)],
    [SNR en lazo cerrado (OL como referencia)], [>= 60 dB en operación CL], [44.94 dB (modelo OL)], [75.36 dB CL; 29.22 dB OL], [#state-badge("Cumple", color: c-accent)],
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
    Para la SNR: $v_("n,rms")=302.762$ µV en CL y 61.3966 mV en OL, integrados entre 1 kHz y 100 MHz.
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
        [$C_("in")$ considerado], [$approx 1.64 times 10^(-14)$ F (16.44 fF)],
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

#slide(title: "Ruido integrado de salida: OL y CL", tag: "PUNTO 8 · 1/2")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    img-card(
      "imgs_p2/8.- Ruido OL.jpeg",
      "Ruido en lazo abierto (OL)",
      caption: "Integración de ruido desde 1 kHz hasta 100 MHz.",
      img-height: 4.45cm,
    ),
    img-card(
      "imgs_p2/8.- Ruido CL.jpeg",
      "Ruido en lazo cerrado (CL)",
      caption: "Condición de operación usada para verificar la especificación.",
      img-height: 4.45cm,
    ),
  )
  #v(6pt)
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    panel(title: "Resultado OL")[
      #set text(size: 10.5pt)
      $v_("n,rms")=61.3966$ mV → $"SNR"=29.22$ dB.
    ],
    panel(title: "Resultado CL", fill: c-accent-soft, stroke-c: c-accent)[
      #set text(size: 10.5pt)
      $v_("n,rms")=302.762$ µV → $"SNR"=75.36$ dB *✓*.
    ],
  )
]

#slide(title: "CMFB con capacitores conmutados", tag: "PUNTO 8 · 2/2")[
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
      #v(6pt)
      #text(size: 7.8pt, fill: c-muted)[
        *Referencia:* O. Choksi y L. R. Carley, “Analysis of
        Switched-Capacitor Common-Mode Feedback Circuit,” _IEEE Transactions
        on Circuits and Systems II_, vol. 50, no. 12, pp. 906–917, dic. 2003.
        #link("https://doi.org/10.1109/TCSII.2003.820253")[DOI: 10.1109/TCSII.2003.820253].
      ]
    ],
  )
]

// ============================================================
// ANEXO — CÁLCULOS TEÓRICOS Y RESULTADOS DE SIMULACIÓN
// ============================================================
#point-divider("Anexo", "Cálculo teórico y obtención de métricas en SPICE")

#slide(title: "Anexo: potencia DC", tag: "ANEXO")[
  #grid(columns: (1fr, 1fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11.5pt)
        $P = V_("DD") (I_("OTA") + I_("espejos") + f_("ck,CMFB") (C_("CMFB") + C_L))$
        #v(7pt)
        Se suman las corrientes estáticas del OTA y los espejos, junto con el
        término dinámico debido a la conmutación del CMFB.
      ]
      #v(8pt)
      #kpi("51.52 µW", "predicción teórica")
    ],
    [
      #panel(title: "Resultado de simulación")[
        #set text(size: 10.8pt)
        La potencia total suma el consumo analógico y el de la parte digital
        que genera el clock:
        #v(5pt)
        $P_("analog") = abs("avg"(v_("DD") I_("DD")))$
        #linebreak()
        $P_("clk") = abs("avg"(v_("clk") I_("clk")))$
        #linebreak()
        $P_("DC,SPICE") = P_("analog") + P_("clk")$
        #v(5pt)
        Los valores se toman con el signo ajustado según la convención de las
        fuentes de LTspice.
      ]
      #v(8pt)
      #kpi("55.67 µW", "resultado SPICE")
    ],
  )
]

#slide(title: "Anexo: excursión de salida", tag: "ANEXO")[
  #grid(columns: (0.9fr, 1.1fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11.5pt)
        $V_("o,min") = V_("ov,M9") + V_("ov,M7")$
        #linebreak()
        $V_("o,max") = V_("DD") - ("abs"(V_("ov,M5")) + "abs"(V_("ov,M3")))$
        #linebreak()
        $V_("swing") = V_("o,max") - V_("o,min")$
      ]
      #v(8pt)
      #kpi("2.93 V", "predicción teórica")
    ],
    [
      #panel(title: "Resultado de simulación")[
        #image("imgs_p2/A.- Excursión de salida.jpeg", width: 100%, height: 4.5cm, fit: "contain")
        #v(3pt)
        #text(size: 10.5pt)[La zona con ganancia diferencial $>=0.5$ kV/V entrega una excursión de *2.51 V*.]
      ]
      #v(6pt)
      #kpi("2.51 V", "resultado SPICE")
    ],
  )
]

#slide(title: "Anexo: CMRR", tag: "ANEXO")[
  #grid(columns: (0.9fr, 1.1fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 11.2pt)
        $A_("cm") = R_o / (2 r_("tail"))$
        #linebreak()
        $"CMRR" = 20 log_10(A_("v,teorico")) - 20 log_10(A_("cm"))$
      ]
      #v(6pt)
      #panel(title: "Limitación del modelo")[
        #set text(size: 10.2pt)
        Este cálculo no considera correctamente el largo del transistor de cola.
        Como se usó un largo elevado para aumentar $r_("tail")$, la estimación
        teórica queda penalizada.
      ]
      #v(6pt)
      #kpi("41.54 dB", "predicción teórica")
    ],
    [
      #panel(title: "Resultado de simulación")[
        #image("imgs_p2/A.- Av_CM.jpeg", width: 100%, height: 4.35cm, fit: "contain")
        #v(3pt)
        #set text(size: 10.5pt)
        $A_("v,diff")=66.08$ dB y $A_("v,CM")=-238$ dB.
        #linebreak()
        $"CMRR"_("SPICE") = A_("v,diff") - A_("v,CM") = 304.08$ dB.
      ]
      #v(6pt)
      #kpi("304.08 dB", "CMRR simulado")
    ],
  )
]

#slide(title: "Anexo: PSRR", tag: "ANEXO")[
  #grid(columns: (0.9fr, 1.1fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 9.8pt)
        `Rcas = gm4*ro4*ro5`
        #linebreak()
        `Avdd = (1/ro3) * par(Rcas, par(Rcas,ro2) * par(ro1,ro2) * gm2)**-1`
        #v(5pt)
        $"PSRR" = 20 log_10(A_("v,teorico")) - 20 log_10(A_("vdd"))$
      ]
      #v(8pt)
      #kpi("344.14 dB", "predicción teórica")
    ],
    [
      #panel(title: "Resultado de simulación")[
        #image("imgs_p2/A.- Av_Vdd.jpeg", width: 100%, height: 4.35cm, fit: "contain")
        #v(3pt)
        #set text(size: 10.5pt)
        $A_("v,diff")=66.08$ dB y $A_("v,VDD")=-202$ dB.
        #linebreak()
        $"PSRR"_("SPICE") = A_("v,diff") - A_("v,VDD") = 268.08$ dB.
      ]
      #v(6pt)
      #kpi("268.08 dB", "PSRR simulado")
    ],
  )
]

#slide(title: "Anexo: frecuencia de crossover y margen de fase", tag: "ANEXO")[
  #grid(columns: (1.12fr, 0.88fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 9.25pt)
        $C_("in") = C_("gs,pair") + (1 + g_("m,pair")/g_("m,p")) C_("gd,pair")$
        #linebreak()
        $C_("L,eff") = C_L + C_("CMFB") + C_("par,out") + C_("in") = 149.07$ fF
        #v(4pt)
        $omega_c = g_("m,pair") / C_("L,eff")$,
        $f_c = omega_c/(2 pi) = 27.22$ MHz
        #v(5pt)
        #table(
          columns: (1fr, auto),
          inset: 3pt,
          align: (left, right),
          stroke: 0.5pt + c-line,
          fill: (_, y) => if y == 0 { white },
          [*Polo*], [*Frecuencia*],
          [Dominante, salida], [18.23 kHz],
          [Nodo intermedio $x$], [69.31 MHz],
          [Nodo intermedio $z$], [374.36 MHz],
        )
        #v(5pt)
        $"PM" = 180 degree - ("atan"(omega_c/omega_(p 1)) +
        "atan"(omega_c/omega_(p x)) + "atan"(omega_c/omega_(p z)))$
        #linebreak()
        #align(center)[$"PM" = 64.44 degree$]
      ]
    ],
    [
      #kpi("27.22 MHz", "frecuencia de crossover teórica")
      #v(12pt)
      #kpi("64.44°", "margen de fase teórico")
    ],
  )
]

#slide(title: "Anexo: SNR", tag: "ANEXO")[
  #grid(columns: (0.95fr, 1.05fr), gutter: 12pt,
    [
      #panel(title: "Cálculo teórico", fill: c-accent-soft, stroke-c: c-accent)[
        #set text(size: 9.5pt)
        $i_("n,in") = (4 k T gamma / g_(m 1)) (1 + g_(m 3)/g_(m 1) + g_(m 5)/g_(m 1))$
        #v(4pt)
        $B_n = 1/(2 pi) integral_0^infinity 1/(1 + (omega/omega_p)^2) dif omega
        = (pi/2) f_p$
        #v(4pt)
        $v_("n,out,rms") = sqrt(i_("n,in") A_("v,teorico")^2 B_n)$
        #v(4pt)
        $"SNR" = 20 log_10((V_("swing") / sqrt(2)) / v_("n,out,rms"))$
      ]
      #v(7pt)
      #kpi("44.94 dB", "predicción teórica OL")
    ],
    [
      #panel(title: "Resultados de simulación")[
        #set text(size: 10.3pt)
        Con $V_("signal,rms")=2.51/sqrt(2)=1.775$ V:
        #v(5pt)
        #table(
          columns: (0.55fr, 1.25fr, 0.8fr),
          inset: 4pt,
          align: (left, right, right),
          stroke: 0.5pt + c-line,
          fill: (_, y) => if y == 0 { c-accent-soft },
          [*Condición*], [*$v_("noise,rms")$*], [*SNR*],
          [OL], [61.3966 mV], [29.22 dB],
          [CL], [302.762 µV], [75.36 dB],
        )
        #v(5pt)
        $"SNR" = 20 log_10(V_("signal,rms") / v_("noise,rms"))$
        #v(4pt)
        El requisito corresponde a la operación en lazo cerrado.
      ]
      #v(7pt)
      #kpi("75.36 dB", "SNR simulada en CL")
    ],
  )
]
