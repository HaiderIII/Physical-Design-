# Lesson 02: TCL Control Flow - Conditionals and Loops

## Table of Contents
1. Introduction to Control Flow
2. If-Else Statements
3. Switch-Case Statements
4. While Loops
5. For Loops
6. Foreach Loops
7. Break and Continue
8. Nested Control Structures
9. Common Patterns in Physical Design
10. Practice Exercises

---

## 1. Introduction to Control Flow

### What is Control Flow? 🎯

Control flow determines the ORDER in which code executes.

Three main types:
- Sequential: Line by line (default)
- Conditional: Execute based on condition
- Iterative: Repeat code multiple times

### Why Control Flow Matters in Physical Design 🔧

Use case: Check timing violations

    if {$slack < 0} {
        puts "TIMING VIOLATION"
    }

Use case: Process all cells in design

    foreach cell $cell_list {
        optimize_cell $cell
    }

Use case: Iterate through clock domains

    for {set i 0} {$i < $num_clocks} {incr i} {
        analyze_clock $i
    }

---

## 2. If-Else Statements

### Basic If Statement ✅

Syntax:

    if {condition} {
        code_to_execute
    }

Example: Check voltage level

    set vdd 1.8
    
    if {$vdd < 1.5} {
        puts "Voltage too low"
    }

⚠️ Important: Condition MUST be in braces { }

### If-Else Statement 🔀

Syntax:

    if {condition} {
        code_if_true
    } else {
        code_if_false
    }

Example: Timing check

    set slack 0.5
    
    if {$slack >= 0} {
        puts "Timing constraint MET"
    } else {
        puts "Timing constraint VIOLATED"
    }

### If-Elseif-Else Statement ��️

Syntax:

    if {condition1} {
        code_block_1
    } elseif {condition2} {
        code_block_2
    } elseif {condition3} {
        code_block_3
    } else {
        code_block_default
    }

Example: Grade classification

    set score 85
    
    if {$score >= 90} {
        puts "Grade: A"
    } elseif {$score >= 80} {
        puts "Grade: B"
    } elseif {$score >= 70} {
        puts "Grade: C"
    } elseif {$score >= 60} {
        puts "Grade: D"
    } else {
        puts "Grade: F"
    }

Output:

    Grade: B

### Comparison Operators Review 📊

Equal:

    if {$x == 10} { ... }

Not equal:

    if {$x != 10} { ... }

Greater than:

    if {$x > 10} { ... }

Less than:

    if {$x < 10} { ... }

Greater or equal:

    if {$x >= 10} { ... }

Less or equal:

    if {$x <= 10} { ... }

### Logical Operators in Conditions 🔗

AND operator:

    set voltage 1.8
    set temp 25
    
    if {$voltage >= 1.62 && $voltage <= 1.98 && $temp <= 85} {
        puts "Operating conditions VALID"
    }

OR operator:

    set error_count 0
    set warning_count 5
    
    if {$error_count > 0 || $warning_count > 10} {
        puts "Design needs review"
    }

NOT operator:

    set design_clean 1
    
    if {!$design_clean} {
        puts "Run cleanup"
    }

### String Comparison 📝

String equal:

    set mode "synthesis"
    
    if {$mode eq "synthesis"} {
        puts "Running synthesis..."
    }

String not equal:

    if {$mode ne "place_route"} {
        puts "Not in place and route mode"
    }

String match with wildcards:

    set filename "counter_16bit.v"
    
    if {[string match "*counter*" $filename]} {
        puts "Counter module detected"
    }

### Checking Variable Existence 🔍

    if {[info exists my_variable]} {
        puts "Variable exists: $my_variable"
    } else {
        puts "Variable not defined"
    }

### Multiple Conditions Example 🌡️

Physical design voltage check:

    set vdd 1.8
    set vss 0.0
    set temp 85
    set process "typical"
    
    if {$vdd >= 1.62 && $vdd <= 1.98} {
        if {$temp <= 125} {
            if {$process eq "typical" || $process eq "fast"} {
                puts "ALL PVT conditions VALID"
                puts "   Voltage: $vdd V"
                puts "   Temperature: $temp C"
                puts "   Process: $process"
            } else {
                puts "Invalid process corner"
            }
        } else {
            puts "Temperature out of range"
        }
    } else {
        puts "Voltage out of specification"
    }

