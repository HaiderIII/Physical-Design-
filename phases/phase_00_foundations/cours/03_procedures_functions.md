# Lesson 03: TCL Procedures and Functions

## Table of Contents
1. Introduction to Procedures
2. Defining Procedures with proc
3. Parameters and Arguments
4. Return Values
5. Variable Scope (local vs global)
6. Default Parameters
7. Variable Number of Arguments
8. Recursive Procedures
9. Best Practices
10. Common Patterns in Physical Design
11. Practice Exercises

---

## 1. Introduction to Procedures

### What is a Procedure? 🎯

A procedure is a **reusable block of code** with a name.

Benefits:
- Code reusability
- Better organization
- Easier debugging
- Abstraction of complex operations

### Syntax Overview

Basic structure:

    proc procedure_name {arguments} {
        procedure_body
        return result
    }

Simple example:

    proc greet {name} {
        puts "Hello, $name"
    }
    
    greet "Alice"

Output:

    Hello, Alice

---

## 2. Defining Procedures with proc

### Basic Procedure Definition ✅

Syntax:

    proc name {} {
        body
    }

Example: Procedure without parameters

    proc show_banner {} {
        puts "================================"
        puts "    TIMING ANALYSIS TOOL"
        puts "================================"
    }
    
    show_banner

Output:

    ================================
        TIMING ANALYSIS TOOL
    ================================

### Procedure with One Parameter 📝

    proc square {x} {
        return [expr {$x * $x}]
    }
    
    set result [square 5]
    puts "5 squared = $result"

Output:

    5 squared = 25

### Procedure with Multiple Parameters 📊

    proc calculate_area {width height} {
        set area [expr {$width * $height}]
        return $area
    }
    
    set chip_area [calculate_area 100 200]
    puts "Chip area: $chip_area um2"

Output:

    Chip area: 20000 um2

---

## 3. Parameters and Arguments

### Positional Parameters 🎯

Parameters are matched by position:

    proc divide {numerator denominator} {
        return [expr {$numerator / $denominator}]
    }
    
    puts [divide 10 2]
    puts [divide 2 10]

Output:

    5
    0

⚠️ Order matters!

### Required vs Optional Parameters

Required: Must be provided

    proc compute {x y} {
        return [expr {$x + $y}]
    }
    
    compute 5 3

Optional: Have default values (see section 6)

---

## 4. Return Values

### Explicit Return 📤

Use `return` to send value back:

    proc add {a b} {
        set sum [expr {$a + $b}]
        return $sum
    }
    
    set result [add 10 20]
    puts $result

Output:

    30

### Implicit Return

Last executed command is returned:

    proc multiply {a b} {
        expr {$a * $b}
    }
    
    puts [multiply 4 5]

Output:

    20

⚠️ Explicit `return` is clearer and preferred!

### Early Return 🚪

Exit procedure before end:

    proc check_voltage {vdd} {
        if {$vdd < 0.9} {
            return "ERROR: Voltage too low"
        }
        if {$vdd > 1.9} {
            return "ERROR: Voltage too high"
        }
        return "OK"
    }
    
    puts [check_voltage 0.5]
    puts [check_voltage 1.8]
    puts [check_voltage 2.5]

Output:

    ERROR: Voltage too low
    OK
    ERROR: Voltage too high

### Return Multiple Values 📦

Use list:

    proc get_min_max {numbers} {
        set min [lindex $numbers 0]
        set max [lindex $numbers 0]
        
        foreach num $numbers {
            if {$num < $min} { set min $num }
            if {$num > $max} { set max $num }
        }
        
        return [list $min $max]
    }
    
    set values {5 2 9 1 7}
    set result [get_min_max $values]
    
    puts "Min: [lindex $result 0]"
    puts "Max: [lindex $result 1]"

Output:

    Min: 1
    Max: 9

Alternative with lassign:

    lassign [get_min_max $values] minimum maximum
    puts "Range: $minimum to $maximum"

Output:

    Range: 1 to 9

---

## 5. Variable Scope (local vs global)

### Local Variables 🏠

By default, variables inside procedures are LOCAL:

    proc test_local {} {
        set x 10
        puts "Inside proc: x = $x"
    }
    
    set x 5
    puts "Before proc: x = $x"
    test_local
    puts "After proc: x = $x"

Output:

    Before proc: x = 5
    Inside proc: x = 10
    After proc: x = 5

