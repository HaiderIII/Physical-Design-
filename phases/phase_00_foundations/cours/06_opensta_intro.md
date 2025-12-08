# Lesson 06: Introduction to OpenSTA - Static Timing Analysis

## 🎯 Learning Objectives
- Understand Static Timing Analysis (STA) concepts
- Learn OpenSTA commands and workflow
- Read and write SDC (Synopsys Design Constraints)
- Analyze timing paths and identify violations
- Generate timing reports

## 📚 What is Static Timing Analysis?

### Definition
🔍 **STA** = Static Timing Analysis
- Verifies timing WITHOUT simulation
- Checks ALL paths in the design
- Ensures setup and hold times are met
- Critical for chip signoff

### Why Static?
✅ Exhaustive coverage (all paths)
✅ Fast analysis (no vectors needed)
✅ Industry standard methodology
❌ Doesn't verify functionality

## ⏱️ Timing Concepts

### Basic Timing Terms

**Setup Time** 📥
- Data must arrive BEFORE clock edge
- Ensures data is stable for capture
- Violation = data arrives too late

**Hold Time** 📌
- Data must stay stable AFTER clock edge
- Prevents data corruption
- Violation = data changes too soon

**Clock Period** 🕐
- Time between clock edges
- Determines maximum frequency
- Formula: Freq = 1 / Period

### Timing Path Components

Launch Flop → Combinational Logic → Capture Flop

**Path Delay = CLK-to-Q + Logic Delay + Net Delay + Setup**

## 🛠️ OpenSTA Basics

### What is OpenSTA?

OpenSTA = Open Source Static Timing Analyzer
- Part of OpenROAD project
- Industry-quality timing engine
- TCL-based interface
- Reads Liberty (.lib) files

### Installation Check

sta -version

### Basic OpenSTA Workflow

1. Read liberty library
2. Read netlist (Verilog)
3. Link design
4. Read constraints (SDC)
5. Run timing analysis
6. Generate reports

## 📝 SDC - Synopsys Design Constraints

### What is SDC?

SDC = Industry standard format for timing constraints
- Clock definitions
- Input/Output delays
- Timing exceptions
- Design rules

### Essential SDC Commands

**Clock Definition** 🕐

create_clock -name clk -period 10.0 [get_ports clk_pin]

- Creates clock object
- Period in nanoseconds
- Associates with port/pin

**Input Delay** 📥

set_input_delay -clock clk -max 2.0 [get_ports data_in]

- External logic delay before input
- Relative to clock edge
- Affects setup analysis

**Output Delay** 📤

set_output_delay -clock clk -max 1.5 [get_ports data_out]

- Next stage requirements
- Relative to clock edge
- Affects output path timing

**Timing Exceptions** ⚡

set_false_path -from [get_ports reset]
set_multicycle_path -setup 2 -from [get_pins FF1/Q]

## 🔬 OpenSTA Commands

### Reading Design Files

read_liberty library.lib

- Reads cell timing models
- Contains delay tables
- Multiple corners possible

read_verilog design.v

- Reads gate-level netlist
- Post-synthesis format
- Hierarchical designs supported

link_design top_module

- Connects netlist to library
- Resolves cell references
- Reports missing cells

### Reading Constraints

read_sdc constraints.sdc

- Loads timing constraints
- Clock definitions
- I/O delays
- Exceptions

### Timing Analysis Commands

report_checks -path_delay max

- Shows worst setup paths
- Critical path analysis
- Slack calculation

report_checks -path_delay min

- Shows worst hold paths
- Hold violations
- Min delay paths

report_worst_slack -max
report_worst_slack -min

- Quick slack summary
- Setup slack (max)
- Hold slack (min)

### Path Reporting

report_checks -from [get_pins FF1/Q] -to [get_pins FF2/D]

- Specific path analysis
- Detailed timing breakdown
- Startpoint to endpoint

report_checks -through [get_pins LOGIC_GATE/A]

- Paths through specific pin
- Debug specific logic
- Multi-stage analysis

### Design Queries

get_ports pattern*

- Find ports by pattern
- Wildcard matching
- Returns port collection

get_pins cell_name/pin_name

- Access specific pins
- Hierarchical paths
- Pin-level queries

get_cells pattern*

- Find cells/instances
- Hierarchical selection
- Instance collection

## 📊 Understanding Timing Reports

### Setup Timing Report Structure

Startpoint: FF1/Q (rising edge-triggered flip-flop clocked by clk)
Endpoint: FF2/D (rising edge-triggered flip-flop clocked by clk)
Path Type: max

