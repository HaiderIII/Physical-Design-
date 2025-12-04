# Junior Physical Design Interview Q&A

Comprehensive reference for **junior-level physical design interviews**, covering all major steps of Physical Design, with detailed explanations, numeric examples, and complete answers. Formulas are in LaTeX compatible with MathJax.

---

## Table of Contents

- [Floorplanning & Placement](#floorplanning--placement)
- [Clock Tree Synthesis (CTS) & Timing](#clock-tree-synthesis-cts--timing)
- [Static Timing Analysis (STA)](#static-timing-analysis-sta)
- [Power, IR Drop & Electromigration](#power-ir-drop--electromigration)
- [Cell Sizing, Buffers & ECO](#cell-sizing-buffers--eco)
- [Signal Integrity & Crosstalk](#signal-integrity--crosstalk)

---

## Floorplanning & Placement

### Q1: What is Core Utilization and how is it calculated?

**Answer:**  
Core utilization is the fraction of the design core area that is occupied by standard cells, macros, or blockages relative to the total core area. It affects routability, congestion, and PPA (Performance, Power, Area).

Formula:

$$
\text{Core Utilization (\%)} = \frac{\text{Occupied Core Area}}{\text{Total Core Area}} \times 100
$$

- High utilization (>80%) may create congestion and timing violations.  
- Low utilization (<60%) underuses silicon.

---

### Q2: Explain LEF, DEF, and SDC files.

**Answer:**  

- **LEF (Library Exchange Format):** Contains geometric/electrical info for cells, macros, pins, metal layers, routing directions, and design rules.  
- **DEF (Design Exchange Format):** Contains placed/routed design: cell positions, orientations, nets, pins, routes. Output from PnR.  
- **SDC (Synopsys Design Constraints):** Contains clocks, input/output delays, false/multi-cycle paths, exceptions for STA.

---

### Q3: Clock skew and impact

**Answer:**  
Clock skew = difference in arrival times at flip-flops.  

- **Local skew:** Between two FFs on same path  
- **Global skew:** Between earliest and latest FFs  

Impact:  
- Positive skew (clock arrives late at capture FF): improves setup, may hurt hold  
- Negative skew (clock arrives early): improves hold, may hurt setup

---

### Q4: Setup and hold timing constraints

**Answer:**  

- **Setup:** Data stable before clock edge  

$$
T_\text{clk} \ge T_\text{CQ(max)} + D_\text{max} + T_\text{setup} - T_\text{skew}
$$

- **Hold:** Data stable after clock edge  

$$
T_\text{CQ(min)} + D_\text{min} \ge T_\text{hold} + T_\text{skew}
$$

Where \(T_\text{CQ}\) = clock-to-Q, \(D\) = combinational delay

---

### Q5: Fixing setup/hold violations

**Answer:**  

- **Setup violation:** positive skew, upsize cells, buffer, retiming  
- **Hold violation:** negative skew, downsize cells, buffer

---

### Q6: False path

**Answer:**  
A path that never activates (e.g., unused MUX branch). Ignored in STA.

---

### Q7: Placement and routing blockages

**Answer:**  

- Placement blockage: area where cells/macros cannot be placed (hard/soft)  
- Routing blockage: area restricted for routing  
- Prevent congestion and help timing closure

---

### Q8: Keepout vs blockage

**Answer:**  

- Keepout: surrounds macro, moves with it (~0.5 μm margin)  
- Blockage: fixed, independent of macros

---

### Q9: Mitigating congestion

**Answer:**  

- Limit density  
- Group macros  
- Promote higher metal layers  
- Split high-fanout nets  
- Use blockages strategically

---

## Clock Tree Synthesis (CTS) & Timing

### Q10: CTS definition

**Answer:**  
CTS distributes clock uniformly using H-tree or A-tree, minimizing skew and insertion delay.

---

### Q11: Source & network latency

**Answer:**  
- Source latency: from clock source to launching FF  
- Network latency: delay along clock tree  
- Total = source + network latency

---

### Q12: Multi-mode multi-corner (MMMC)

**Answer:**  
- STA tested across PVT corners ensures setup/hold for worst/best-case  
- Example: 0.9 V at 125°C

---

## Static Timing Analysis (STA)

### Q13: Compute setup and hold slack

**Given:**  
- $T_\text{CQ(max)} = 80~\text{ps}$, $D_\text{max} = 420~\text{ps}$, $T_\text{setup} = 90~\text{ps}$, $T_\text{clk} = 700~\text{ps}$, $T_\text{skew} = 30~\text{ps}$  
- $T_\text{CQ(min)} = 25~\text{ps}$, $D_\text{min} = 65~\text{ps}$, $T_\text{hold} = 50~\text{ps}$

**Answer:**  

- Setup period:  
$$
T_\text{clk,min} = T_\text{CQ(max)} + D_\text{max} + T_\text{setup} + T_\text{skew} = 80 + 420 + 90 + 30 = 620~\text{ps}
$$

- Slack:  
$$
\text{Slack} = T_\text{clk} - T_\text{clk,min} = 700 - 620 = 80~\text{ps} \quad (\text{setup met})
$$

- Hold margin:  
$$
T_\text{CQ(min)} + D_\text{min} = 25 + 65 = 90~\text{ps} \ge T_\text{hold} + T_\text{skew} = 50 + 30 = 80~\text{ps}
$$
→ Margin = 10 ps (hold met)

---

### Q14: Skew impact example

**Answer:**  

- Positive skew (+20 ps): setup slack increases, hold satisfied  
- Negative skew (-20 ps): setup slack decreases, hold still satisfied

---

### Q15: Multi-cycle path

**Answer:**  

$$
T_\text{required} = N \cdot T_\text{clk} - T_\text{setup}
$$  

Slack calculated according to multi-cycle specification.

---

### Q16: Setup and hold numeric example

- Setup slack = -40 ps → path needs adjustment  
- Hold slack = 170 ps → safe

---

### Q17: Setup and hold formulas

- Setup slack:  
$$
\text{Slack}_\text{setup} = T_\text{clk} + T_\text{skew} - T_\text{setup} - (T_\text{CQ(max)} + D_\text{max})
$$

- Hold margin:  
$$
\text{Margin}_\text{hold} = T_\text{CQ(min)} + D_\text{min} - (T_\text{hold} + T_\text{skew})
$$

---

## Power, IR Drop & Electromigration

### Q18: Power grid and IR drop

- Distributes VDD/VSS via metal layers  
- IR drop = voltage loss along power nets  
- Mitigation: wider metals, shields, dedicated routing

---

### Q19: Electromigration (EM)

- EM constraint: current density limit  
- Example: w=0.6 μm, t=0.4 μm, I=2.5 mA, allowed 1 mA/μm²  
- Area = 0.6 × 0.4 = 0.24 μm² → Current density = 2.5 / 0.24 ≈ 10.4 mA/μm² → exceeds limit  
- Fix: widen trace, parallel wires, higher metal layers

---

## Cell Sizing, Buffers & ECO

### Q20: Techniques to fix timing

- Upsize/downsize cells to adjust delays  
- Buffer insertion to delay/drive paths  
- Spare cells for post-PnR ECO  
- Tie cells to VDD/VSS for density

---

### Q21: ECO definition

- Engineering Change Order  
- Post-PnR fix of timing or functional issues  
- Types: RTL-level, gate-level, metal-only

---

## Signal Integrity & Crosstalk

### Q22: Crosstalk numeric example

- $C_c = 10~\text{fF}$, $C_v = 50~\text{fF}$, $V_\text{DD} = 1~\text{V}$  

$$
\Delta V = V_\text{DD} \cdot \frac{C_c}{C_c + C_v} = 1 \cdot \frac{10}{60} \approx 0.167~\text{V}
$$  

- Mitigation: spacing, shielding, routing layers, buffers

---

### Q23: Placement blockages and keepouts

- Keepout moves with macro, blockage fixed  
- Prevent routing/placement conflicts

---

### Q24: Floorplanning for PPA

- Respect Performance, Power, Area  
- Consider congestion, timing, density

---

### Q25: CTS with buffers

- H-tree/A-tree with buffers  
- Minimizes skew, preserves signal integrity

---

### Q26: Network latency

- Clock delay along routing and buffers  
- Source latency + network latency = total

---

### Q27: MMC corners in STA

- Worst-case: slow process + low voltage + high temperature  
- Best-case: fast process + high voltage + low temperature

---

### Q28: ECO example

- Adding buffer to fix timing post-PnR  
- Metal-only changes to adjust critical path delay

---