The `$x` inside procedure is DIFFERENT from outside!

### Global Variables 🌍

Use `global` keyword to access outside variables:

    proc increment_counter {} {
        global counter
        incr counter
    }
    
    set counter 0
    puts "Counter: $counter"
    increment_counter
    puts "Counter: $counter"
    increment_counter
    puts "Counter: $counter"

Output:

    Counter: 0
    Counter: 1
    Counter: 2

### Multiple Global Variables

    proc update_stats {} {
        global total_cells violated_paths
        incr total_cells 100
        incr violated_paths 5
    }
    
    set total_cells 0
    set violated_paths 0
    
    update_stats
    puts "Cells: $total_cells, Violations: $violated_paths"

Output:

    Cells: 100, Violations: 5

### Upvar for Parent Scope 🔗

Access caller's variables:

    proc modify_list {list_name} {
        upvar $list_name local_list
        lappend local_list "NEW"
    }
    
    set my_list {A B C}
    puts "Before: $my_list"
    modify_list my_list
    puts "After: $my_list"

Output:

    Before: A B C
    After: A B C NEW

⚠️ Advanced feature, use carefully!

---

## 6. Default Parameters

### Syntax for Default Values 🎛️

    proc name {required_param {optional_param default_value}} {
        body
    }

Example:

    proc greet {name {title "Mr."}} {
        puts "Hello, $title $name"
    }
    
    greet "Smith"
    greet "Smith" "Dr."

Output:

    Hello, Mr. Smith
    Hello, Dr. Smith

### Multiple Default Parameters

    proc create_report {design {format "text"} {verbose 0}} {
        puts "Design: $design"
        puts "Format: $format"
        puts "Verbose: $verbose"
    }
    
    create_report "chip1"
    create_report "chip2" "html"
    create_report "chip3" "pdf" 1

Output:

    Design: chip1
    Format: text
    Verbose: 0
    Design: chip2
    Format: html
    Verbose: 0
    Design: chip3
    Format: pdf
    Verbose: 1

### Physical Design Example 🔧

    proc analyze_timing {clock_period {corner "typical"} {max_paths 10}} {
        puts "Analyzing timing..."
        puts "  Clock period: $clock_period ns"
        puts "  Corner: $corner"
        puts "  Max paths to report: $max_paths"
    }
    
    analyze_timing 10.0
    analyze_timing 10.0 "slow"
    analyze_timing 10.0 "fast" 50

Output:

    Analyzing timing...
      Clock period: 10.0 ns
      Corner: typical
      Max paths to report: 10
    Analyzing timing...
      Clock period: 10.0 ns
      Corner: slow
      Max paths to report: 10
    Analyzing timing...
      Clock period: 10.0 ns
      Corner: fast
      Max paths to report: 50

---

## 7. Variable Number of Arguments

### Using args 📋

Special parameter `args` captures remaining arguments:

    proc sum {args} {
        set total 0
        foreach num $args {
            set total [expr {$total + $num}]
        }
        return $total
    }
    
    puts [sum 1 2 3]
    puts [sum 10 20 30 40 50]
    puts [sum 5]

Output:

    6
    150
    5

### Mixing Fixed and Variable Arguments

    proc report_violations {design args} {
        puts "Design: $design"
        puts "Violations found: [llength $args]"
        
        set count 1
        foreach violation $args {
            puts "  $count. $violation"
            incr count
        }
    }
    
    report_violations "cpu_core" "Setup at FF1" "Hold at FF2" "DRC in block3"

Output:

    Design: cpu_core
    Violations found: 3
      1. Setup at FF1
      2. Hold at FF2
      3. DRC in block3

### Checking Argument Count

    proc configure {args} {
        if {[llength $args] == 0} {
            puts "ERROR: At least one argument required"
            return
        }
        
        puts "Configuring with [llength $args] options"
        foreach opt $args {
            puts "  - $opt"
        }
    }
    
    configure
    configure "opt1" "opt2" "opt3"

Output:

    ERROR: At least one argument required
    Configuring with 3 options
      - opt1
      - opt2
      - opt3

---

## 8. Recursive Procedures

### What is Recursion? 🔄

A procedure that calls itself.

Required elements:
1. Base case (stop condition)
2. Recursive case (call itself)

### Simple Recursion: Factorial

    proc factorial {n} {
        if {$n <= 1} {
            return 1
        } else {
            return [expr {$n * [factorial [expr {$n - 1}]]}]
        }
    }
    
    puts "5! = [factorial 5]"
    puts "10! = [factorial 10]"

