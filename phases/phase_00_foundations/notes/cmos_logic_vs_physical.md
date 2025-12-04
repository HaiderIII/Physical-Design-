# CMOS Logic vs Physical Implementation

## Logic View
- Ideal, functional representation of the circuit
- Signals are boolean; gates are instantaneous
- Wires have no length, no resistance or capacitance
- Timing is abstract and assumed
- Artifacts: RTL, truth tables, Boolean equations
- Focus: **function correctness** only

## Physical View
- Real, geometric realization of the circuit
- Gates become standard cell instances
- Wires become routed nets with RC delays
- Clock becomes a physical network
- Timing, area, and manufacturability constraints exist
- Artifacts: LEF, DEF, floorplan, netlist, routed layout
- Focus: **timing, area, routing, manufacturability**

## Key Differences
| Concept           | Logic View          | Physical View                  |
|------------------|------------------|--------------------------------|
| Gates             | Abstract function | Standard cell instance         |
| Wires             | Ideal connection  | Routed nets with RC delays     |
| Clock             | Concept           | Physical tree or mesh          |
| Delay             | Assumed           | Actual, path-dependent         |
| Timing verification | Simulation       | Static Timing Analysis (STA)  |

## Implications for Tcl
- Tcl scripts interact with **physical objects derived from logic**, not logic itself
- Manipulate: cells, pins, nets, paths, coordinates, constraints
- Confusing logic with physical reality leads to incorrect scripts

## Self-Check Question
- Why can a functionally correct RTL fail in Physical Implementation?
