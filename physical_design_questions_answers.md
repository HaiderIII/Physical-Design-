# Junior Physical Design Interview Q&A

A comprehensive reference for **junior-level physical design interviews**, with 28 questions, answers, and numeric examples.

---

## Table of Contents

- [Floorplanning & Placement](#floorplanning--placement)
- [Clock Tree Synthesis (CTS) & Timing](#clock-tree-synthesis-cts--timing)
- [Static Timing Analysis (STA)](#static-timing-analysis-sta)
- [Power, IR Drop & EM](#power-ir-drop--em)
- [Cell Sizing, Buffers & ECO](#cell-sizing-buffers--eco)
- [Signal Integrity & Crosstalk](#signal-integrity--crosstalk)

---

## Floorplanning & Placement

### Q1: Core Utilization
**Your answer:** Fraction of area occupied  
**Assessment:** Correct  
**Complete answer:**  
\[
\text{Core Utilization} = \frac{\text{Occupied Area}}{\text{Total Core Area}} \times 100\%
\]  

### Q2: LEF, DEF, SDC
**Your answer:** LEF = layout, DEF = PnR output, SDC = timing constraints  
**Assessment:** Conceptually correct  
**Complete answer:**  
- LEF: cell dimensions, pins, routing layers  
- DEF: placement/routing info  
- SDC: timing constraints, clocks, exceptions  

### Q19: Placement / Routing Blockage
**Your answer:** Hard vs soft  
**Assessment:** Correct  
**Complete answer:**  
- Hard: forbids placement/routing  
- Soft: limits density  

### Q20: Keepout vs Blockage
**Your answer:** Keepout moves with macro; blockage fixed  
**Complete answer:** Keepout margin ~0.5 µm  

### Q22: Congestion Mitigation
**Your answer:** Blockages, macro grouping, split HFNs  
**Complete answer:** Methods: define blockages, limit density, join macros, split HFNs, layer promotion  

---

## Clock Tree Synthesis (CTS) & Timing

### Q3: Clock Skew
**Your answer:** Difference of clock arrival  
**Assessment:** Correct  
**Complete answer:** Positive skew helps setup, may hurt hold; negative skew helps hold, may hurt setup  

### Q4: Setup & Hold Inequalities
**Your answer:** Tclk > Tcq + Tcombo + Tsetup - Tskew  
**Complete answer:**  
\[
\text{Setup: } T_{clk} \ge T_{CQ(max)} + D_{max} + T_{setup} + T_{skew}
\]  
\[
\text{Hold: } T_{CQ(min)} + D_{min} \ge T_{hold} + T_{skew}
\]

### Q5: Setup vs Hold
**Your answer:** Setup violation → late; Hold violation → early  
**Complete answer:** Fix with skew, upsizing/downsizing, buffers  

### Q23: CTS / Clock Trees
**Your answer:** H-tree spreads clock  
**Complete answer:** H-tree / A-tree with buffers, minimal skew/latency  

### Q24: Clock Latency
**Your answer:** Source + network latency  
**Complete answer:** Total = T_source + T_network  

### Q18: Multi-Cycle Path
**Your answer:** Wait several clocks  
**Complete answer:** STA uses N*T_clk - T_setup  

---

## Static Timing Analysis (STA)

### Q15: STA Slack Computation
**Your answer:** Setup slack = 80 ps, hold margin = 10 ps  
**Complete answer:** Step-by-step calculation with formulas  

### Q16: Skew Impact
**Your answer:** Positive helps setup; negative helps hold  
**Complete answer:** Example numeric computation with +20/-20 ps skew  

### Q17: Setup Calculation Formula
**Your answer:** Tclk + Tskew - Tsetup - (Tcq + D)  
**Complete answer:** Formula aligns with industrial convention  

### Q6: False Path
**Your answer:** Branch never activated  
**Complete answer:** Ignored in STA  

### Q25: MMMC Corners
**Your answer:** Worst-case: 0.9 V, 125°C  
**Complete answer:** Setup: slow corner, Hold: fast corner  

### Q14: Signal Integrity / Crosstalk
**Your answer:** Current check; no violation  
**Complete answer:** ΔV = VDD * Cc / (Cc + Cv); mitigation: spacing, shielding, routing layers  

### Q28: Signal Integrity / Crosstalk Numeric
**Your answer:** Not answered  
**Complete answer:** ΔV = 1 * 10/60 ≈ 0.167 V  

---

## Power, IR Drop & EM

### Q10: Power Grid & IR Drop
**Your answer:** VDD/VSS, vias, metal layers  
**Complete answer:** Example Vdrop calculation; mitigation: wider rails, multiple vias  

### Q11: Electromigration (EM)
**Your answer:** EM constraints, antenna  
**Complete answer:** Compute J = I/A, check against allowed current, widen trace if violation  

### Q26: Electromigration Numeric
**Your answer:** Not computed  
**Complete answer:** Area = 0.24 µm², I = 2.5 mA → violation factor ~10  

### Q21: Power / Ground Pins
**Your answer:** VDD powers, VSS ground, data, clock  
**Complete answer:** VDD/VSS supply, Data logical signal, Clock sync FFs  

---

## Cell Sizing, Buffers & ECO

### Q12: Cell Upsizing / Buffer / Spare Cells
**Your answer:** Upsize, buffer, spare, physical-only  
**Complete answer:** Detailed effects and timing numeric examples  

### Q27: Cell Sizing / Buffers Numeric
**Your answer:** Concept only  
**Complete answer:** Arrival = 350, required = 340 → buffer pair fixes slack → minimum fix  

### Q13: ECO
**Your answer:** Post-PnR change  
**Complete answer:** Types: RTL, gate-level, metal-only  

---

## Signal Integrity & Crosstalk

### Q14: Signal Integrity / Crosstalk
**Your answer:** EM/antenna check  
**Complete answer:** ΔV = 0.167 V, mitigation: spacing, shielding, routing  

## Static Timing Analysis (STA) – Questions 15 à 22

### Q15: STA Slack Computation
**Question:** Compute setup and hold slack:  
T_CQ(max) = 80 ps, D_max = 420 ps, T_setup = 90 ps, T_clk = 700 ps, T_skew = 30 ps  
T_CQ(min) = 25 ps, D_min = 65 ps, T_hold = 50 ps  

**Your answer:**  
> Setup slack = 80 ps, Hold slack = 10 ps  

**Assessment:** Correct conceptually  

**Complete answer:**  
- Setup: Required = 80 + 420 + 90 + 30 = 620 ps → Slack = 700 - 620 = 80 ps  
- Hold: Min path = 25 + 65 = 90 ps ≥ 50 + 30 → satisfied, margin = 10 ps  

---

### Q16: Skew Impact
**Question:** How does skew affect setup and hold?  

**Your answer:**  
> Positive skew helps setup; negative skew helps hold  

**Complete answer:**  
- Positive skew +20 ps → setup slack = 90 ps, hold satisfied  
- Negative skew -20 ps → setup slack = 50 ps, hold satisfied  

---

### Q17: Setup Calculation Formula
**Question:** Write setup slack formula using industrial convention  

**Your answer:**  
> Slack = T_clk + T_skew - T_setup - (T_CQ + D_max)  

**Complete answer:**  
\[
\text{Setup Slack} = T_{clk} + T_{skew} - T_{setup} - (T_{CQ(max)} + D_{max})
\]  

---

### Q18: Multi-Cycle Path
**Question:** How to handle data paths longer than one clock?  

**Your answer:**  
> Wait several clocks; specify multi-cycle constraint  

**Complete answer:**  
- STA computes required arrival = N*T_clk - T_setup  
- Slack = required - actual arrival  

---

### Q19: Placement / Routing Blockage
**Question:** Define hard and soft blockage  

**Your answer:**  
> Hard = forbids completely, soft = partially allows  

**Complete answer:**  
- Hard: no placement/routing allowed  
- Soft: limits placement density or allows fraction of placement  

---

### Q20: Keepout vs Blockage
**Question:** Difference between keepout and blockage  

**Your answer:**  
> Keepout moves with macro; blockage independent  

**Complete answer:**  
- Keepout: prevents placement around macro, moves with it, typical margin 0.5 μm  
- Blockage: fixed location, prevents routing  

---

### Q21: Power / Ground Pins
**Question:** What are VDD, VSS, data, and clock pins?  

**Your answer:**  
> VDD powers cells; VSS ground; data transfers info; clock synchronizes  

**Complete answer:**  
- VDD: supply voltage  
- VSS: ground  
- Data: logical signal between cells  
- Clock: synchronizes FFs  

---

### Q22: Congestion Mitigation
**Question:** How to reduce routing congestion?  

**Your answer:**  
> Define blockage area, limit density, join macros, layer promotion  

**Complete answer:**  
- Methods: define blockages, limit density, group macros, split HFNs, layer promotion  
- Objective: avoid routing hotspots, meet timing  

---

## Clock Tree Synthesis & Timing – Questions 23 à 25

### Q23: CTS / Clock Trees
**Question:** Define CTS, H-tree, and objectives  

**Your answer:**  
> Clock tree spreads clock efficiently, limits latency and skew  

**Complete answer:**  
- H-tree or A-tree distributes clock across core  
- Buffers inserted to reduce skew and latency  
- Objective: minimal skew, uniform clock, low voltage drop  

---

### Q24: Clock Latency
**Question:** Difference between source latency and network latency  

**Your answer:**  
> Source: input to launch FF, Network: route/cells/buffers  

**Complete answer:**  
- Source latency: delay from clock source to launching FF  
- Network latency: routing and buffers along the tree  

---

### Q25: MMMC Corners
**Question:** Why use Multi-Mode Multi-Corner (MMMC) STA?  

**Your answer:**  
> Tests STA under different process/voltage/temp; worst-case 0.9 V, 125°C  

**Complete answer:**  
- Setup: slow process, low V, high T  
- Hold: fast process, high V, low T  
- STA ensures timing is met in all modes and corners  

---

## Power, EM, and Signal Integrity – Questions 26 à 28

### Q26: Electromigration Numeric
**Question:** Compute if trace is safe: w = 0.6 μm, t = 0.4 μm, I = 2.5 mA, allowed 1 mA/μm²  

**Your answer:**  
> Not violation EM limits  

**Assessment:** Incorrect; must compute density  

**Complete answer:**  
- Area = 0.6*0.4 = 0.24 μm²  
- Current density = 2.5 / 0.24 ≈ 10.4 mA/μm² → violation  
- Fix: widen trace, parallel tracks, higher metal layer  

---

### Q27: Cell Sizing / Buffers Numeric
**Question:** Timing fix: T_CQ=50, D=300, T_setup=80, T_clk=420, T_skew=0. Upsize reduces D by 8 ps; buffer pair reduces 15 ps D, adds 5 ps delay  

**Your answer:** Conceptual only  

**Complete answer:**  
- Arrival = 350, required = 340 → slack = -10 ps  
- One buffer pair: reduces D → slack = 0 → timing met  
- Two upsizes: slack = +6 ps → minimal fix = one buffer pair  

---

### Q28: Signal Integrity / Crosstalk Numeric
**Question:** Compute ΔV for victim: Cc=10 fF, Cv=50 fF, VDD=1 V  

**Your answer:** Not answered  

**Complete answer:**  
\[
\Delta V = V_{DD} \cdot \frac{C_c}{C_c + C_v} = 1 \cdot \frac{10}{60} \approx 0.167 \text{ V}
\]  
- Mitigation: spacing, shielding, routing layers, buffers  

---