Output:

    5! = 120
    10! = 3628800

Execution trace for factorial 4:

    factorial(4)
      = 4 * factorial(3)
      = 4 * (3 * factorial(2))
      = 4 * (3 * (2 * factorial(1)))
      = 4 * (3 * (2 * 1))
      = 4 * (3 * 2)
      = 4 * 6
      = 24

### Recursion: Fibonacci

    proc fibonacci {n} {
        if {$n <= 1} {
            return $n
        } else {
            return [expr {[fibonacci [expr {$n-1}]] + [fibonacci [expr {$n-2}]]}]
        }
    }
    
    for {set i 0} {$i <= 10} {incr i} {
        puts "fib($i) = [fibonacci $i]"
    }

Output:

    fib(0) = 0
    fib(1) = 1
    fib(2) = 1
    fib(3) = 2
    fib(4) = 3
    fib(5) = 5
    fib(6) = 8
    fib(7) = 13
    fib(8) = 21
    fib(9) = 34
    fib(10) = 55

### Physical Design Example: Hierarchy Traversal 🌲

    proc count_cells {hierarchy_level max_level} {
        if {$hierarchy_level > $max_level} {
            return 0
        }
        
        set cell_count [expr {10 * $hierarchy_level}]
        set child_count [count_cells [expr {$hierarchy_level + 1}] $max_level]
        
        return [expr {$cell_count + $child_count}]
    }
    
    set total [count_cells 1 4]
    puts "Total cells in hierarchy: $total"

Output:

    Total cells in hierarchy: 100

⚠️ Be careful with recursion: can cause stack overflow!

---

## 9. Best Practices

### 1. Clear Naming 📝

Good names:

    proc calculate_slack {arrival required} { ... }
    proc report_timing_violations {} { ... }
    proc optimize_cell {cell_name} { ... }

Bad names:

    proc calc {a b} { ... }
    proc do_stuff {} { ... }
    proc x {y} { ... }

### 2. Single Responsibility 🎯

Each procedure should do ONE thing:

Good:

    proc read_liberty_file {filename} { ... }
    proc parse_liberty_data {data} { ... }
    proc extract_cell_delays {cell} { ... }

Bad:

    proc do_everything {file} {
        set data [read_file $file]
        parse_data $data
        compute_delays
        generate_report
        send_email
    }

### 3. Error Handling ⚠️

Always check inputs:

    proc divide_safe {a b} {
        if {$b == 0} {
            puts "ERROR: Division by zero"
            return -1
        }
        return [expr {$a / $b}]
    }

### 4. Documentation 📚

Add comments:

    proc calculate_setup_slack {data_arrival clock_arrival setup_time} {
        # Calculate setup slack
        # Formula: slack = clock_arrival - data_arrival - setup_time
        # Positive slack = OK, Negative slack = VIOLATION
        
        set slack [expr {$clock_arrival - $data_arrival - $setup_time}]
        return $slack
    }

### 5. Consistent Return Values 🔄

Always return same type:

Good:

    proc find_max {numbers} {
        if {[llength $numbers] == 0} {
            return 0
        }
        set max [lindex $numbers 0]
        foreach num $numbers {
            if {$num > $max} { set max $num }
        }
        return $max
    }

Bad:

    proc find_max {numbers} {
        if {[llength $numbers] == 0} {
            return "ERROR"
        }
        return [calculate $numbers]
    }

---

## 10. Common Patterns in Physical Design

### Pattern 1: Report Generator 📊

    proc generate_timing_report {paths} {
        puts "\n========================================="
        puts "          TIMING REPORT"
        puts "========================================="
        puts "Total paths analyzed: [llength $paths]\n"
        
        set violated 0
        foreach path $paths {
            lassign $path name slack
            if {$slack < 0} {
                puts [format "VIOLATED: %-20s %6.2f ns" $name $slack]
                incr violated
            }
        }
        
        puts "\n========================================="
        puts "Total violations: $violated"
        puts "========================================="
    }
    
    set timing_paths {
        {"clk_to_out1" 0.5}
        {"clk_to_out2" -0.2}
        {"data_path" 1.3}
        {"control_path" -0.1}
    }
    
    generate_timing_report $timing_paths

