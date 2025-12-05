# Lesson 04: Strings and Lists in TCL

## Table of Contents
1. String Basics
2. String Length and Indexing
3. String Extraction (range)
4. String Search Operations
5. String Replacement
6. String Formatting
7. List Basics
8. List Creation and Access
9. List Manipulation (append, insert, replace)
10. List Searching and Sorting
11. List Iteration Techniques
12. Nested Lists
13. Converting Strings ↔ Lists
14. Physical Design Use Cases
15. Practice Exercises

---

## 1. String Basics

### What is a String? 📝

In TCL, **everything is a string** by default!

Examples:

    set name "Alice"
    set number "42"
    set path "/home/user/design.v"

Even numbers are internally strings:

    set x 10
    set y "10"
    # Both are equivalent in TCL!

### String Representation

Single word (no spaces):

    set cell inverter

With spaces (use quotes):

    set message "Hello World"

With special characters (use braces):

    set script {
        puts "Multi-line"
        puts "string"
    }

---

## 2. String Length and Indexing

### String Length Command 📏

Syntax:

    string length string

Example:

    set text "ASIC Design"
    set len [string length $text]
    puts "Length: $len"

Output:

    Length: 11

### String Indexing 🔢

Get character at position (0-based):

    string index string position

Example:

    set word "Timing"
    puts [string index $word 0]
    puts [string index $word 3]
    puts [string index $word end]

Output:

    T
    i
    g

Special indices:
- `0` = first character
- `end` = last character
- `end-1` = second to last

Example with end:

    set pin "CLK_input"
    puts [string index $pin end]
    puts [string index $pin end-2]

Output:

    t
    p

---

## 3. String Extraction (range)

### Extract Substring 📍

Syntax:

    string range string first last

Example:

    set filename "design_top_v1.v"
    puts [string range $filename 0 5]
    puts [string range $filename 7 9]
    puts [string range $filename end-1 end]

Output:

    design
    top
    .v

### Using end keyword

    set path "/usr/local/bin/opensta"
    puts [string range $path 0 3]
    puts [string range $path end-7 end]

Output:

    /usr
    opensta

### Extract file extension

    set file "netlist.v"
    set ext [string range $file end-1 end]
    puts "Extension: $ext"

Output:

    Extension: .v

---

## 4. String Search Operations

### Find Substring Position ��

Syntax:

    string first substring string ?startIndex?

Returns: index of first occurrence (-1 if not found)

Example:

    set text "clock_domain_crossing"
    set pos [string first "domain" $text]
    puts "Position: $pos"

Output:

    Position: 6

### Search from specific position

    set path "/home/user/designs/chip1/rtl/top.v"
    set pos1 [string first "/" $path 0]
    set pos2 [string first "/" $path [expr {$pos1 + 1}]]
    puts "First /: $pos1"
    puts "Second /: $pos2"

Output:

    First /: 0
    Second /: 5

### Check if string contains substring ✅

    set filename "clock_tree.rpt"
    if {[string first "clock" $filename] != -1} {
        puts "This is a clock-related file"
    }

Output:

    This is a clock-related file

### Find last occurrence

Syntax:

    string last substring string

Example:

    set path "/home/user/project/src/design.v"
    set last_slash [string last "/" $path]
    set filename [string range $path [expr {$last_slash + 1}] end]
    puts "Filename: $filename"

Output:

    Filename: design.v

---

## 5. String Replacement

### Replace Substring 🔄

Syntax:

    string map {old1 new1 old2 new2 ...} string

Example:

    set text "clock frequency is 100MHz"
    set new_text [string map {"100MHz" "200MHz"} $text]
    puts $new_text

Output:

    clock frequency is 200MHz

### Multiple replacements

    set code "wire a; wire b; wire c;"
    set new_code [string map {"wire" "reg"} $code]
    puts $new_code

Output:

    reg a; reg b; reg c;

### Case-sensitive replacement

    set signal "CLK clk Clk"
    set result [string map {"clk" "clock"} $signal]
    puts $result

Output:

    CLK clock Clk

Only lowercase "clk" was replaced!

---

## 6. String Formatting

### String Comparison 📊

Equal:

    string equal string1 string2

Example:

    set pin1 "CLK"
    set pin2 "CLK"
    if {[string equal $pin1 $pin2]} {
        puts "Pins match"
    }

Output:

    Pins match

### Case-insensitive comparison

    string equal -nocase string1 string2

Example:

    set s1 "Clock"
    set s2 "CLOCK"
    if {[string equal -nocase $s1 $s2]} {
        puts "Same clock (ignoring case)"
    }