Output:

    ALL PVT conditions VALID
       Voltage: 1.8 V
       Temperature: 85 C
       Process: typical

---

## 3. Switch-Case Statements

### Basic Switch Statement 🎛️

Syntax:

    switch $variable {
        pattern1 {
            code_block_1
        }
        pattern2 {
            code_block_2
        }
        default {
            code_block_default
        }
    }

Example: Process corner selection

    set corner "slow"
    
    switch $corner {
        fast {
            puts "Fast corner: Best performance"
            set delay_multiplier 0.8
        }
        typical {
            puts "Typical corner: Nominal"
            set delay_multiplier 1.0
        }
        slow {
            puts "Slow corner: Worst performance"
            set delay_multiplier 1.2
        }
        default {
            puts "Unknown corner"
            set delay_multiplier 1.0
        }
    }

Output:

    Slow corner: Worst performance

### Switch with Multiple Patterns 🔀

Multiple values can share same action:

    set signal_type "clock"
    
    switch $signal_type {
        clock -
        clk -
        CLK {
            puts "Clock signal detected"
            set is_clock 1
        }
        reset -
        rst -
        RST {
            puts "Reset signal detected"
            set is_reset 1
        }
        data {
            puts "Data signal"
        }
        default {
            puts "Unknown signal type"
        }
    }

Note: Dash (-) means "fall through to next case"

### Switch with Pattern Matching 🎯

Use -glob option for wildcards:

    set filename "counter_32bit_syn.v"
    
    switch -glob $filename {
        "*_syn.v" {
            puts "Synthesized Verilog file"
        }
        "*_tb.v" {
            puts "Testbench file"
        }
        "*.sdc" {
            puts "Timing constraint file"
        }
        "*.lib" {
            puts "Liberty library file"
        }
        default {
            puts "Generic file"
        }
    }

Output:

    Synthesized Verilog file

### Switch with Regular Expressions 🔤

Use -regexp option:

    set cell_name "BUFX2_LVT"
    
    switch -regexp $cell_name {
        {^BUF} {
            puts "Buffer cell"
        }
        {^INV} {
            puts "Inverter cell"
        }
        {^DFF} {
            puts "Flip-flop cell"
        }
        {_LVT$} {
            puts "Low Vt variant"
        }
        default {
            puts "Other cell type"
        }
    }

Output:

    Buffer cell

### Practical Switch Example 📋

Design stage management:

    set design_stage "synthesis"
    
    switch $design_stage {
        rtl {
            puts "RTL Design Stage"
            puts "   - Write Verilog code"
            puts "   - Run lint checks"
            puts "   - Simulate design"
        }
        synthesis {
            puts "Synthesis Stage"
            puts "   - Read RTL files"
            puts "   - Apply constraints"
            puts "   - Generate netlist"
            set sdc_file "design.sdc"
        }
        placement {
            puts "Placement Stage"
            puts "   - Read netlist"
            puts "   - Place cells"
            puts "   - Optimize timing"
        }
        routing {
            puts "Routing Stage"
            puts "   - Route signals"
            puts "   - Fix DRC violations"
            puts "   - Optimize"
        }
        verification {
            puts "Verification Stage"
            puts "   - DRC check"
            puts "   - LVS check"
            puts "   - Timing signoff"
        }
        default {
            puts "Unknown design stage: $design_stage"
        }
    }

Output:

    Synthesis Stage
       - Read RTL files
       - Apply constraints
       - Generate netlist

---

## 4. While Loops

### Basic While Loop 🔁

Syntax:

    while {condition} {
        code_to_repeat
    }

Example: Count to 5

    set count 1
    
    while {$count <= 5} {
        puts "Count: $count"
        incr count
    }

Output:

    Count: 1
    Count: 2
    Count: 3
    Count: 4
    Count: 5

### While Loop with Complex Condition ⚙️

Example: Timing optimization loop

    set slack -0.5
    set iteration 0
    set max_iterations 10
    
    while {$slack < 0 && $iteration < $max_iterations} {
        puts "Iteration $iteration: Slack = $slack ns"
        
        set slack [expr {$slack + 0.15}]
        incr iteration
    }
    
    if {$slack >= 0} {
        puts "Timing MET after $iteration iterations"
    } else {
        puts "Failed to meet timing after $max_iterations iterations"
    }