Output:

    =========================================
              TIMING REPORT
    =========================================
    Total paths analyzed: 4
    
    VIOLATED: clk_to_out2          -0.20 ns
    VIOLATED: control_path         -0.10 ns
    
    =========================================
    Total violations: 2
    =========================================

### Pattern 2: Configuration Manager 🎛️

    proc set_corner_config {corner} {
        global voltage temperature process
        
        switch $corner {
            "fast" {
                set voltage 1.95
                set temperature -40
                set process "ff"
            }
            "typical" {
                set voltage 1.80
                set temperature 25
                set process "tt"
            }
            "slow" {
                set voltage 1.62
                set temperature 125
                set process "ss"
            }
            default {
                puts "ERROR: Unknown corner $corner"
                return 0
            }
        }
        
        puts "Corner: $corner"
        puts "  Voltage: $voltage V"
        puts "  Temperature: $temperature C"
        puts "  Process: $process"
        return 1
    }
    
    set_corner_config "slow"

Output:

    Corner: slow
      Voltage: 1.62 V
      Temperature: 125 C
      Process: ss

### Pattern 3: Hierarchy Walker 🌲

    proc walk_hierarchy {module_name level} {
        set indent [string repeat "  " $level]
        puts "$indent$module_name"
        
        if {[has_children $module_name]} {
            set children [get_children $module_name]
            foreach child $children {
                walk_hierarchy $child [expr {$level + 1}]
            }
        }
    }
    
    proc has_children {module} {
        return [expr {rand() > 0.5}]
    }
    
    proc get_children {module} {
        return [list "${module}_sub1" "${module}_sub2"]
    }
    
    walk_hierarchy "TOP" 0

Possible output:

    TOP
      TOP_sub1
        TOP_sub1_sub1
        TOP_sub1_sub2
      TOP_sub2

### Pattern 4: Statistics Collector 📈

    proc analyze_cell_distribution {cells} {
        array set stats {}
        
        foreach cell $cells {
            lassign $cell type
            if {[info exists stats($type)]} {
                incr stats($type)
            } else {
                set stats($type) 1
            }
        }
        
        puts "\nCell Distribution:"
        puts "-----------------------------------"
        foreach type [lsort [array names stats]] {
            puts [format "%-15s : %4d" $type $stats($type)]
        }
        puts "-----------------------------------"
        
        set total 0
        foreach type [array names stats] {
            set total [expr {$total + $stats($type)}]
        }
        puts [format "%-15s : %4d" "TOTAL" $total]
    }
    
    set cell_list {
        {NAND2 inst1}
        {NOR2 inst2}
        {NAND2 inst3}
        {INV inst4}
        {NAND2 inst5}
        {NOR2 inst6}
        {INV inst7}
        {INV inst8}
    }
    
    analyze_cell_distribution $cell_list

Output:

    Cell Distribution:
    -----------------------------------
    INV             :    3
    NAND2           :    3
    NOR2            :    2
    -----------------------------------
    TOTAL           :    8

---

## 11. Practice Exercises

### Exercise 1: Temperature Converter 🌡️

Create procedure to convert Celsius to Fahrenheit:

Formula: F = C * 9/5 + 32

    proc celsius_to_fahrenheit {celsius} {
        # TODO: Your code here
    }
    
    puts "[celsius_to_fahrenheit 0] F"
    puts "[celsius_to_fahrenheit 25] F"
    puts "[celsius_to_fahrenheit 100] F"

Expected output:

    32.0 F
    77.0 F
    212.0 F

### Exercise 2: List Statistics 📊

Create procedure that returns min, max, average:

    proc get_statistics {numbers} {
        # TODO: Your code here
        # Return list: {min max avg}
    }
    
    set values {5 2 9 1 7 3 8}
    lassign [get_statistics $values] min max avg
    puts "Min: $min, Max: $max, Avg: $avg"

Expected output:

    Min: 1, Max: 9, Avg: 5.0

### Exercise 3: Power of Two Checker ⚡

Create procedure to check if number is power of 2:

    proc is_power_of_two {n} {
        # TODO: Your code here
        # Return 1 if true, 0 if false
    }
    
    for {set i 1} {$i <= 20} {incr i} {
        if {[is_power_of_two $i]} {
            puts "$i is power of 2"
        }
    }

Expected output:

    1 is power of 2
    2 is power of 2
    4 is power of 2
    8 is power of 2
    16 is power of 2

Hint: Powers of 2: 1, 2, 4, 8, 16, 32, 64...

### Exercise 4: Path Delay Calculator 🕐

