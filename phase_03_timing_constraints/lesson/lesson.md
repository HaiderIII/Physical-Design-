# Phase 3: Timing Constraints

## Objective
Understand how to define and interpret timing constraints in an ASIC backend design. Be able to write Tcl scripts that apply, check, and analyze these constraints using the enhanced `sample_design.v` netlist.

---

## 1. Clock Definitions
- Define clocks in the design using `create_clock` or similar commands.
- This netlist has two clocks: `clk` and `clk_alt`.
- Specify period, waveform, and associated ports.
- Example concepts:
  ```tcll
  create_clock -name clk_main -period 10 [get_ports clk]
  create_clock -name clk_alt -period 12 [get_ports clk_alt]
  ```
- Clocks drive flip-flops; all paths are measured relative to clocks.

---

## 2. I/O Delays
- Input delay: time data arrives at a pin relative to the external clock.
- Output delay: time data must be valid on an output pin.
- This netlist has multiple I/Os: `data_in`, `data_in2`, `data_out`, `data_out2`.
- Example concept:
  ```tcl
  set_input_delay -clock clk_main 2.0 [get_ports data_in]
  set_input_delay -clock clk_main 1.5 [get_ports data_in2]
  set_output_delay -clock clk_main 3.0 [get_ports data_out]
  set_output_delay -clock clk_main 2.5 [get_ports data_out2]
  ```
- Properly setting I/O delays ensures timing analysis reflects system-level constraints.

---

## 3. False Paths & Multicycle Paths
- False path: a path that should not be considered in STA because it will never be exercised.
  ```tcl
  set_false_path -from [get_pins ff1/Q] -to [get_pins ff3/D]
  ```
- Multicycle path: path that has multiple cycles to settle; slack must be adjusted.
  ```tcl
  set_multicycle_path 3 -from [get_pins ff5/Q] -to [get_pins ff8/D]
  ```

---

## 4. High Fanout Nets
- Identify high fanout nets such as `hf1`.
- Use Tcl to list all loads (sinks) connected to the net:
  ```tcl
  get_nets hf1
  ```
- High fanout nets are critical for timing and buffering considerations.

---

## 5. Macro Access
- Access macro instances, e.g., `u_macro`.
- List input and output pins:
  ```tcl
  get_cells u_macro
  get_pins [get_cells u_macro]
  ```
- Enables hierarchical queries and manipulation in Tcl.

---

## Summary
- Clocks anchor timing; multiple clocks allow multi-clock path practice.
- I/O delays represent interface requirements on multiple ports.
- False/multicycle paths modify analysis assumptions.
- High fanout nets and macro instances provide realistic backend scenarios.
- All constraints and accesses must be reflected in Tcl scripts for reproducible and tool-independent analysis.