Output:

    Same clock (ignoring case)

### String to Upper/Lower Case 🔤

    string toupper string
    string tolower string

Example:

    set pin "clk_input"
    puts [string toupper $pin]
    puts [string tolower "VDD_CORE"]

Output:

    CLK_INPUT
    vdd_core

### Trim Whitespace ✂️

    string trim string ?chars?

Example:

    set text "  clock  "
    set clean [string trim $text]
    puts "[$clean]"

Output:

    [clock]

### Trim specific characters

    set path "/home/user/"
    set clean [string trim $path "/"]
    puts $clean

Output:

    home/user

---

## 7. List Basics

### What is a List? 📋

A list is an **ordered collection** of elements.

Create a list:

    set colors {red green blue}
    set numbers {1 2 3 4 5}
    set mixed {10 "hello" 3.14}

### Lists vs Strings

String with spaces:

    set str "a b c"

Convert to list:

    set lst [list a b c]
    # or
    set lst {a b c}

Both are equivalent!

---

## 8. List Creation and Access

### Create List with list command 🛠️

Syntax:

    list element1 element2 ...

Example:

    set pins [list CLK RST DATA]
    puts $pins

Output:

    CLK RST DATA

### Create empty list

    set empty_list {}
    set also_empty [list]

### List Length 📏

    llength list

Example:

    set gates {AND OR NOT NAND}
    puts "Number of gates: [llength $gates]"

Output:

    Number of gates: 4

### Access List Element 🎯

Syntax:

    lindex list index

Example:

    set ports {clk rst data_in data_out}
    puts [lindex $ports 0]
    puts [lindex $ports 2]
    puts [lindex $ports end]

Output:

    clk
    data_in
    data_out

---

## 9. List Manipulation

### Append to List ➕

Syntax:

    lappend listVar element1 element2 ...

⚠️ **Important**: `lappend` modifies the variable directly!

Example:

    set cells {INV BUF}
    lappend cells AND OR
    puts $cells

Output:

    INV BUF AND OR

### Insert into List 📥

Syntax:

    linsert list index element1 element2 ...

Example:

    set signals {clk data}
    set new_list [linsert $signals 1 rst]
    puts $new_list

Output:

    clk rst data

### Replace List Elements 🔄

Syntax:

    lreplace list first last ?element ...?

Example:

    set pins {A B C D}
    set new_pins [lreplace $pins 1 2 X Y Z]
    puts $new_pins

Output:

    A X Y Z D

Replace with nothing (delete):

    set list {1 2 3 4 5}
    set shorter [lreplace $list 2 3]
    puts $shorter

Output:

    1 2 5

---

## 10. List Searching and Sorting

### Search in List 🔍

Syntax:

    lsearch ?options? list pattern

Example:

    set cells {AND OR NOT NAND NOR}
    set pos [lsearch $cells "NOT"]
    puts "NOT is at position: $pos"

Output:

    NOT is at position: 2

### Search options

Exact match:

    lsearch -exact $list "value"

Glob pattern:

    set files {test.v design.v sim.tcl}
    set v_files [lsearch -all -inline $files "*.v"]
    puts $v_files

Output:

    test.v design.v

### Check if element exists ✅

    set pins {CLK RST DATA}
    if {[lsearch $pins "CLK"] != -1} {
        puts "CLK pin exists"
    }

Output:

    CLK pin exists

### Sort List 📶

Syntax:

    lsort ?options? list

Example:

    set numbers {5 2 8 1 9}
    puts [lsort -integer $numbers]

Output:

    1 2 5 8 9

Alphabetical sort:

    set names {charlie alice bob}
    puts [lsort $names]

Output:

    alice bob charlie

Reverse sort:

    set values {10 5 20 15}
    puts [lsort -integer -decreasing $values]

Output:

    20 15 10 5

---

## 11. List Iteration Techniques

### Foreach Loop with Lists 🔁

Basic foreach:

    set pins {CLK RST EN}
    foreach pin $pins {
        puts "Processing pin: $pin"
    }

Output:

    Processing pin: CLK
    Processing pin: RST
    Processing pin: EN

### Multiple lists simultaneously

    set inputs {A B C}
    set outputs {X Y Z}
    foreach in $inputs out $outputs {
        puts "$in -> $out"
    }

Output:

    A -> X
    B -> Y
    C -> Z

### Iterate with index

Using lindex in for loop:

    set cells {INV AND OR}
    set len [llength $cells]
    for {set i 0} {$i < $len} {incr i} {
        set cell [lindex $cells $i]
        puts "Cell $i: $cell"
    }

