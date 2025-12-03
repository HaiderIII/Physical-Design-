# Phase 3 Exercises: Timing Constraints (Enhanced sample_design.v)

## Objective
Apply timing constraints using Tcl on `sample_design.v`. Focus on clocks, I/O delays, false paths, multicycle paths, and prepare for multi-clock and macro analysis.

---

### Exercise 1: Clock Definition
- Define two clocks:
  - `clk_main` with a period of 10ns on port `clk`.
  - `clk_alt` with a period of 12ns on port `clk_alt`.

### Exercise 2: I/O Delays
- Set input delays relative to `clk_main`:
  - `data_in` → 2.0ns
  - `data_in2` → 1.5ns
- Set output delays relative to `clk_main`:
  - `data_out` → 3.0ns
  - `data_out2` → 2.5ns

### Exercise 3: False Path
- Identify a path from `ff1/Q` to `ff3/D` that should not be analyzed.
- Mark this path as false.

### Exercise 4: Multicycle Path
- Identify a path from `ff5/Q` to `ff8/D` that takes 3 clock cycles.
- Set this path as a multicycle path.

### Exercise 5: High Fanout Net Analysis
- Identify the high fanout net `hf1`.
- List all the sinks (loads) of this net.

### Exercise 6: Macro Access
- Access the macro instance `u_macro`.
- List its input and output pins.

### Exercise 7: Summary Check
- Print all clocks, false paths, multicycle paths, high fanout nets, and macro instances in the design.
