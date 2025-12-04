# Junior Physical Design Interview Q&A

Comprehensive reference for **junior-level physical design interviews**, covering all major steps of Physical Design, with detailed explanations, numeric examples, and complete answers. This includes floorplanning, placement, clock tree synthesis, STA, power, EM, cell sizing, and signal integrity.

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
\[
\text{Core Utilization (\%)} = \frac{\text{Occupied Core Area}}{\text{Total Core Area}} \times 100
\]  
- A high utilization (>80%) can create routing congestion and timing violations.  
- A low utilization (<60%) underuses silicon, wasting area.  

---

### Q2: Explain the role of LEF, DEF, and SDC files in physical design.
**Answer:**  
- **LEF (Library Exchange Format):** Contains geometric and electrical data for standard cells, macros, pin locations, metal layers, routing directions, and design rules. Used by PnR tools to perform placement and routing.  
- **DEF (Design Exchange Format):** Contains the placed and routed design, including cell positions, orientations, nets, pins, and routing paths. It is the output of PnR that can be used for verification or downstream tools.  
- **SDC (Synopsys Design Constraints):** Contains timing constraints such as clocks, input/output delays, false paths, multi-cycle paths, and exceptions. Used by STA tools to compute setup and hold slacks.  

---

### Q3: What is clock skew and its impact on setup and hold timing?
**Answer:**  
Clock skew is the difference in arrival times of the clock signal at different flip-flops in the design.  
- **Local skew:** Difference between two flip-flops connected in a path.  
- **Global skew:** Difference between the earliest and latest clock arrival in the entire design.  
**Impact:**  
- Positive skew (clock arrives later at capture FF): improves setup margin but can hurt hold.  
- Negative skew (clock arrives earlier at capture FF): improves hold margin but can hurt setup.  

---

### Q4: Explain setup and hold timing constraints with formulas.
**Answer:**  
- **Setup timing:** Data must be stable at the capture flip-flop before the clock edge.  
\[
T_{clk} \ge T_{CQ(max)} + D_{max} + T_{setup} + T_{skew}
\]  
- **Hold timing:** Data must remain stable at the capture flip-flop after the clock edge.  
\[
T_{CQ(min)} + D_{min} \ge T_{hold} + T_{skew}
\]  
Where:  
- \(T_{CQ}\) = clock-to-Q delay of the launch FF  
- \(D\) = combinational path delay  
- \(T_{setup}\), \(T_{hold}\) = timing requirements  
- \(T_{skew}\) = clock skew  

---

### Q5: How can setup and hold violations be fixed?
**Answer:**  
- **Setup violation (data arrives too late):**  
  - Insert positive skew  
  - Upsize the slowest cell in the path  
  - Add buffers to shorten critical path delays  
  - Slack the combinational path using retiming or path restructuring  
- **Hold violation (data changes too early):**  
  - Insert negative skew  
  - Downsize cells to increase path delay  
  - Add buffers to slow down fast paths  

---

### Q6: What is a false path in STA and why is it ignored?
**Answer:**  
- A **false path** is a logic path that cannot be activated during normal operation, e.g., a branch in a multiplexer that is never selected.  
- Ignoring false paths prevents overly pessimistic timing analysis and avoids unnecessary timing fixes.  

---

### Q7: What are placement and routing blockages?
**Answer:**  
- **Placement blockage:** Area where cells or macros cannot be placed. Can be hard (completely forbidden) or soft (density-limited).  
- **Routing blockage:** Area where routing of metal layers is restricted or forbidden.  
- Proper use of blockages avoids congestion and allows timing closure.  

---

### Q8: What is a keepout vs a blockage?
**Answer:**  
- **Keepout:** Surrounds a macro to prevent placement nearby; moves with the macro during ECO or optimization. Typical margin ~0.5 μm.  
- **Blockage:** Fixed location independent of macros; used to prevent routing in congested areas.  

---

### Q9: How do you mitigate congestion in floorplanning?
**Answer:**  
- Limit placement density in high-density regions  
- Group macros logically in the same hierarchy  
- Promote higher metal layers for critical routing  
- Split high-fanout nets (HFNs) to reduce routing load  
- Introduce soft/hard blockages strategically  

---

## Clock Tree Synthesis (CTS) & Timing

### Q10: What is CTS and why is it needed?
**Answer:**  
- **Clock Tree Synthesis (CTS):** The process of distributing the clock signal uniformly across the design.  
- Uses H-tree or A-tree structures with buffers to reduce skew and insertion delay.  
- Objective: deliver the clock edge to all flip-flops at approximately the same time, minimizing skew and latency.  

