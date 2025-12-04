# Junior Physical Design Interview Q&A – Complete Reference

Comprehensive Q&A for **junior-level physical design interviews**, covering floorplanning, placement, CTS, STA, power, EM, signal integrity, and ECO. Includes numeric examples, formulas, and full explanations. All formulas are MathJax-compatible.

---

## Table of Contents

1. [Floorplanning & Placement](#floorplanning--placement)
2. [Clock Tree Synthesis & Timing](#clock-tree-synthesis--timing)
3. [Static Timing Analysis (STA)](#static-timing-analysis-sta)
4. [Power, IR Drop & Electromigration](#power-ir-drop--electromigration)
5. [Cell Sizing, Buffers & ECO](#cell-sizing-buffers--eco)
6. [Signal Integrity & Crosstalk](#signal-integrity--crosstalk)

---

## Floorplanning & Placement

### Q1: What is Core Utilization and how is it calculated?

**Answer:**  
Core utilization is the fraction of the design core area occupied by standard cells, macros, or blockages.  

Formula:  

$$
\text{Core Utilization (\%)} = \frac{\text{Occupied Core Area}}{\text{Total Core Area}} \times 100
$$

- **High utilization (>80%)** → potential routing congestion, timing violations.  
- **Low utilization (<60%)** → wasted silicon area.  

**Example:**  
Occupied area = 0.48 mm², total core area = 0.6 mm²  

$$
\text{Core Utilization} = \frac{0.48}{0.6} \times 100 = 80\%
$$

---

### Q2: Explain LEF, DEF, and SDC files.

**Answer:**  

- **LEF (Library Exchange Format):** Provides geometry, pins, metal layers, routing directions, design rules. Used for placement/routing.  
- **DEF (Design Exchange Format):** Describes placed and routed design: cell positions, orientations, nets, routing. Output of PnR.  
- **SDC (Synopsys Design Constraints):** Timing constraints (clocks, input/output delays, false paths, multi-cycle paths). Input for STA.

---

### Q3: Clock skew and its effect on timing

**Answer:**  
- **Clock skew:** difference between arrival times at FFs.  
- **Local skew:** between two FFs of the same path.  
- **Global skew:** difference between earliest and latest FFs.  

**Effect:**  
- Positive skew at capture FF → improves setup, may hurt hold  
- Negative skew at capture FF → improves hold, may hurt setup

---

### Q4: Setup and Hold Timing Equations

- **Setup:** Data must be stable before clock edge  

$$
T_\text{clk} \ge T_\text{CQ(max)} + D_\text{max} + T_\text{setup} + T_\text{skew}
$$

- **Hold:** Data must be stable after clock edge  

$$
T_\text{CQ(min)} + D_\text{min} \ge T_\text{hold} + T_\text{skew}
$$

---

### Q5: Fixing Setup/Hold Violations

- **Setup violation:** insert positive skew, upsize slow cells, add buffers, retime paths.  
- **Hold violation:** insert negative skew, downsize cells, add buffers to slow paths.

---

### Q6: What is a false path?

- Path that is never activated logically (e.g., unused MUX branch).  
- Ignored in STA to avoid over-constraining the design.

---

### Q7: Placement & Routing Blockages

- **Placement blockage:** area where cells/macros cannot be placed. Hard (forbidden) or soft (density limit).  
- **Routing blockage:** area restricted for routing.  

---

### Q8: Keepout vs Blockage

- **Keepout:** surrounds macro, moves with it. Typical margin ~0.5 μm.  
- **Blockage:** fixed, independent of macros.  

---

### Q9: Mitigating Congestion

- Limit density, group macros, promote higher metal layers, split high-fanout nets, use blockages strategically.

---

## Clock Tree Synthesis & Timing

### Q10: What is CTS and why is it needed?

- **CTS:** Clock Tree Synthesis distributes clock using H-tree/A-tree with buffers.  
- Goal: uniform clock arrival, minimal skew, preserve timing integrity.

---

### Q11: Source vs Network Latency

- **Source latency:** delay from clock source to launch FF.  
- **Network latency:** delay along tree including buffers and wires.  
- Total latency = source + network.

---

### Q12: Multi-Mode Multi-Corner (MMMC) STA

- Checks timing across PVT corners (Process, Voltage, Temperature).  
- Ensures setup/hold satisfied in worst-case and best-case scenarios.

---

## Static Timing Analysis (STA)

### Q13: Compute Setup & Hold Slack

**Given:**  
- $T_\text{CQ(max)} = 80~\text{ps}$, $D_\text{max} = 420~\text{ps}$, $T_\text{setup} = 90~\text{ps}$, $T_\text{clk} = 700~\text{ps}$, $T_\text{skew} = 30~\text{ps}$  
- $T_\text{CQ(min)} = 25~\text{ps}$, $D_\text{min} = 65~\text{ps}$, $T_\text{hold} = 50~\text{ps}$

**Answer:**  

- Setup required period:  

$$
T_\text{clk,min} = T_\text{CQ(max)} + D_\text{max} + T_\text{setup} + T_\text{skew} = 80 + 420 + 90 + 30 = 620~\text{ps}
$$

- Setup slack:  

$$
\text{Slack} = T_\text{clk} - T_\text{clk,min} = 700 - 620 = 80~\text{ps}
$$

- Hold margin:  

$$
T_\text{CQ(min)} + D_\text{min} = 25 + 65 = 90~\text{ps} \ge T_\text{hold} + T_\text{skew} = 50 + 30 = 80~\text{ps}
$$

→ Margin = 10 ps → hold satisfied.

---

### Q14: Skew Impact Example

- Positive skew (+20 ps): increases setup slack, hold still satisfied  
- Negative skew (-20 ps): decreases setup slack, hold still satisfied

---

### Q15: Multi-Cycle Path Handling

$$
T_\text{required} = N \cdot T_\text{clk} - T_\text{setup}
$$

STA calculates slack according to multi-cycle path.

---

### Q16: Setup & Hold Slack Example

- Setup slack = -40 ps → path requires optimization  
- Hold slack = 170 ps → safe

---

### Q17: General STA Formulas

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

### Q18: Power Grid & IR Drop

- Distributes VDD/VSS through metal layers  
- **IR drop:** voltage drop along power wires due to resistance/current  
- Mitigation: wider metals, shields, dedicated routing

---

### Q19: Electromigration Example

- Width = 0.6 μm, thickness = 0.4 μm, I = 2.5 mA, allowed current density = 1 mA/μm²  
- Area = 0.6 × 0.4 = 0.24 μm² → Current density = 2.5 / 0.24 ≈ 10.4 mA/μm² → exceeds limit  
- Fix: widen trace, parallel wires, higher metal layers

---

## Cell Sizing, Buffers & ECO

### Q20: Techniques to Fix Timing

- Upsize/downsize cells, buffer insertion, spare cells, tie cells to VDD/VSS

---

### Q21: ECO Definition

- Engineering Change Order  
- Post-PnR fixes: RTL-level, gate-level, or metal-only

---

## Signal Integrity & Crosstalk

### Q22: Crosstalk Example

- $C_c = 10~\text{fF}$, $C_v = 50~\text{fF}$, $V_\text{DD} = 1~\text{V}$  

$$
\Delta V = V_\text{DD} \cdot \frac{C_c}{C_c + C_v} = 1 \cdot \frac{10}{60} \approx 0.167~\text{V}
$$  

- Mitigation: spacing, shielding, routing layers, buffers

---

### Q23: Placement Blockages & Keepouts

- Keepout moves with macro, blockage fixed  
- Prevent routing/placement conflicts

---

### Q24: Floorplanning for PPA

- Respect Performance, Power, Area  
- Consider congestion, timing, density

---

### Q25: CTS with Buffers

- H-tree/A-tree with buffers  
- Minimize skew, preserve signal integrity

---

### Q26: Network Latency

- Clock delay along routing and buffers  
- Total latency = source + network

---

### Q27: MMC Corners in STA

- Worst-case: slow process + low voltage + high temperature  
- Best-case: fast process + high voltage + low temperature

---

### Q28: ECO Example

- Adding buffers or metal-only routing to fix timing post-PnR  
- Avoids full redesign