Create procedure to calculate total path delay:

    proc calculate_path_delay {cell_delays wire_delays} {
        # TODO: Your code here
        # Return total delay
    }
    
    set cells {0.5 0.3 0.4 0.6}
    set wires {0.1 0.2 0.1 0.3}
    
    set total [calculate_path_delay $cells $wires]
    puts "Total path delay: $total ns"

Expected output:

    Total path delay: 2.5 ns

### Exercise 5: Recursive Sum 🔄

Create recursive procedure to sum list:

    proc recursive_sum {numbers} {
        # TODO: Your code here
        # Base case: empty list = 0
        # Recursive: first + sum(rest)
    }
    
    puts [recursive_sum {1 2 3 4 5}]
    puts [recursive_sum {10 20 30}]
    puts [recursive_sum {}]

Expected output:

    15
    60
    0

Hint: Use `lindex` to get first element, `lrange` for rest

### Exercise 6: Violation Reporter 🚨

Create procedure that generates violation report:

    proc report_violations {paths threshold} {
        # TODO: Your code here
        # Print violations where slack < threshold
        # Return count of violations
    }
    
    set timing_data {
        {"path1" 0.5}
        {"path2" -0.2}
        {"path3" 1.0}
        {"path4" -0.5}
        {"path5" 0.1}
    }
    
    set count [report_violations $timing_data 0]
    puts "\nTotal violations: $count"

Expected output:

    VIOLATION: path2, slack = -0.20 ns
    VIOLATION: path4, slack = -0.50 ns
    
    Total violations: 2

### Exercise 7: Counter with Persistence 🔢

Create global counter that persists between calls:

    proc increment_counter {} {
        # TODO: Your code here
        # Use global variable
        # Initialize to 0 on first call
        # Return current count
    }
    
    proc reset_counter {} {
        # TODO: Your code here
    }
    
    puts [increment_counter]
    puts [increment_counter]
    puts [increment_counter]
    reset_counter
    puts [increment_counter]

Expected output:

    1
    2
    3
    1

### Exercise 8: Parameter Validator ✅

Create procedure with default parameters and validation:

    proc create_clock {name period {duty_cycle 0.5} {edge "rising"}} {
        # TODO: Your code here
        # Validate: period > 0
        # Validate: 0 < duty_cycle < 1
        # Validate: edge is "rising" or "falling"
        # Print configuration if valid
        # Return 1 if valid, 0 if invalid
    }
    
    create_clock "clk1" 10.0
    create_clock "clk2" 5.0 0.6
    create_clock "clk3" 2.5 0.5 "falling"
    create_clock "clk4" -5.0
    create_clock "clk5" 10.0 1.5

Expected output:

    Clock clk1: period=10.0ns, duty=0.5, edge=rising
    Clock clk2: period=5.0ns, duty=0.6, edge=rising
    Clock clk3: period=2.5ns, duty=0.5, edge=falling
    ERROR: Invalid period -5.0
    ERROR: Invalid duty cycle 1.5

---

## Summary Cheat Sheet

Topic: Define procedure
Syntax: proc name {args} {body}
Example: proc add {a b} {expr {dollar sign a + dollar sign b}}

Topic: Call procedure
Syntax: name arg1 arg2
Example: set x [add 5 3]

Topic: Return value
Syntax: return value
Example: return [expr {dollar sign x * 2}]

Topic: Default parameter
Syntax: proc name {req {opt default}} {body}
Example: proc greet {name {title "Mr"}} {puts "Hi dollar sign title dollar sign name"}

Topic: Variable args
Syntax: proc name {args} {body}
Example: proc sum {args} {expr {[join dollar sign args +]}}

Topic: Global variable
Syntax: global varname
Example: global counter; incr counter

Topic: Upvar
Syntax: upvar parent_var local_var
Example: upvar dollar sign list_name lst

Topic: Recursion
Syntax: proc name {n} {if base return; name [expr ...]}
Example: proc fact {n} {if {dollar sign n<=1} {return 1}; ...}

---

## What's Next? 🚀

In Lesson 04 you will learn:

- String manipulation (length, index, range)
- String search and replace
- String formatting
- List operations (create, append, insert)
- List searching and sorting
- List iteration techniques
- Nested lists
- Converting between strings and lists

Ready to proceed?

Complete the exercises above first, then move to:

    04_strings_lists.md

---

Good luck with your practice! 💪