Output:

    Iteration 0: Slack = -0.5 ns
    Iteration 1: Slack = -0.35 ns
    Iteration 2: Slack = -0.2 ns
    Iteration 3: Slack = -0.05 ns
    Timing MET after 4 iterations

### Infinite Loop Prevention ⚠️

Always ensure loop will eventually terminate:

Bad example (infinite loop):

    set x 10
    while {$x > 0} {
        puts $x
    }

Good example:

    set x 10
    while {$x > 0} {
        puts $x
        incr x -1
    }

### While Loop for File Processing 📄

Read until specific condition:

    set line_number 1
    set max_lines 100
    set found 0
    
    while {$line_number <= $max_lines && !$found} {
        set line "line $line_number"
        
        if {[string match "*error*" $line]} {
            puts "Error found at line $line_number"
            set found 1
        }
        
        incr line_number
    }

---

## 5. For Loops

### Basic For Loop 🔢

Syntax:

    for {initialization} {condition} {increment} {
        code_to_repeat
    }

Example: Count from 0 to 4

    for {set i 0} {$i < 5} {incr i} {
        puts "Iteration: $i"
    }

Output:

    Iteration: 0
    Iteration: 1
    Iteration: 2
    Iteration: 3
    Iteration: 4

### For Loop Components Explained 📚

    for {set i 0} {$i < 5} {incr i} { ... }
         ^^^^^^^^  ^^^^^^^^  ^^^^^^^
            |          |         |
         Initial   Condition  Increment

Step 1: set i 0 (run once at start)
Step 2: Check dollar sign i < 5 (before each iteration)
Step 3: Execute loop body
Step 4: incr i (after each iteration)
Step 5: Go back to step 2

### Counting Backward ⏪

    for {set i 10} {$i >= 0} {incr i -1} {
        puts "Countdown: $i"
    }

Output:

    Countdown: 10
    Countdown: 9
    ...
    Countdown: 1
    Countdown: 0

### Custom Increment 🎯

Count by 2:

    for {set i 0} {$i <= 10} {incr i 2} {
        puts "Even number: $i"
    }

Output:

    Even number: 0
    Even number: 2
    Even number: 4
    Even number: 6
    Even number: 8
    Even number: 10

### For Loop with Calculation ⏱️

Generate clock periods:

    puts "Clock Period Table"
    puts "Freq(MHz) | Period(ns)"
    puts "----------|----------"
    
    for {set freq 100} {$freq <= 500} {incr freq 100} {
        set period [expr {1000.0 / $freq}]
        puts "[format %9d $freq] | [format %.2f $period]"
    }

Output:

    Clock Period Table
    Freq(MHz) | Period(ns)
    ----------|----------
          100 | 10.00
          200 | 5.00
          300 | 3.33
          400 | 2.50
          500 | 2.00

### Multiple Variables in For Loop 🔗

    for {set x 0; set y 10} {$x < 5} {incr x; incr y -1} {
        puts "x=$x, y=$y, sum=[expr {$x + $y}]"
    }

Output:

    x=0, y=10, sum=10
    x=1, y=9, sum=10
    x=2, y=8, sum=10
    x=3, y=7, sum=10
    x=4, y=6, sum=10

---

## 6. Foreach Loops

### Basic Foreach Loop 📦

Syntax:

    foreach variable $list {
        code_to_execute
    }

Example: Process signal list

    set signals {clk rst data valid ready}
    
    foreach sig $signals {
        puts "Processing signal: $sig"
    }

Output:

    Processing signal: clk
    Processing signal: rst
    Processing signal: data
    Processing signal: valid
    Processing signal: ready

### Foreach with Index 🔢

Get both element and position:

    set pins {A B C D E}
    set index 0
    
    foreach pin $pins {
        puts "Pin $index: $pin"
        incr index
    }

Output:

    Pin 0: A
    Pin 1: B
    Pin 2: C
    Pin 3: D
    Pin 4: E

### Foreach with Multiple Variables 🔗

Process pairs:

    set pin_pairs {A1 A2 B1 B2 C1 C2}
    
    foreach {pin1 pin2} $pin_pairs {
        puts "Pair: $pin1 <-> $pin2"
    }

