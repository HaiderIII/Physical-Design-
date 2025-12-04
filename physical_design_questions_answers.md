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
Core utilization is the fraction of the design core area that is occupied by standard cells, macros, or blockages relative to the total core area. It is a key metric in floorplanning and placement because it affects routability, congestion, and PPA (Performance, Power, Area).

The formula is:

$$
\text{Core Utilization (\%)} = \frac{\text{Occupied Core Area}}{\text{Total Core Area}} \times 100
$$

- High utilization (>80%) can create routing congestion and timing violations.  
- Low utilization (<60%) underuses silicon, wasting area.

---

### Q2: Explain the role of LEF, DEF, and SDC files in physical design.

**Answer:**  
- **LEF (Library Exchange Format):** Contains geometric and electrical data for standard cells, macros, pin locations, metal layers, routing directions, and design rules. Used by PnR tools for placement and routing.  
- **DEF (Design Exchange Format):** Contains the placed and routed design, including cell positions, orientations, nets, pins, and routing paths. Output of PnR for verification or downstream tools.  
- **SDC (Synopsys Design Constraints):** Contains timing constraints such as clocks, input/output delays, false paths, multi-cycle paths, and exceptions. Used by STA tools to compute setup and hold slacks.

---

### Q3: What is clock skew and its impact on setup and hold timing?

**Answer:**  
Clock skew is the difference in arrival times of the clock signal at different flip-flops.  
- **Local skew:** Difference between two flip-flops in a path.  
- **Global skew:** Difference between earliest and latest clock arrival in the design.  

Impact:  
- Positive skew (clock arrives later at capture FF) improves setup margin but may hurt hold.  
- Negative skew (clock arrives earlier at capture FF) improves hold margin but may hurt setup.

---

### Q4: Explain setup and hold timing constraints with formulas.

**Answer:**  

- **Setup timing:** Data must be stable at the capture flip-flop before the clock edge.  

$$
T_\text{clk} \ge T_\text{CQ(max)} + D_\text{max} + T_\text{setup} + T_\text{skew}
$$

- **Hold timing:** Data must remain stable at the capture flip-flop after the clock edge.  

$$
T_\text{CQ(min)} + D_\text{min} \ge T_\text{hold} + T_\text{skew}
$$

Where:  
- \(T_\text{CQ}\) = clock-to-Q delay of the launch FF  
- \(D\) = combinational path delay  
- \(T_\text{setup}\), \(T_\text{hold}\) = timing requirements  
- \(T_\text{skew}\) = clock skew

---

### Q5: How can setup and hold violations be fixed?

**Answer:**  
- **Setup violation (data arrives too late):**  
  - Insert positive skew  
  - Upsize slow cells  
  - Add buffers to reduce critical path delay  
  - Retiming or path restructuring  
- **Hold violation (data changes too early):**  
  - Insert negative skew  
  - Downsize cells to increase path delay  
  - Add buffers to slow fast paths

---

### Q6: What is a false path in STA and why is it ignored?

**Answer:**  
- A **false path** is a logic path that never activates during normal operation (e.g., an unused branch of a multiplexer).  
- Ignoring false paths avoids overly pessimistic timing and unnecessary fixes.

---

### Q7: What are placement and routing blockages?

**Answer:**  
- **Placement blockage:** Area where cells or macros cannot be placed. Can be hard (completely forbidden) or soft (density-limited).  
- **Routing blockage:** Area where routing of metal layers is restricted or forbidden.  
- Proper blockages avoid congestion and help timing closure.

---

### Q8: What is a keepout vs a blockage?

**Answer:**  
- **Keepout:** Surrounds a macro to prevent placement nearby; moves with the macro. Typical margin ~0.5 μm.  
- **Blockage:** Fixed, independent of macros; prevents routing or placement in specific areas.

---

### Q9: How do you mitigate congestion in floorplanning?

**Answer:**  
- Limit placement density  
- Group macros in hierarchy  
- Promote higher metal layers for critical routes  
- Split high-fanout nets  
- Use strategic soft/hard blockages  

---

## Clock Tree Synthesis (CTS) & Timing

### Q10: What is CTS and why is it needed?

**Answer:**  
- **CTS (Clock Tree Synthesis):** Distributes the clock signal uniformly across the core.  
- Uses H-tree or A-tree structures with buffers to reduce skew and insertion delay.  
- Objective: uniform clock arrival, minimal skew, minimal voltage drop.

