# Lesson 06 Exercises: OpenSTA - Static Timing Analysis

## 🎯 Exercise Overview

These exercises will help you master:
- Reading and analyzing timing reports
- Writing SDC constraints
- Using OpenSTA commands
- Identifying timing violations
- Understanding timing paths

## 📚 Prerequisites

Before starting:
- Complete Lesson 06
- Have OpenSTA installed
- Resources in: phase_00_foundations/resources/lesson06_opensta/
- Basic understanding of digital timing

## 🏋️ Exercise 1: First Timing Analysis (Beginner)

### Objective
Run your first OpenSTA analysis on a simple inverter

### Files Needed
- simple_inv.v
- simple_inv.sdc
- simple.lib

### Tasks

**1.1** Navigate to the resources directory

cd ~/projects/Physical-Design/phases/phase_00_foundations/resources/lesson06_opensta

**1.2** Create an analysis script: ex1_analysis.tcl

Content:

read_liberty simple.lib
read_verilog simple_inv.v
link_design inverter
read_sdc simple_inv.sdc
report_checks -path_delay max
report_checks -path_delay min

**1.3** Run OpenSTA

sta -f ex1_analysis.tcl

**1.4** Answer these questions:
- What is the clock period?
- Is there a setup violation?
- Is there a hold violation?
- What is the worst slack?

### Expected Output
✅ Design links successfully
✅ No timing violations
✅ Positive slack values

---

## 🏋️ Exercise 2: Understanding Timing Reports (Beginner)

### Objective
Learn to read and interpret timing report fields

### Files Needed
- pipeline_reg.v
- pipeline_reg.sdc
- simple.lib

### Tasks

**2.1** Create analysis script: ex2_detailed.tcl

read_liberty simple.lib
read_verilog pipeline_reg.v
link_design pipeline_reg
read_sdc pipeline_reg.sdc
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded

**2.2** Run and analyze the report

sta -f ex2_detailed.tcl > ex2_report.txt

**2.3** From the report, identify:
- Startpoint (launch flop)
- Endpoint (capture flop)
- Number of logic levels
- Clock network delay
- Data arrival time
- Data required time
- Slack value

**2.4** Calculate manually:
- Total combinational delay
- Setup margin
- Maximum frequency possible

### Questions to Answer
📝 What is the critical path?
📝 Which gate has the largest delay?
📝 What is the input slew rate?
📝 What is the output load capacitance?

---

## 🏋️ Exercise 3: Writing SDC Constraints (Intermediate)

### Objective
Write proper timing constraints for a design

### Files Needed
- adder8.v
- simple.lib

### Tasks

**3.1** Create SDC file: ex3_adder.sdc

Write constraints for:
- Clock definition (period = 5.0 ns)
- Input delays (1.5 ns for all inputs)
- Output delays (1.0 ns for all outputs)
- Load capacitance on outputs (0.1 pF)

**3.2** Create analysis script: ex3_adder.tcl

read_liberty simple.lib
read_verilog adder8.v
link_design adder8
read_sdc ex3_adder.sdc
report_checks -path_delay max
report_checks -path_delay min
report_worst_slack -max
report_worst_slack -min

**3.3** Run analysis and answer:
- Does the design meet timing?
- What is the critical path?
- What is the setup slack?
- What is the hold slack?

**3.4** Experiment:
- Change clock period to 3.0 ns
- Re-run analysis
- What happens to slack?

### Bonus Challenge
🎯 Find the minimum clock period where timing still meets

---

## 🏋️ Exercise 4: Fixing Setup Violations (Intermediate)

### Objective
Understand and fix setup timing violations

### Scenario
Given design has setup violation with 10 ns clock period

### Files Needed
- hier_design.v
- simple.lib

### Tasks

**4.1** Create initial SDC: ex4_tight.sdc

Create constraints with:
- Clock period = 3.0 ns (aggressive)
- Input delay = 1.0 ns
- Output delay = 1.0 ns

**4.2** Run initial analysis

read_liberty simple.lib
read_verilog hier_design.v
link_design hier_design
read_sdc ex4_tight.sdc
report_checks -path_delay max -n 5

**4.3** Document violations:
- How many setup violations?
- Worst negative slack?
- Which paths are critical?

**4.4** Fix the violations by:

Method 1: Relax clock period
- Try 4.0 ns, then 5.0 ns
- Find minimum period with no violations

Method 2: Relax I/O delays
- Reduce input/output delays
- Find acceptable values

**4.5** Compare solutions:
- Which method is more realistic?
- What are the tradeoffs?