Output:

    Pair: A1 <-> A2
    Pair: B1 <-> B2
    Pair: C1 <-> C2

### Nested Foreach 🗺️

Process 2D grid:

    set rows {1 2 3}
    set cols {A B C}
    
    foreach row $rows {
        foreach col $cols {
            puts "Cell: $col$row"
        }
    }

Output:

    Cell: A1
    Cell: B1
    Cell: C1
    Cell: A2
    Cell: B2
    Cell: C2
    Cell: A3
    Cell: B3
    Cell: C3

### Foreach with Timing Paths ⏱️

    set paths {
        {FF1 FF2 5.2}
        {FF2 FF3 3.8}
        {FF3 FF4 4.5}
    }
    
    puts "Timing Path Report"
    puts "From | To  | Delay(ns)"
    puts "-----|-----|----------"
    
    foreach path $paths {
        set from [lindex $path 0]
        set to [lindex $path 1]
        set delay [lindex $path 2]
        puts "[format %4s $from] | [format %3s $to] | [format %.1f $delay]"
    }

Output:

    Timing Path Report
    From | To  | Delay(ns)
    -----|-----|----------
     FF1 | FF2 | 5.2
     FF2 | FF3 | 3.8
     FF3 | FF4 | 4.5

---

## 7. Break and Continue

### Break Statement 🛑

Exit loop immediately:

    for {set i 0} {$i < 10} {incr i} {
        if {$i == 5} {
            puts "Breaking at $i"
            break
        }
        puts "i = $i"
    }

Output:

    i = 0
    i = 1
    i = 2
    i = 3
    i = 4
    Breaking at 5

### Continue Statement ⏭️

Skip to next iteration:

    for {set i 0} {$i < 10} {incr i} {
        if {$i % 2 == 0} {
            continue
        }
        puts "Odd number: $i"
    }

Output:

    Odd number: 1
    Odd number: 3
    Odd number: 5
    Odd number: 7
    Odd number: 9

### Break in While Loop 🔄

    set errors 0
    set line 1
    
    while {$line <= 100} {
        if {$line == 42} {
            puts "Critical error at line $line"
            set errors 1
            break
        }
        incr line
    }
    
    if {$errors} {
        puts "Processing stopped due to errors"
    }

Output:

    Critical error at line 42
    Processing stopped due to errors

### Continue in Foreach ⏩

Skip certain elements:

    set cells {BUF INV NAND2 NOR2 DFF}
    
    foreach cell $cells {
        if {$cell eq "NAND2"} {
            puts "Skipping $cell"
            continue
        }
        puts "Processing $cell"
    }

Output:

    Processing BUF
    Processing INV
    Skipping NAND2
    Processing NOR2
    Processing DFF

### Practical Example: Find First Violation 🔍

    set timing_paths {
        {path1 0.5}
        {path2 0.3}
        {path3 -0.2}
        {path4 0.1}
    }
    
    set violation_found 0
    
    foreach path $timing_paths {
        set name [lindex $path 0]
        set slack [lindex $path 1]
        
        if {$slack < 0} {
            puts "VIOLATION: $name has slack $slack ns"
            set violation_found 1
            break
        }
        
        puts "$name: slack $slack ns"
    }
    
    if {!$violation_found} {
        puts "All paths meeting timing"
    }

Output:

    path1: slack 0.5 ns
    path2: slack 0.3 ns
    VIOLATION: path3 has slack -0.2 ns

---

## 8. Nested Control Structures

### If Inside For Loop 🔄

    puts "Voltage Compliance Check"
    
    for {set i 1} {$i <= 5} {incr i} {
        set voltage [expr {1.7 + $i * 0.05}]
        
        if {$voltage >= 1.62 && $voltage <= 1.98} {
            puts "Supply $i: $voltage V PASS"
        } else {
            puts "Supply $i: $voltage V FAIL"
        }
    }

Output:

    Voltage Compliance Check
    Supply 1: 1.75 V PASS
    Supply 2: 1.8 V PASS
    Supply 3: 1.85 V PASS
    Supply 4: 1.9 V PASS
    Supply 5: 1.95 V PASS

### Foreach Inside If 📊

    set mode "analysis"
    
    if {$mode eq "analysis"} {
        set reports {timing power area}
        
        foreach report $reports {
            puts "Generating $report report..."
        }
    }