---

### Q11: What are source and network latency in CTS?
**Answer:**  
- **Source latency:** Delay from the clock source to the launching flip-flop.  
- **Network latency:** Delay caused by routing, buffers, and cells along the clock tree.  
- Total clock latency = source + network latency.  

---

### Q12: Why is Multi-Mode Multi-Corner (MMMC) STA important?
**Answer:**  
- Tests timing under different operating conditions (mode) and PVT corners (process, voltage, temperature).  
- Ensures setup and hold are met under worst-case and best-case scenarios.  
- Example: worst-case slow process, low voltage, high temperature; hold worst-case fast process, high voltage, low temperature.  

---

## Static Timing Analysis (STA)

### Q13: Compute setup and hold slack for a data path
**Given:**  
- \(T_{CQ(max)} = 80 \text{ ps}\), \(D_{max} = 420 \text{ ps}\), \(T_{setup} = 90 \text{ ps}\), \(T_{clk} = 700 \text{ ps}\), \(T_{skew} = 30 \text{ ps}\)  
- \(T_{CQ(min)} = 25 \text{ ps}\), \(D_{min} = 65 \text{ ps}\), \(T_{hold} = 50 \text{ ps}\)  

**Answer:**  
- **Setup required period:** \(80 + 420 + 90 + 30 = 620\text{ ps}\)  
- Slack = \(T_{clk} - T_{clk,min} = 700 - 620 = 80\text{ ps}\) → timing met  
- **Hold margin:** \(25 + 65 = 90 ≥ 50 + 30 = 80\) → margin = 10 ps → hold met  

---

### Q14: Skew impact example
**Given:** Skew +20 ps and -20 ps  
**Answer:**  
- Positive skew (+20 ps): setup slack increases, hold satisfied  
- Negative skew (-20 ps): setup slack decreases, hold still satisfied  

---

### Q15: Multi-cycle path handling
**Answer:**  
- If combinational logic delay > clock period, define multi-cycle constraint:  
\[
T_{required} = N \cdot T_{clk} - T_{setup}
\]  
- STA calculates slack accordingly for N-cycle paths.  

---

### Q16: STA example with setup and hold violation
**Given:**  
- Setup slack = -40 ps → must fix path with buffers or upsizing  
- Hold slack = 170 ps → safe  

---

### Q17: Setup and hold numeric computation
**Answer:**  
- Setup: \(\text{Slack} = T_{clk} + T_{skew} - T_{setup} - (T_{CQ} + D_{max})\)  
- Hold: \(\text{Margin} = T_{CQ} + D_{min} - (T_{hold} + T_{skew})\)  

---

## Power, IR Drop & Electromigration

### Q18: Explain power grid and IR drop
**Answer:**  
- Power grid distributes VDD/VSS to cells and macros through horizontal/vertical metal layers connected via vias.  
- **IR drop:** Voltage drop due to resistive routing and current load. Can affect timing.  
- Mitigation: use wider metal layers, shield critical nets, provide dedicated power routes.  

---

### Q19: Electromigration (EM) example
**Given:** w = 0.6 μm, t = 0.4 μm, I = 2.5 mA, allowed = 1 mA/μm²  
**Answer:**  
- Area = 0.6 × 0.4 = 0.24 μm²  
- Current density = 2.5 / 0.24 ≈ 10.4 mA/μm² → exceeds limit  
- Mitigation: widen trace, use parallel wires, move to higher metal layers  

---

## Cell Sizing, Buffers & ECO

### Q20: Cell upsizing, buffers, spare cells, tie cells
**Answer:**  
- **Upsizing:** Increase transistor width to reduce delay for setup paths  
- **Downsizing:** Reduce width to increase delay for hold paths  
- **Buffers:** Adjust timing along critical paths  
- **Spare cells:** Reserved in layout for ECO fixes without restarting flow  
- **Tie cells:** Connected to VDD/VSS for density/power purposes, no logic  

---

### Q21: ECO definition
**Answer:**  
- Engineering Change Order  
- Used post-PnR to fix timing or functional issues without full redesign  
- Types: RTL-level, gate-level, or metal-only changes  

---

## Signal Integrity & Crosstalk

### Q22: Crosstalk numeric example
**Given:** Cc = 10 fF, Cv = 50 fF, VDD = 1 V  
**Answer:**  
\[
\Delta V = VDD \cdot \frac{C_c}{C_c + C_v} = 1 * \frac{10}{60} ≈ 0.167 V
\]  
- Mitigation: increase spacing, shielding, rerouting, or buffer insertion  

---