### Questions
💡 Why does increasing clock period help?
�� What happens to frequency?
💡 How do I/O delays affect internal paths?

---

## 🏋️ Exercise 5: Hold Time Analysis (Intermediate)

### Objective
Understand hold violations and how to detect them

### Files Needed
- pipeline_reg.v
- simple.lib

### Tasks

**5.1** Create SDC with potential hold issues: ex5_hold.sdc

create_clock -name clk -period 2.0 [get_ports clk]
set_input_delay -clock clk -min 0.1 [get_ports data_in*]
set_output_delay -clock clk -min 0.1 [get_ports data_out*]
set_false_path -from [get_ports rst_n]

**5.2** Run hold analysis

read_liberty simple.lib
read_verilog pipeline_reg.v
link_design pipeline_reg
read_sdc ex5_hold.sdc
report_checks -path_delay min -n 10
report_worst_slack -min

**5.3** Analyze:
- Are there hold violations?
- What is the minimum path delay?
- What is the hold requirement?
- What is the hold slack?

**5.4** Understand the fix:
- Hold violations need MORE delay
- Cannot be fixed by changing clock period
- Require buffer insertion or cell sizing

### Questions
📝 Why can't clock period fix hold violations?
📝 What causes hold violations?
📝 How is hold analysis different from setup?

---

## 🏋️ Exercise 6: Path Queries and Filtering (Advanced)

### Objective
Master OpenSTA query commands and path filtering

### Files Needed
- hier_design.v
- simple.lib

### Tasks

**6.1** Create comprehensive analysis script: ex6_queries.tcl

read_liberty simple.lib
read_verilog hier_design.v
link_design hier_design
create_clock -name clk -period 10.0 [get_ports clk]

Query 1: Find all registers

foreach_in_collection ff [get_cells -hierarchical -filter "is_sequential == true"] {
    puts [get_property $ff full_name]
}

Query 2: Find high fanout nets

foreach_in_collection net [get_nets *] {
    set fanout [get_property $net fanout]
    if {$fanout > 5} {
        puts "Net: [get_property $net full_name] Fanout: $fanout"
    }
}

Query 3: Specific path analysis

report_checks -from [get_pins u_reg/reg_q*] -to [get_pins u_reg/reg_d*]

**6.2** Run and document:
- How many registers in design?
- Which nets have high fanout?
- What are the register-to-register paths?

**6.3** Advanced filtering:
- Find paths through specific logic
- Analyze only input-to-register paths
- Check only register-to-output paths

### Challenge
🎯 Write TCL loop to report slack for each register pair

---

## 🏋️ Exercise 7: Multi-File Design Analysis (Advanced)

### Objective
Analyze a hierarchical design with multiple modules

### Tasks

**7.1** Create top-level Verilog: ex7_top.v

module top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);
    wire [7:0] stage1, stage2;
    
    pipeline_reg u_stage1 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(stage1)
    );
    
    pipeline_reg u_stage2 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(stage1),
        .data_out(stage2)
    );
    
    pipeline_reg u_stage3 (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(stage2),
        .data_out(data_out)
    );
endmodule

**7.2** Create comprehensive SDC: ex7_top.sdc

create_clock -name clk -period 10.0 [get_ports clk]
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.2 [get_clocks clk]
set_input_delay -clock clk -max 3.0 [get_ports data_in*]
set_input_delay -clock clk -min 1.0 [get_ports data_in*]
set_output_delay -clock clk -max 2.5 [get_ports data_out*]
set_output_delay -clock clk -min 0.5 [get_ports data_out*]
set_false_path -from [get_ports rst_n]
set_load 0.15 [get_ports data_out*]

**7.3** Analyze each pipeline stage