---

### Q11: What are source and network latency in CTS?

**Answer:**  
- **Source latency:** Delay from clock source to launching flip-flop.  
- **Network latency:** Delay along clock routing, buffers, and cells.  
- Total clock latency = source latency + network latency.

---

### Q12: Why is Multi-Mode Multi-Corner (MMMC) STA important?

**Answer:**  
- Tests timing under different operating conditions and PVT corners (process, voltage, temperature).  
- Ensures setup and hold are met for worst-case and best-case scenarios.  
- Example: Worst-case voltage 0.9 V at 125°C; slow process for setup, fast process for hold.

---

## Static Timing Analysis (STA)

### Q13: Compute setup and hold slack for a data path

**Given:**  
- \(T_\text{CQ(max)} = 80\,\text{ps}, D_\text{max} = 420\,\text{ps}, T_\text{setup} = 90\,\text{ps}, T_\text{clk} = 700\,\text{ps}, T_\text{skew} = 30\,\text{ps}\)  
- \(T_\text{CQ(min)} = 25\,\text{ps}, D_\text{min} = 65\,\text{ps}, T_\text{hold} = 50\,\text{ps}\)

**Answer:**  
- Setup required period: \(80 + 420 + 90 + 30 = 620\,\text{ps}\)  
- Slack: \(T_\text{clk} - T_\text{clk,min} = 700 - 620 = 80\,\text{ps}\) → setup met  
- Hold margin: \(25 + 65 = 90 ≥ 50 + 30 = 80\,\text{ps}\) → margin = 10 ps → hold met  

---

### Q14: Skew impact example

**Answer:**  
- Positive skew (+20 ps): setup slack increases, hold satisfied  
- Negative skew (-20 ps): setup slack decreases, hold still satisfied  

---

### Q15: Multi-cycle path handling

**Answer:**  
- Required arrival for N-cycle path:  
$$
T_\text{required} = N \cdot T_\text{clk} - T_\text{setup}
$$  
- STA calculates slack accordingly.

---

### Q16: Setup and hold numeric example

**Answer:**  
- Setup slack = -40 ps → path needs adjustment (buffers or upsizing)  
- Hold slack = 170 ps → safe

---

### Q17: Setup and hold formulas

**Answer:**  
- Setup slack:  
$$
\text{Slack} = T_\text{clk} + T_\text{skew} - T_\text{setup} - (T_\text{CQ(max)} + D_\text{max})
$$  
- Hold margin:  
$$
\text{Margin} = T_\text{CQ(min)} + D_\text{min} - (T_\text{hold} + T_\text{skew})
$$

---

## Power, IR Drop & Electromigration

### Q18: Explain power grid and IR drop

**Answer:**  
- Distributes VDD/VSS through horizontal/vertical metal layers connected with vias.  
- **IR drop:** Voltage drop due to resistance and current in the metal. Affects timing.  
- Mitigation: Use wider metal layers, shield critical nets, dedicated power routes.

---

### Q19: Electromigration (EM) example

**Given:** w=0.6 μm, t=0.4 μm, I=2.5 mA, allowed 1 mA/μm²  

**Answer:**  
- Area = 0.6 × 0.4 = 0.24 μm²  
- Current density = 2.5 / 0.24 ≈ 10.4 mA/μm² → exceeds limit  
- Fix: widen trace, parallel wires, use higher metal layers

---

## Cell Sizing, Buffers & ECO

### Q20: Cell upsizing, buffers, spare cells, tie cells

**Answer:**  
- Upsizing: Reduce delay for setup paths  
- Downsizing: Increase delay for hold paths  
- Buffers: Adjust timing along paths  
- Spare cells: Reserve for ECO without redesign  
- Tie cells: Connect to VDD/VSS for density, no logical function

---

### Q21: ECO definition

**Answer:**  
- Engineering Change Order  
- Post-PnR fix of timing or functional issues  
- Types: RTL-level, gate-level, metal-only

---

## Signal Integrity & Crosstalk

### Q22: Crosstalk numeric example

**Given:** Cc = 10 fF, Cv = 50 fF, VDD = 1 V  

**Answer:**  
$$
\Delta V = VDD \cdot \frac{C_c}{C_c + C_v} = 1 \cdot \frac{10}{60} \approx 0.167 \, \text{V}
$$  

- Mitigation: spacing, shielding, routing layers, buffers

---