Point                    Incr      Path
--------------------------------------------
clock clk (rise edge)    0.00      0.00
clock network delay      0.50      0.50
FF1/CLK (DFF_X1)         0.00      0.50
FF1/Q (DFF_X1)           0.15      0.65 r
U1/A (AND2_X1)           0.00      0.65 r
U1/Y (AND2_X1)           0.08      0.73 r
U2/A (OR2_X1)            0.02      0.75 r
U2/Y (OR2_X1)            0.10      0.85 r
FF2/D (DFF_X1)           0.00      0.85 r
data arrival time                  0.85

clock clk (rise edge)   10.00     10.00
clock network delay      0.50     10.50
FF2/CLK (DFF_X1)         0.00     10.50
library setup time      -0.08     10.42
data required time                10.42
--------------------------------------------
slack (MET)                        9.57

### Reading the Report

**Slack Calculation** 📐
Slack = Required Time - Arrival Time
- Positive slack = timing MET ✅
- Negative slack = VIOLATION ❌
- Zero slack = exactly met (risky) ⚠️

**Incremental vs Path Delay**
- Incr = delay of this stage
- Path = cumulative delay

**Rise/Fall Transitions**
- r = rising edge
- f = falling edge

## 🎓 Practical Example - Simple Pipeline

### Design Files

Example Verilog: pipeline_reg.v (see resources)
Example SDC: pipeline_reg.sdc (see resources)

### Analysis Script

read_liberty ../resources/lesson06_opensta/simple.lib
read_verilog ../resources/lesson06_opensta/pipeline_reg.v
link_design pipeline_reg
read_sdc ../resources/lesson06_opensta/pipeline_reg.sdc
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded
report_checks -path_delay min
report_worst_slack -max
report_worst_slack -min

### Expected Output Analysis

Setup Check:
- Clock period: 10.0 ns
- Path delay: ~1.5 ns
- Setup time: 0.08 ns
- Slack: +8.42 ns (MET)

Hold Check:
- Hold time: 0.05 ns
- Min path: ~0.2 ns
- Slack: +0.15 ns (MET)

## 🔧 Common Analysis Tasks

### Finding Critical Paths

report_checks -path_delay max -n 10

- Top 10 worst setup paths
- Identify bottlenecks
- Optimization targets

### Clock Skew Analysis

report_clock_skew

- Clock network imbalance
- Launch vs capture skew
- Hold time impact

### Fanout Analysis

report_net -connections -verbose [get_nets critical_net]

- Net fanout
- Load capacitance
- Driver strength

## ⚠️ Common Timing Violations

### Setup Violation
❌ Data arrives TOO LATE

**Causes:**
- Logic too slow
- Long routing
- High fanout
- Weak drivers

**Fixes:**
- Reduce logic depth
- Buffer insertion
- Upsize gates
- Reduce clock frequency

### Hold Violation
❌ Data changes TOO SOON

**Causes:**
- Path too fast
- Clock skew
- Short routing
- Strong drivers

**Fixes:**
- Add delay buffers
- Adjust clock tree
- Downsize gates
- Balance clock distribution

## 📋 Complete Analysis Checklist

Before Signoff:
☐ All clocks defined
☐ I/O delays specified
☐ False paths marked
☐ Multicycle paths defined
☐ Setup slack > 0
☐ Hold slack > 0
☐ No unconstrained paths
☐ Clock skew analyzed
☐ Max transition checked
☐ Max capacitance checked

## 💡 Best Practices

### Constraint Writing
✅ Start with clock definition
✅ Add realistic I/O delays
✅ Document all exceptions
✅ Use consistent naming
✅ Group related constraints

### Analysis Strategy
✅ Check worst paths first
✅ Analyze all corners
✅ Verify clock domains
✅ Check timing exceptions
✅ Review all warnings

### Reporting
✅ Save reports to files
✅ Compare across runs
✅ Track slack trends
✅ Document violations
✅ Version control SDC

## 🎯 Key Takeaways

1. 📊 STA verifies timing exhaustively without simulation
2. ⏱️ Setup = data arrives before clock, Hold = data stable after clock
3. 📝 SDC defines all timing requirements
4. 🔍 OpenSTA analyzes paths and reports slack
5. ✅ Positive slack = timing met, negative = violation
6. 🛠️ Liberty files contain cell timing models
7. 📐 Slack = Required Time - Arrival Time
8. 🎯 Critical path = worst (minimum) slack path

## 📚 Further Reading

- OpenSTA documentation
- SDC command reference
- Liberty file format specification
- Timing closure techniques
- Clock domain crossing

## 🏋️ Practice Exercises

See: phase_00_foundations/exercices/06_opensta_intro_exercises.md

Resources: phase_00_foundations/resources/lesson06_opensta/

---

**Next Lesson:** Advanced OpenSTA - Multi-corner Analysis and Optimization

**Prerequisites Mastered:** ✅ TCL basics, File I/O, Liberty basics

---

💪 Ready to analyze timing like a pro!