read_liberty simple.lib
read_verilog pipeline_reg.v
read_verilog ex7_top.v
link_design top
read_sdc ex7_top.sdc
report_checks -from [get_pins u_stage1/*] -to [get_pins u_stage2/*]
report_checks -from [get_pins u_stage2/*] -to [get_pins u_stage3/*]
report_clock_skew

**7.4** Answer:
- What is the longest path?
- How many pipeline stages?
- What is the clock skew?
- Is timing balanced across stages?

---

## 🏋️ Exercise 8: Timing Exceptions (Advanced)

### Objective
Learn to properly define false paths and multicycle paths

### Files Needed
- hier_design.v
- simple.lib

### Tasks

**8.1** Create SDC with exceptions: ex8_exceptions.sdc

create_clock -name clk -period 10.0 [get_ports clk]

False path from reset

set_false_path -from [get_ports rst_n]

Multicycle path (2 cycles for computation)

set_multicycle_path -setup 2 -from [get_pins u_reg/data_in*] -to [get_pins u_reg/data_out*]
set_multicycle_path -hold 1 -from [get_pins u_reg/data_in*] -to [get_pins u_reg/data_out*]

False path between clock domains (if applicable)

set_false_path -from [get_clocks clk] -to [get_clocks async_clk]

**8.2** Analyze with and without exceptions:

Without exceptions:

read_liberty simple.lib
read_verilog hier_design.v
link_design hier_design
create_clock -name clk -period 10.0 [get_ports clk]
report_checks -path_delay max

With exceptions:

read_liberty simple.lib
read_verilog hier_design.v
link_design hier_design
read_sdc ex8_exceptions.sdc
report_checks -path_delay max

**8.3** Compare:
- How many paths analyzed?
- Which paths are now ignored?
- How does slack change?

---

## 🏋️ Exercise 9: Complete Analysis Flow (Expert)

### Objective
Perform complete timing signoff analysis

### Tasks

**9.1** Create production-quality script: ex9_signoff.tcl

puts "==================================="
puts "Starting Timing Analysis"
puts "==================================="

Read libraries

read_liberty simple.lib

Read design

read_verilog hier_design.v
link_design hier_design

Read constraints

read_sdc constraints.sdc

Setup analysis

puts "\n--- Setup Analysis ---"
report_checks -path_delay max -n 10 -format full_clock_expanded
report_worst_slack -max

Hold analysis

puts "\n--- Hold Analysis ---"
report_checks -path_delay min -n 10
report_worst_slack -min

Clock analysis

puts "\n--- Clock Analysis ---"
report_clock_skew
report_clock_properties [get_clocks *]

Design checks

puts "\n--- Design Checks ---"
check_setup -verbose
report_disabled_paths

Summary

puts "\n--- Summary ---"
puts "Setup WNS: [get_property [get_timing_paths -max_paths 1 -setup] slack]"
puts "Hold WNS: [get_property [get_timing_paths -max_paths 1 -hold] slack]"

**9.2** Generate complete report

sta -f ex9_signoff.tcl > ex9_timing_report.txt

**9.3** Create signoff checklist:
- [ ] All clocks defined
- [ ] I/O constraints specified
- [ ] False paths marked
- [ ] Setup slack positive
- [ ] Hold slack positive
- [ ] No unconstrained paths
- [ ] Clock skew acceptable
- [ ] All checks pass

---

## 🏋️ Exercise 10: Optimization Challenge (Expert)

### Objective
Optimize a failing design to meet timing

### Scenario
Given design fails timing at 100 MHz (10 ns period)
Goal: Meet timing at 150 MHz (6.67 ns period)

### Files Needed
- adder8.v
- simple.lib

### Tasks

**10.1** Baseline analysis at 100 MHz

create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay -clock clk 2.0 [all_inputs]
set_output_delay -clock clk 2.0 [all_outputs]

**10.2** Attempt 150 MHz

create_clock -name clk -period 6.67 [get_ports clk]

**10.3** Document violations:
- Negative slack value?
- Critical path elements?
- Bottleneck gates?

**10.4** Propose solutions:
- Pipeline insertion points
- Logic restructuring
- Constraint relaxation
- Architecture changes

**10.5** Implement best solution and verify

### Deliverables
📄 Initial timing report
📄 Critical path analysis
📄 Optimization plan
📄 Final timing report
📄 Frequency achieved

---

## ✅ Solution Checklist

For each exercise, verify:
- [ ] All commands run without errors
- [ ] Reports generated successfully
- [ ] Questions answered completely
- [ ] Slack values documented
- [ ] Understanding demonstrated

## 🎯 Completion Criteria

You have mastered this lesson when you can:
- ✅ Run OpenSTA analysis independently
- ✅ Read and interpret timing reports
- ✅ Write correct SDC constraints
- ✅ Identify setup and hold violations
- ✅ Query design paths effectively
- ✅ Apply timing exceptions properly
- ✅ Perform complete timing signoff

## 📚 Additional Challenges

For more practice:
1. Analyze your own Verilog designs
2. Create multi-corner analysis scripts
3. Write automated timing reporting
4. Compare OpenSTA with commercial tools
5. Optimize real designs for timing

---

**Next Steps:** Check solutions in phase_00_foundations/solutions/06_opensta_intro_solutions.md

**Need Help?** Review Lesson 06 or consult OpenSTA documentation

---

💪 Happy timing analysis!