Output:

    Cell 0: INV
    Cell 1: AND
    Cell 2: OR

---

## 12. Nested Lists

### Create Nested List 📦

    set matrix {
        {1 2 3}
        {4 5 6}
        {7 8 9}
    }

### Access Nested Elements

    set row0 [lindex $matrix 0]
    puts "Row 0: $row0"
    
    set element [lindex [lindex $matrix 1] 2]
    puts "Element [1][2]: $element"

Output:

    Row 0: 1 2 3
    Element [1][2]: 6

### Timing Arc Example 📊

    set timing_arcs {
        {input_pin output_pin 0.5}
        {clk q 0.3}
        {d q 1.2}
    }
    
    foreach arc $timing_arcs {
        set from [lindex $arc 0]
        set to [lindex $arc 1]
        set delay [lindex $arc 2]
        puts "Arc: $from -> $to, delay = $delay ns"
    }

Output:

    Arc: input_pin -> output_pin, delay = 0.5 ns
    Arc: clk -> q, delay = 0.3 ns
    Arc: d -> q, delay = 1.2 ns

---

## 13. Converting Strings ↔ Lists

### Split String to List ✂️

Syntax:

    split string ?splitChars?

Example:

    set path "/home/user/designs/chip"
    set parts [split $path "/"]
    puts $parts

Output:

    {} home user designs chip

⚠️ First element is empty because path starts with /

### Split by comma

    set csv "100,200,300,400"
    set values [split $csv ","]
    foreach val $values {
        puts "Value: $val"
    }

Output:

    Value: 100
    Value: 200
    Value: 300
    Value: 400

### Join List to String 🔗

Syntax:

    join list ?joinString?

Example:

    set words {Hello TCL World}
    set sentence [join $words " "]
    puts $sentence

Output:

    Hello TCL World

Join with custom separator:

    set pins {CLK RST DATA}
    set verilog [join $pins ", "]
    puts "input $verilog;"

Output:

    input CLK, RST, DATA;

---

## 14. Physical Design Use Cases

### Example 1: Parse Pin Names 📌

Extract bus index from pin name:

    proc get_bus_index {pin_name} {
        set start [string first "\[" $pin_name]
        if {$start == -1} {
            return -1
        }
        set end [string first "\]" $pin_name]
        set index [string range $pin_name [expr {$start + 1}] [expr {$end - 1}]]
        return $index
    }
    
    puts [get_bus_index "data\[5\]"]
    puts [get_bus_index "clk"]

Output:

    5
    -1

### Example 2: Parse Liberty File Path 📂

    proc extract_lib_name {path} {
        set parts [split $path "/"]
        set filename [lindex $parts end]
        set name [string range $filename 0 end-4]
        return $name
    }
    
    set lib_path "/libs/process/fast.lib"
    puts [extract_lib_name $lib_path]

Output:

    fast

### Example 3: Build Port List 🔌

    proc create_port_list {prefix count} {
        set ports {}
        for {set i 0} {$i < $count} {incr i} {
            lappend ports "${prefix}\[${i}\]"
        }
        return $ports
    }
    
    set data_ports [create_port_list "data" 8]
    puts $data_ports

Output:

    data[0] data[1] data[2] data[3] data[4] data[5] data[6] data[7]

### Example 4: Filter Nets by Pattern 🔍

    proc filter_nets {net_list pattern} {
        set result {}
        foreach net $net_list {
            if {[string match $pattern $net]} {
                lappend result $net
            }
        }
        return $result
    }
    
    set all_nets {clk_main clk_cpu clk_mem data_bus ctrl_en}
    set clk_nets [filter_nets $all_nets "clk_*"]
    puts "Clock nets: $clk_nets"

Output:

    Clock nets: clk_main clk_cpu clk_mem

---

## 15. Practice Exercises

### Exercise 1: String Statistics 📊

Write procedure to analyze a string:

    proc string_stats {text} {
        # TODO: Calculate and print:
        # - Total length
        # - Number of words (split by space)
        # - Number of uppercase letters
        # - Number of lowercase letters
        # - Number of digits
    }
    
    string_stats "Clock frequency: 100MHz"

Expected output:

    Length: 23
    Words: 3
    Uppercase: 3
    Lowercase: 17
    Digits: 3

Hint: Use string length, split, string is upper, string is lower, string is digit

### Exercise 2: Path Parser 📁

