# Junior Physical Design Interview Q&A

Comprehensive reference for **junior-level physical design interviews**, covering all major steps of Physical Design, with answers and numeric examples.

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
**Answer:**  
\[
\text{Core Utilization} = \frac{\text{Occupied Area}}{\text{Total Core Area}} \times 100\%
\]  
Fraction of area occupied by standard cells, macros, or blockages.  

---

### Q2: LEF, DEF, SDC
**Answer:**  
- **LEF (Library Exchange Format):** Cell dimensions, pins, routing layers, geometric info  
- **DEF (Design Exchange Format):** Placement/routing output from PnR  
- **SDC (Synopsys Design Constraints):** Timing constraints, clocks, exceptions  

---

### Q19: Placement / Routing Blockage
**Answer:**  
- **Hard blockage:** forbids placement or routing completely  
- **Soft blockage:** partially allows placement/routing, e.g., fraction of density  

---

### Q20: Keepout vs Blockage
**Answer:**  
- **Keepout:** Prevents placement near a macro, moves with macro, typical margin 0.5 μm  
- **Blockage:** Fixed, prevents routing independently of macro  

---

### Q21: Power / Ground Pins
**Answer:**  
- **VDD:** Supply voltage  
- **VSS:** Ground  
- **Data:** Logical signal  
- **Clock:** Synchronizes FFs  

---

### Q22: Congestion Mitigation
**Answer:**  
- Define blockage area  
- Limit density  
- Group macros together  
- Split HFNs (high-fanout nets)  
- Layer promotion  
Objective: avoid routing congestion, meet timing, preserve PPA (Performance, Power, Area)  

---

## Clock Tree Synthesis (CTS) & Timing

### Q3: Clock Skew
**Answer:**  
- Difference in clock arrival at FFs  
- **Positive skew:** helps setup, may hurt hold  
- **Negative skew:** helps hold, may hurt setup  

---

### Q4: Setup & Hold Inequalities
**Answer:**  
\[
\text{Setup: } T_{clk} \ge T_{CQ(max)} + D_{max} + T_{setup} + T_{skew}
\]  
\[
\text{Hold: } T_{CQ(min)} + D_{min} \ge T_{hold} + T_{skew}
\]  

---

### Q5: Setup vs Hold
**Answer:**  
- **Setup violation:** Data arrives too late  
- **Hold violation:** Data changes too early  
**Fix:** Adjust skew, upsize/downsize cells, buffer insertion  

---

### Q23: CTS / Clock Trees
**Answer:**  
- H-tree or A-tree distributes clock across the core  
- Buffers injected to reduce skew and latency  
- Objective: uniform clock arrival, minimal skew, minimal voltage drop  

---

### Q24: Clock Latency
**Answer:**  
- **Source latency:** Delay from clock source to launching FF  
- **Network latency:** Delay along routing, buffers, cells  

---

### Q25: MMMC Corners
**Answer:**  
- **Purpose:** Test STA across different modes (timing modes) and corners (process/voltage/temp)  
- **Example:** Worst-case voltage 0.9 V, 125°C  
- **Setup:** slow process, low V, high T  
- **Hold:** fast process, high V, low T  

---

## Static Timing Analysis (STA)

### Q15: STA Slack Computation
**Given:**  
T_CQ(max)=80 ps, D_max=420 ps, T_setup=90 ps, T_clk=700 ps, T_skew=30 ps  
T_CQ(min)=25 ps, D_min=65 ps, T_hold=50 ps  

**Answer:**  
- **Setup required period:** 80+420+90+30 = 620 ps → Slack = 700-620 = 80 ps  
- **Hold margin:** 25+65 = 90 ≥ 50+30 → margin = 10 ps  

---

### Q16: Skew Impact
**Answer:**  
- +20 ps skew: setup slack = 90 ps, hold satisfied  
- -20 ps skew: setup slack = 50 ps, hold satisfied  

---

### Q17: Setup Calculation Formula
**Answer:**  
\[
\text{Setup Slack} = T_{clk} + T_{skew} - T_{setup} - (T_{CQ(max)} + D_{max})
\]  

---

### Q18: Multi-Cycle Path
**Answer:**  
- Required arrival = N*T_clk - T_setup  
- Used when combinational path is longer than one clock period  

---

### Q6: False Path
**Answer:**  
- Path that never activates in real operation  
- Ignored in STA to avoid unnecessary timing pessimism  

---

### Q14: Signal Integrity / Crosstalk
**Answer:**  
- Crosstalk voltage: \(\Delta V = V_{DD} \cdot \frac{C_c}{C_c + C_v}\)  
- Mitigation: spacing, shielding, routing layers, buffers  

---

## Cell Sizing, Buffers & ECO

### Q12: Cell Upsizing / Buffer / Spare Cells
**Answer:**  
- **Upsizing / Downsizing:** Adjust transistor width to meet timing  
- **Buffer insertion:** Improve signal propagation, meet setup/hold  
- **Spare cells:** Reserve for ECO/fixes without restarting flow  
- **Tie cells:** Tie to VDD/VSS for power/density, no logical function  

---

### Q13: ECO
**Answer:**  
- Engineering Change Order  
- Post-PnR modification of design  
- Types: RTL-level, gate-level, metal-only  

### Q26: Electromigration Numeric
**Given:** w=0.6 μm, t=0.4 μm, I=2.5 mA, allowed 1 mA/μm²  
**Answer:**  
- Area = 0.6*0.4=0.24 μm²  
- Current density = 2.5/0.24 ≈ 10.4 mA/μm² → exceeds limit → violation  
- Fix: widen trace, parallel tracks, higher metal layer  

### Q27: Cell Sizing / Buffers Numeric
**Given:** T_CQ=50, D=300, T_setup=80, T_clk=420, T_skew=0; buffer reduces 15 ps, adds 5 ps delay  
**Answer:**  
- Arrival = 350, required = 340 → slack = -10 ps  
- One buffer pair → slack = 0 → timing met  

### Q28: Signal Integrity / Crosstalk Numeric
**Given:** Cc=10 fF, Cv=50 fF, VDD=1 V  
**Answer:**  
\(\Delta V = VDD \cdot \frac{C_c}{C_c + C_v} = 1 * 10/60 ≈ 0.167 V\)  
- Mitigation: spacing, shielding, routing layers, buffers  

---