Output:

    Generating timing report...
    Generating power report...
    Generating area report...

### Nested For Loops 🔢

Multiplication table:

    puts "Multiplication Table"
    
    for {set i 1} {$i <= 5} {incr i} {
        for {set j 1} {$j <= 5} {incr j} {
            set product [expr {$i * $j}]
            puts -nonewline "[format %3d $product] "
        }
        puts ""
    }

Output:

    Multiplication Table
      1   2   3   4   5 
      2   4   6   8  10 
      3   6   9  12  15 
      4   8  12  16  20 
      5  10  15  20  25

### Complex Nested Example 🎯

Design rule checking simulation:

    set layers {metal1 metal2 metal3}
    set rules {width spacing}
    
    puts "Design Rule Check Results"
    puts "========================================"
    
    foreach layer $layers {
        puts ""
        puts "Layer: [string toupper $layer]"
        
        foreach rule $rules {
            set violations [expr {int(rand() * 5)}]
            
            if {$violations == 0} {
                puts "  $rule: PASS"
            } else {
                puts "  $rule: $violations violations"
                
                for {set i 1} {$i <= $violations} {incr i} {
                    set location [expr {int(rand() * 1000)}]
                    puts "     Violation $i at coordinate: $location"
                }
            }
        }
    }

Example output:

    Design Rule Check Results
    ========================================
    
    Layer: METAL1
      width: PASS
      spacing: 2 violations
         Violation 1 at coordinate: 432
         Violation 2 at coordinate: 867
    
    Layer: METAL2
      width: PASS
      spacing: PASS
    
    Layer: METAL3
      width: 1 violations
         Violation 1 at coordinate: 234
      spacing: PASS

---

## 9. Common Patterns in Physical Design

### Pattern 1: Constraint Application ⏰

    set clock_ports {clk sys_clk ref_clk}
    set clock_period 5.0
    
    foreach clk $clock_ports {
        puts "Creating clock: $clk"
        puts "   Period: $clock_period ns"
    }

### Pattern 2: Iterative Optimization 🔧

    set target_slack 0.0
    set current_slack -0.8
    set max_iterations 20
    set iteration 0
    
    puts "Target slack: $target_slack ns"
    puts "Initial slack: $current_slack ns"
    puts ""
    
    while {$current_slack < $target_slack && $iteration < $max_iterations} {
        incr iteration
        
        set improvement [expr {0.1 + rand() * 0.1}]
        set current_slack [expr {$current_slack + $improvement}]
        
        puts "Iteration $iteration: slack = [format %.3f $current_slack] ns"
        
        if {$current_slack >= $target_slack} {
            puts ""
            puts "Timing CONVERGED after $iteration iterations"
            break
        }
    }
    
    if {$current_slack < $target_slack} {
        puts ""
        puts "Did not converge after $max_iterations iterations"
        puts "Final slack: [format %.3f $current_slack] ns"
    }

### Pattern 3: Report Generation 📋

    set corners {fast typical slow}
    set voltages {1.62 1.8 1.98}
    set temps {-40 25 125}
    
    puts "PVT Corner Analysis"
    puts "=================================================="
    
    set corner_index 0
    foreach corner $corners {
        set voltage [lindex $voltages $corner_index]
        set temp [lindex $temps $corner_index]
        
        puts ""
        puts "Corner: [string toupper $corner]"
        puts "   Voltage: $voltage V"
        puts "   Temperature: $temp C"
        
        set wns [expr {-0.5 + $corner_index * 0.3}]
        set tns [expr {-2.0 + $corner_index * 1.0}]
        
        if {$wns < 0} {
            puts "   WNS: [format %.2f $wns] ns"
        } else {
            puts "   WNS: [format %.2f $wns] ns"
        }
        
        if {$tns < 0} {
            puts "   TNS: [format %.2f $tns] ns"
        } else {
            puts "   TNS: [format %.2f $tns] ns"
        }
        
        incr corner_index
    }

