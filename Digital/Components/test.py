#!/usr/bin/env python3
"""
Worst-case phi-arithmetic delay sweep for the fir_racx polyphase block.

Rewrites ONLY the Xold PULSE sources, the Xnew .param, and the .measure line in
a copy of your existing SPICE netlist; leaves .subckt / .lib / models / .inc
untouched.  Runs LTspice in batch mode and reports the worst-case delay.

BASE_NETLIST MUST be a SPICE netlist (.net/.cir), NOT a .asc.
(In LTspice: open the .asc -> View > SPICE Netlist -> save.)
"""

import os
import re
import subprocess
import sys

# ----------------------------------------------------------------------
# CONFIG
# ----------------------------------------------------------------------
LTSPICE_EXE = r"C:\Users\Vicente\AppData\Local\Programs\ADI\LTspice\LTspice.exe"
BASE_NETLIST = r"C:\Users\Vicente\Desktop\UC\Semestre 11\Proyectos\ICD\Digital\Components\TestFIR_RACX.net"

VDD = 3.3
VMID = VDD / 2.0
TRF = "100p"
TSWITCH = "5n"

# trig_edge / targ_edge: "RISE", "FALL", or "ANY" (ANY measures whichever edge
# happens -- robust when you are not sure which way the bit moves).
# ROUNDED filter: phi1 = (3*x_old + x_new + 2) >> 2 ; phi2 = (x_old+x_new+1)>>1
# Vectors chosen so the rounded numerator crosses a power-of-2 (full carry
# ripple) AND the output makes a clean, measurable edge.
SCENARIOS = [
    dict(name="A_rise", xold_from=31, xold_to=32, xnew=32,
         trig="xold_5", trig_edge="RISE", targ="phi1_5", targ_edge="RISE",
         note="phi1 31->32, MSB rises; numerator 127->130 crosses 128"),
    dict(name="B_rise", xold_from=0,  xold_to=1,  xnew=61,
         trig="xold_0", trig_edge="RISE", targ="phi1_4", targ_edge="RISE",
         note="phi1 15->16, bit4 rises; S ripples + rounding carry crosses 64"),
    dict(name="C_rise", xold_from=62, xold_to=63, xnew=1,
         trig="xold_0", trig_edge="RISE", targ="phi1_4", targ_edge="RISE",
         note="phi1 47->48, bits4&5 rise; numerator 189->192 crosses 192"),
    dict(name="D_fall", xold_from=32, xold_to=31, xnew=32,
         trig="xold_5", trig_edge="FALL", targ="phi1_5", targ_edge="FALL",
         note="phi1 32->31, MSB falls; rise/fall asymmetry check"),
]


def bits(v):
    return [(v >> i) & 1 for i in range(6)]


def edge_clause(edge):
    """Return the LTspice edge keyword(s) for TRIG/TARG."""
    if edge == "RISE":
        return "RISE=1"
    if edge == "FALL":
        return "FALL=1"
    return "CROSS=1"   # ANY: first crossing in either direction


def absolutize_includes(text, base_dir):
    out = []
    for ln in text.splitlines():
        s = ln.strip()
        m = re.match(r"^(\.(?:inc|include|lib))\s+(.+)$", s, re.IGNORECASE)
        if m:
            directive = m.group(1)
            path = m.group(2).strip().strip('"')
            is_abs = re.match(r"^[A-Za-z]:[\\/]", path) or path.startswith("\\\\")
            if not is_abs:
                path = os.path.normpath(os.path.join(base_dir, path))
            out.append(directive + ' "' + path + '"')
        else:
            out.append(ln)
    return "\n".join(out)