Parse file path into components:

    proc parse_path {path} {
        # TODO: Extract and return dict with:
        # - directory
        # - filename
        # - extension
    }
    
    array set info [parse_path "/home/user/design.v"]
    puts "Dir: $info(directory)"
    puts "File: $info(filename)"
    puts "Ext: $info(extension)"

Expected output:

    Dir: /home/user
    File: design
    Ext: .v

### Exercise 3: List Statistics 📈

Calculate statistics for a list of numbers:

    proc list_stats {numbers} {
        # TODO: Calculate and print:
        # - Count
        # - Sum
        # - Average
        # - Min
        # - Max
    }
    
    list_stats {10 25 15 30 20}

Expected output:

    Count: 5
    Sum: 100
    Average: 20.0
    Min: 10
    Max: 30

### Exercise 4: CSV Parser 📄

Parse CSV line into list:

    proc parse_csv {line} {
        # TODO: Split by comma and trim spaces
        # Return clean list
    }
    
    set line "  cell1  ,  cell2  ,  cell3  "
    set cells [parse_csv $line]
    puts $cells

Expected output:

    cell1 cell2 cell3

### Exercise 5: Pin Bus Expander 🔢

Expand bus notation to individual pins:

    proc expand_bus {bus_spec} {
        # TODO: Parse "data[7:0]" format
        # Return list of individual pins
    }
    
    set pins [expand_bus "data\[7:0\]"]
    puts $pins

Expected output:

    data[7] data[6] data[5] data[4] data[3] data[2] data[1] data[0]

Hint: Use string first, string range, split

### Exercise 6: Timing Report Parser ⏱️

Parse timing report line:

    proc parse_timing_line {line} {
        # TODO: Extract path, delay, slack
        # Line format: "path: INV->BUF delay: 1.5ns slack: 0.2ns"
    }
    
    parse_timing_line "path: CLK->Q delay: 2.3ns slack: -0.1ns"

Expected output:

    Path: CLK->Q
    Delay: 2.3
    Slack: -0.1
    Status: VIOLATION

### Exercise 7: List Deduplication 🔄

Remove duplicates from list:

    proc unique_list {list} {
        # TODO: Return list with duplicates removed
        # Preserve order
    }
    
    set nets {clk data clk rst data clk}
    puts [unique_list $nets]

Expected output:

    clk data rst

### Exercise 8: Hierarchical Path Builder 🌳

Build hierarchical module path:

    proc build_hierarchy {modules} {
        # TODO: Join modules with "/" separator
        # Return full hierarchical path
    }
    
    set path [build_hierarchy {top cpu alu adder}]
    puts $path

Expected output:

    top/cpu/alu/adder

---

## Summary Cheat Sheet

### String Operations

| Operation | Command | Example |
|-----------|---------|---------|
| Length | `string length $str` | `string length "hello"` → 5 |
| Get char | `string index $str $pos` | `string index "abc" 1` → b |
| Substring | `string range $str $start $end` | `string range "hello" 1 3` → ell |
| Find | `string first $sub $str` | `string first "lo" "hello"` → 3 |
| Replace | `string map {old new} $str` | `string map {a x} "abc"` → xbc |
| Upper | `string toupper $str` | `string toupper "abc"` → ABC |
| Lower | `string tolower $str` | `string tolower "ABC"` → abc |
| Trim | `string trim $str` | `string trim "  x  "` → x |

### List Operations

| Operation | Command | Example |
|-----------|---------|---------|
| Length | `llength $list` | `llength {a b c}` → 3 |
| Get element | `lindex $list $pos` | `lindex {a b c} 1` → b |
| Append | `lappend var $elem` | `lappend x "a"` |
| Insert | `linsert $list $pos $elem` | `linsert {a c} 1 b` → a b c |
| Replace | `lreplace $list $i $j $elem` | `lreplace {a b c} 1 1 x` → a x c |
| Search | `lsearch $list $pattern` | `lsearch {a b c} b` → 1 |
| Sort | `lsort $list` | `lsort {3 1 2}` → 1 2 3 |
| Join | `join $list $sep` | `join {a b c} ","` → a,b,c |
| Split | `split $str $sep` | `split "a,b,c" ","` → a b c |

---

## What's Next? 🚀

In Lesson 05 you will learn:

- File operations (open, read, write, close)
- Reading files line by line
- Writing formatted output
- File existence checks
- Directory operations
- Processing Verilog/Liberty/SDC files
- Error handling with file operations

Ready to proceed?

Complete the exercises above first, then move to:

    05_file_operations.md

---

Good luck with your practice! 💪