### Pattern 4: Cell Library Processing 📚

    set cell_types {
        {BUFX1 buffer 1}
        {BUFX2 buffer 2}
        {BUFX4 buffer 4}
        {INVX1 inverter 1}
        {INVX2 inverter 2}
        {NAND2X1 nand 1}
        {NOR2X1 nor 1}
    }
    
    puts "Cell Library Summary"
    puts ""
    
    array set type_count {buffer 0 inverter 0 nand 0 nor 0}
    
    foreach cell $cell_types {
        set name [lindex $cell 0]
        set type [lindex $cell 1]
        set drive [lindex $cell 2]
        
        incr type_count($type)
        
        puts "Cell: $name"
        puts "  Type: $type"
        puts "  Drive strength: ${drive}x"
        puts ""
    }
    
    puts "========================================"
    puts "Summary:"
    foreach type [array names type_count] {
        puts "  $type cells: $type_count($type)"
    }

---

## 10. Practice Exercises

### Exercise 1: Temperature Range Checker ✅

Write a script that checks if temperatures are within spec:

    set temperatures {-45 -20 0 25 50 85 100 130}
    set min_temp -40
    set max_temp 125
    
    puts "Temperature Compliance Check"
    puts "Specification: $min_temp C to $max_temp C"
    puts ""
    
    set pass_count 0
    set fail_count 0
    
    foreach temp $temperatures {
        if {$temp >= $min_temp && $temp <= $max_temp} {
            puts "$temp C PASS"
            incr pass_count
        } else {
            puts "$temp C FAIL"
            incr fail_count
        }
    }
    
    puts ""
    puts "Results: $pass_count passed, $fail_count failed"

Expected output:

    Temperature Compliance Check
    Specification: -40 C to 125 C
    
    -45 C FAIL
    -20 C PASS
    0 C PASS
    25 C PASS
    50 C PASS
    85 C PASS
    100 C PASS
    130 C FAIL
    
    Results: 6 passed, 2 failed

### Exercise 2: Clock Frequency Table 📊

Generate a table of clock frequencies and periods:

    puts "Clock Frequency vs Period"
    puts "========================================"
    puts [format "%-15s | %-10s | %-10s" "Frequency" "Period" "Category"]
    puts "========================================"
    
    for {set freq 50} {$freq <= 500} {incr freq 50} {
        set period [expr {1000.0 / $freq}]
        
        if {$freq < 100} {
            set category "Low"
        } elseif {$freq < 300} {
            set category "Medium"
        } else {
            set category "High"
        }
        
        puts [format "%-15s | %-10s | %-10s" \
              "$freq MHz" \
              "[format %.2f $period] ns" \
              $category]
    }

Expected output:

    Clock Frequency vs Period
    ========================================
    Frequency       | Period     | Category  
    ========================================
    50 MHz          | 20.00 ns   | Low       
    100 MHz         | 10.00 ns   | Medium    
    150 MHz         | 6.67 ns    | Medium    
    200 MHz         | 5.00 ns    | Medium    
    250 MHz         | 4.00 ns    | Medium    
    300 MHz         | 3.33 ns    | High      
    350 MHz         | 2.86 ns    | High      
    400 MHz         | 2.50 ns    | High      
    450 MHz         | 2.22 ns    | High      
    500 MHz         | 2.00 ns    | High

### Exercise 3: Timing Path Analyzer ⏱️

Analyze timing paths and find violations:

    set paths {
        {clk2q 0.5}
        {comb1 2.3}
        {comb2 1.8}
        {setup -0.3}
    }
    
    set clock_period 5.0
    set total_delay 0.0
    
    puts "Timing Path Analysis"
    puts "Clock Period: $clock_period ns"
    puts ""
    
    foreach segment $paths {
        set name [lindex $segment 0]
        set delay [lindex $segment 1]
        set total_delay [expr {$total_delay + $delay}]
        puts "  $name: [format %5.2f $delay] ns"
    }
    
    puts [string repeat "-" 25]
    puts "  Total: [format %5.2f $total_delay] ns"
    
    set slack [expr {$clock_period - $total_delay}]
    puts ""
    puts "Slack: [format %.2f $slack] ns"
    
    if {$slack >= 0} {
        puts "Timing constraint MET"
    } else {
        puts "Timing constraint VIOLATED"
        puts "Need to improve by [format %.2f [expr {abs($slack)}]] ns"
    }