def build_scenario_netlist(base_text, scn, base_dir):
    bf, bt, bn = bits(scn["xold_from"]), bits(scn["xold_to"]), bits(scn["xnew"])
    out = []
    for ln in base_text.splitlines():
        s = ln.strip()
        replaced = False

        m = re.match(r"^(V[1-6])\s+Xold_([0-5])\s", s, re.IGNORECASE)
        if m:
            src = m.group(1).upper()
            bit = int(m.group(2))
            vf = VDD if bf[bit] else 0.0
            vt = VDD if bt[bit] else 0.0
            if vf == vt:
                out.append(src + " Xold_" + str(bit) + " 0 " + str(vf))
            else:
                out.append(src + " Xold_" + str(bit) + " 0 PULSE(" +
                           str(vf) + " " + str(vt) + " " + TSWITCH + " " +
                           TRF + " " + TRF + " 50n 100n 1)")
            replaced = True

        if not replaced and s.lower().startswith(".param xnew_0"):
            parts = " ".join("Xnew_" + str(i) + "=" + str(VDD if bn[i] else 0)
                             for i in range(6))
            out.append(".param " + parts)
            replaced = True

        if not replaced and s.lower().startswith(".measure"):
            replaced = True
        if not replaced and s.lower().startswith(".param xold_0"):
            replaced = True

        if not replaced:
            out.append(ln)

    meas = (".measure tran tdelay TRIG V(" + scn["trig"] + ") VAL=" +
            str(VMID) + " " + edge_clause(scn["trig_edge"]) +
            " TARG V(" + scn["targ"] + ") VAL=" + str(VMID) + " " +
            edge_clause(scn["targ_edge"]))

    final = []
    inserted = False
    for ln in out:
        if not inserted and ln.strip().lower() in (".backanno", ".end"):
            final.append(meas)
            inserted = True
        final.append(ln)
    if not inserted:
        final.append(meas)

    return absolutize_includes("\n".join(final) + "\n", base_dir)


def read_log(log_path):
    """Read the LTspice log, picking the encoding that yields readable text."""
    if not os.path.exists(log_path):
        return None
    for enc in ("utf-16-le", "utf-16", "utf-8", "latin-1"):
        try:
            with open(log_path, "r", encoding=enc) as f:
                t = f.read()
        except (UnicodeError, UnicodeDecodeError):
            continue
        if ("Measurement" in t) or ("elapsed" in t.lower()) or ("Circuit" in t):
            return t
    return None


def tail_log(log_path, n=25):
    t = read_log(log_path)
    if t is None:
        return "(could not read .log in a known encoding)"
    return "\n".join("    " + l for l in t.splitlines()[-n:])


def parse_measure(log_path, meas="tdelay"):
    t = read_log(log_path)
    if not t:
        return None
    # explicit failure?
    if re.search(meas + r"[^\n]*FAIL", t, re.IGNORECASE):
        return None
    m = re.search(meas + r"\s*=\s*([0-9.eE+\-]+)", t, re.IGNORECASE)
    if not m:
        m = re.search(meas + r".*?=\s*([0-9.eE+\-]+)", t, re.IGNORECASE)
    return float(m.group(1)) if m else None


def main():
    if not os.path.exists(BASE_NETLIST):
        sys.exit("Base netlist not found: " + BASE_NETLIST +
                 "\nMust be a SPICE netlist (.net/.cir), not a .asc.")
    if BASE_NETLIST.lower().endswith(".asc"):
        sys.exit("BASE_NETLIST points at a .asc (graphical data). Export via "
                 "View > SPICE Netlist and point at the .net/.cir.")

    base_dir = os.path.dirname(BASE_NETLIST)
    with open(BASE_NETLIST, "r", encoding="latin-1") as f:
        base_text = f.read()

    results = {}
    for scn in SCENARIOS:
        net = build_scenario_netlist(base_text, scn, base_dir)
        net_path = os.path.join(base_dir, "phi_" + scn["name"] + ".cir")
        with open(net_path, "w", encoding="latin-1") as f:
            f.write(net)
        log_path = os.path.splitext(net_path)[0] + ".log"
        print("[run] " + scn["name"].ljust(8) + " (" + scn["note"] + ")")
        try:
            subprocess.run([LTSPICE_EXE, "-b", "-Run", net_path], check=True)
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            print("   ! LTspice exit error: " + str(e))
            print("   --- .log tail ---")
            print(tail_log(log_path))
            results[scn["name"]] = None
            continue
        d = parse_measure(log_path)
        results[scn["name"]] = d
        if d is not None:
            print("   tdelay = {:.4e} s  ({:.3f} ns)".format(d, d * 1e9))
        else:
            print("   ! ran but measurement did not trigger -- .log tail:")
            print(tail_log(log_path))

    print("\n==================== SUMMARY ====================")
    valid = {k: v for k, v in results.items() if v is not None}
    for k, v in results.items():
        print("  " + k.ljust(8) + " : " +
              ("{:.3f} ns".format(v * 1e9) if v is not None else "FAILED"))
    if valid:
        wn = max(valid, key=valid.get)
        w = valid[wn]
        print("-------------------------------------------------")
        print("  WORST-CASE phi delay : {:.3f} ns   (scenario {})"
              .format(w * 1e9, wn))
        print("  Adders stay off the critical path as long as "
              "T(4fs) > {:.3f} ns".format(w / 4 * 1e9))
    print("=================================================")


if __name__ == "__main__":
    main()