Expected output:

    Timing Path Analysis
    Clock Period: 5.0 ns
    
      clk2q:  0.50 ns
      comb1:  2.30 ns
      comb2:  1.80 ns
      setup: -0.30 ns
    -------------------------
      Total:  4.30 ns
    
    Slack: 0.70 ns
    Timing constraint MET

### Exercise 4: Power Domain Iterator 🔋

Process multiple power domains:

    set domains {
        {CORE 1.8 always_on}
        {MEMORY 1.2 switchable}
        {IO 3.3 always_on}
        {ANALOG 2.5 always_on}
    }
    
    puts "Power Domain Configuration"
    puts ""
    
    set total_domains 0
    set switchable_count 0
    
    foreach domain $domains {
        set name [lindex $domain 0]
        set voltage [lindex $domain 1]
        set mode [lindex $domain 2]
        
        incr total_domains
        
        puts "Domain: $name"
        puts "  Voltage: $voltage V"
        puts "  Mode: $mode"
        
        if {$mode eq "switchable"} {
            puts "  Power gating enabled"
            incr switchable_count
        } else {
            puts "  Always powered"
        }
        puts ""
    }
    
    puts "========================================"
    puts "Total domains: $total_domains"
    puts "Switchable: $switchable_count"
    puts "Always-on: [expr {$total_domains - $switchable_count}]"

Expected output:

    Power Domain Configuration
    
    Domain: CORE
      Voltage: 1.8 V
      Mode: always_on
      Always powered
    
    Domain: MEMORY
      Voltage: 1.2 V
      Mode: switchable
      Power gating enabled
    
    Domain: IO
      Voltage: 3.3 V
      Mode: always_on
      Always powered
    
    Domain: ANALOG
      Voltage: 2.5 V
      Mode: always_on
      Always powered
    
    ========================================
    Total domains: 4
    Switchable: 1
    Always-on: 3

### Exercise 5: Nested Loop Grid 🎯

Create a coordinate grid checker:

    set rows 5
    set cols 5
    set violations {{2 3} {4 1} {3 3}}
    
    puts "Layout Grid Checker"
    puts "========================================"
    
    for {set r 0} {$r < $rows} {incr r} {
        for {set c 0} {$c < $cols} {incr c} {
            set has_violation 0
            
            foreach viol $violations {
                set viol_r [lindex $viol 0]
                set viol_c [lindex $viol 1]
                
                if {$r == $viol_r && $c == $viol_c} {
                    set has_violation 1
                    break
                }
            }
            
            if {$has_violation} {
                puts -nonewline "X "
            } else {
                puts -nonewline "O "
            }
        }
        puts ""
    }
    
    puts "========================================"
    puts "Legend: O = Clean, X = Violation"

Expected output:

    Layout Grid Checker
    ========================================
    O O O O O 
    O O O O O 
    O O O X O 
    O O O X O 
    O X O O O 
    ========================================
    Legend: O = Clean, X = Violation

---

## Summary Cheat Sheet

Control Structure: If statement
Syntax: if {condition} {code}
Example: if {dollar sign x > 10} {puts "big"}

Control Structure: If-else
Syntax: if {cond} {code1} else {code2}
Example: if {dollar sign x > 0} {puts "pos"} else {puts "neg"}

Control Structure: Switch
Syntax: switch dollar sign var {val1 {code1} val2 {code2}}
Example: switch dollar sign mode {fast {puts "F"} slow {puts "S"}}

Control Structure: While loop
Syntax: while {condition} {code}
Example: while {dollar sign i < 5} {puts dollar sign i; incr i}

Control Structure: For loop
Syntax: for {init} {cond} {incr} {code}
Example: for {set i 0} {dollar sign i<5} {incr i} {puts dollar sign i}

Control Structure: Foreach loop
Syntax: foreach var dollar sign list {code}
Example: foreach x dollar sign lst {puts dollar sign x}

Control Structure: Break
Syntax: break
Example: if {dollar sign error} {break}

Control Structure: Continue
Syntax: continue
Example: if {dollar sign skip} {continue}

---

## What's Next? 🚀

In Lesson 03 you will learn:

- Procedure definition (proc)
- Function parameters and return values
- Variable scope (local vs global)
- Default parameters
- Variable number of arguments
- Recursive procedures
- Lambda functions

Ready to proceed?

Complete the exercises above first, then move to:

    03_procedures_functions.md

---

Good luck with your practice! 💪

