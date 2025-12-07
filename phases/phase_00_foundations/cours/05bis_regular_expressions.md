# Lesson 05bis: Regular Expressions for Physical Design

## Table of Contents
1. Why Regexp in Physical Design?
2. TCL Regexp Fundamentals
3. Regexp vs Regsub Commands
4. Basic Patterns and Syntax
5. Character Classes and Quantifiers
6. Capture Groups and Backreferences
7. Verilog Parsing Patterns
8. Liberty File Parsing
9. SDC Constraint Parsing
10. Report Analysis Patterns
11. Bus Notation and Hierarchical Paths
12. Advanced Techniques
13. Performance Optimization
14. Real-world Examples
15. Practice Exercises

---

## 1. Why Regexp in Physical Design? 🎯

### Critical Use Cases in PD Flow 🔄

**You will use regexp EVERY DAY for:**

📌 **Netlist analysis:**
- Extract module names
- Find all flipflops (DFF, DFFR, SDFF...)
- Count instances of specific cells
- Parse port declarations with bus notation

📌 **Timing analysis:**
- Parse STA reports for violations
- Extract slack values from paths
- Find critical timing arcs
- Identify setup/hold failures

📌 **Power analysis:**
- Parse power reports
- Extract leakage per instance
- Find high-power cells
- Calculate total power by hierarchy

📌 **Constraint manipulation:**
- Modify SDC files programmatically
- Extract clock definitions
- Parse input/output delays
- Handle wildcard port selections

📌 **Library processing:**
- Parse Liberty (.lib) files
- Extract cell areas, delays
- Find pin capacitances
- Build cell databases

### Why TCL Regexp? 🤔

✅ **Native integration** with EDA tools (OpenSTA, OpenROAD, Innovus, ICC2)
✅ **Fast** for typical PD file sizes
✅ **Powerful** capture groups for data extraction
✅ **Built-in** - no external dependencies

---

## 2. TCL Regexp Fundamentals 📚

### The regexp Command Syntax 🔍

    regexp ?options? pattern string ?matchVar? ?subMatch1? ...

**Returns:** 1 if match found, 0 otherwise

**Basic example:**

    set text "module counter"
    if {[regexp {module} $text]} {
        puts "Found 'module' keyword"
    }

### Key Options 📋

| Option | Description | Example |
|--------|-------------|---------|
| -nocase | Case insensitive | regexp -nocase {MODULE} $text |
| -all | Find all matches | regexp -all {\\d+} $text |
| -inline | Return matches as list | set matches [regexp -inline -all {\\w+} $text] |
| -start | Start at index | regexp -start 10 {pattern} $text |
| -indices | Return match positions | regexp -indices {word} $text idxVar |

### Capture Groups Example 🎯

    set line "input [7:0] data_in"
    
    if {[regexp {(input|output)\s+\[(\d+):(\d+)\]\s+(\w+)} $line \
                match dir msb lsb name]} {
        puts "Direction: $dir"
        puts "MSB: $msb, LSB: $lsb"
        puts "Name: $name"
    }

**Output:**

    Direction: input
    MSB: 7, LSB: 0
    Name: data_in

---

## 3. Regexp vs Regsub Commands ⚔️

### regexp - Search and Extract 🔍

**Purpose:** Find patterns and capture data

    set text "Clock period is 10.5 ns"
    regexp {(\d+\.?\d*)\s*ns} $text match period
    puts "Period: $period"

**Output:**

    Period: 10.5

### regsub - Search and Replace ✏️

**Purpose:** Modify strings based on patterns

**Syntax:**

    regsub ?options? pattern string replacement varName

**Example 1: Simple replacement**

    set netlist "module TOP"
    regsub {TOP} $netlist "MY_DESIGN" new_netlist
    puts $new_netlist

**Output:**

    module MY_DESIGN

**Example 2: Replace all occurrences**

    set text "clk clk clk"
    regsub -all {clk} $text "clock" new_text
    puts $new_text

**Output:**

    clock clock clock

**Example 3: Using capture groups in replacement**

    set port "data_bus[7:0]"
    regsub {(\w+)\[(\d+):(\d+)\]} $port {\1_\2_to_\3} new_name
    puts $new_name

**Output:**

    data_bus_7_to_0

### Key Differences 📊

| Feature | regexp | regsub |
|---------|--------|--------|
| Purpose | Search/extract | Search/replace |
| Returns | 1/0 (found/not) | Number of substitutions |
| Captures | Into variables | Into replacement string |
| Modifies | No | Yes (into new variable) |
| -all option | Find all | Replace all |

---

## 4. Basic Patterns and Syntax 🔤

### Literal Characters 📝

    Match exact text (case sensitive by default)

**Example:**

    regexp {module} $text      ;# Matches "module"
    regexp {input} $text       ;# Matches "input"
    regexp {clk} $text         ;# Matches "clk"

### Metacharacters - Special Meaning ⚡

| Metacharacter | Meaning | Example |
|---------------|---------|---------|
| . | Any character (except newline) | a.c matches "abc", "a9c" |
| ^ | Start of line | ^module matches "module" at start |
| $ | End of line | ;$ matches ";" at end |
| * | 0 or more repetitions | ab*c matches "ac", "abc", "abbc" |
| + | 1 or more repetitions | ab+c matches "abc", "abbc" (not "ac") |
| ? | 0 or 1 occurrence | colou?r matches "color" or "colour" |
| \\ | Escape special character | \\. matches literal "." |
| | | Alternation (OR) | cat|dog matches "cat" or "dog" |
| () | Group and capture | (ab)+ matches "ab", "abab", "ababab" |
| [] | Character class | [abc] matches "a", "b", or "c" |
| {} | Repetition count | a{3} matches "aaa" |

### Examples 🎯

**Match Verilog comment:**

    regexp {//.*$} $line

**Match any number:**

    regexp {\\d+} $text

**Match floating point:**

    regexp {\\d+\\.\\d+} $text

**Match identifier:**

    regexp {[a-zA-Z_][a-zA-Z0-9_]*} $text

---

## 5. Character Classes and Quantifiers 🎭

### Predefined Character Classes 📦

| Class | Matches | Equivalent |
|-------|---------|------------|
| \\d | Digit | [0-9] |
| \\D | Non-digit | [^0-9] |
| \\w | Word character | [a-zA-Z0-9_] |
| \\W | Non-word character | [^a-zA-Z0-9_] |
| \\s | Whitespace | [ \\t\\n\\r\\f] |
| \\S | Non-whitespace | [^ \\t\\n\\r\\f] |

### Custom Character Classes 🎨

**Basic syntax:**

    [characters]      Match any one character in set
    [^characters]     Match any one character NOT in set

**Examples:**

    [0-9]            Any digit
    [a-z]            Any lowercase letter
    [A-Z]            Any uppercase letter
    [a-zA-Z]         Any letter
    [0-9a-fA-F]      Any hex digit
    [^0-9]           Anything except digit

### Quantifiers - How Many? 🔢

| Quantifier | Meaning | Example |
|------------|---------|---------|
| * | 0 or more | a* matches "", "a", "aa", "aaa" |
| + | 1 or more | a+ matches "a", "aa", "aaa" (not "") |
| ? | 0 or 1 | a? matches "" or "a" |
| {n} | Exactly n | a{3} matches "aaa" |
| {n,} | n or more | a{2,} matches "aa", "aaa", "aaaa" |
| {n,m} | Between n and m | a{2,4} matches "aa", "aaa", "aaaa" |

### Greedy vs Non-Greedy 🍕

**Greedy (default):** Match as much as possible

    set html "<b>bold</b> text <b>more</b>"
    regexp {<b>.*</b>} $html match
    puts $match

**Output:**

    <b>bold</b> text <b>more</b>

**Non-greedy:** Match as little as possible (add ?)

    regexp {<b>.*?</b>} $html match
    puts $match

**Output:**

    <b>bold</b>

### Physical Design Examples 🔧

**Match cell instance (greedy ok):**

    regexp {\\w+\\s+\\w+\\s*\\([^)]*\\)} $line

**Match pin name (non-greedy needed):**

    regexp {pin\\s*\\(\\s*"?(\\w+)"?\\s*\\)} $line match pin

**Match bus range:**

    regexp {\\[(\\d+):(\\d+)\\]} $port match msb lsb

---

## 6. Capture Groups and Backreferences 🎣

### Parentheses Create Groups 👥

**Syntax:**

    (pattern)         Capture group
    (?:pattern)       Non-capturing group

**Example:**

    set line "NAND2_X1 U123 (.A(n1), .B(n2), .Y(n3));"
    
    regexp {(\\w+)\\s+(\\w+)\\s*\\((.*)\\)} $line match celltype instname pins
    
    puts "Cell: $celltype"
    puts "Instance: $instname"
    puts "Pins: $pins"

**Output:**

    Cell: NAND2_X1
    Instance: U123
    Pins: .A(n1), .B(n2), .Y(n3)

### Multiple Captures 🎯

    set delay_line "set_input_delay 0.5 -clock clk [get_ports din]"
    
    regexp {set_input_delay\\s+(\\S+)\\s+-clock\\s+(\\w+)\\s+\\[get_ports\\s+(\\w+)\\]} \\
           $delay_line match delay clk port
    
    puts "Delay: $delay, Clock: $clk, Port: $port"

**Output:**

    Delay: 0.5, Clock: clk, Port: din

### Nested Groups 🪆

    set port "input wire [7:0] data_bus"
    
    regexp {(input|output)\\s+(wire|reg)?\\s*\\[(\\d+):(\\d+)\\]\\s+(\\w+)} \\
           $port match dir type msb lsb name
    
    puts "Direction: $dir"
    puts "Type: $type"
    puts "Range: \[$msb:$lsb\]"
    puts "Name: $name"

**Output:**

    Direction: input
    Type: wire
    Range: [7:0]
    Name: data_bus

### Backreferences - Refer to Previous Captures ��

**In pattern itself:**

    \\1, \\2, \\3...   Refer to capture group 1, 2, 3...

**Example: Find repeated words**

    set text "the the quick brown fox"
    regexp {(\\w+)\\s+\\1} $text match word
    puts "Repeated word: $word"

**Output:**

    Repeated word: the

**Example: Match balanced parentheses (simple case)**

    set expr "((a+b))"
    regexp {\\((.*)\\)} $expr match inner
    puts "Inner: $inner"

---

## 7. Verilog Parsing Patterns 🔌

### Module Declaration 📦

**Pattern:**

    module\\s+(\\w+)\\s*(?:#\\([^)]*\\))?\\s*\\(

**Example:**

    set verilog "module adder #(parameter WIDTH=8) ("
    
    if {[regexp {module\\s+(\\w+)} $verilog match modname]} {
        puts "Module: $modname"
    }

**Output:**

    Module: adder

### Port Declaration with Bus 🚌

**Pattern for input/output:**

    (input|output|inout)\\s+(wire|reg)?\\s*(\\[\\d+:\\d+\\])?\\s*(\\w+)

**Example:**

    set port "input wire [7:0] data_in,"
    
    regexp {(input|output|inout)\\s+(wire|reg)?\\s*(\\[(\\d+):(\\d+)\\])?\\s*(\\w+)} \\
           $port match dir type range msb lsb name
    
    puts "Direction: $dir"
    puts "Type: $type"
    puts "MSB: $msb, LSB: $lsb"
    puts "Name: $name"

**Output:**

    Direction: input
    Type: wire
    MSB: 7, LSB: 0
    Name: data_in

### Instance Declaration 🏗️

**Pattern:**

    (\\w+)\\s+(\\w+)\\s*\\(([^;]*)\\);

**Example:**

    set inst "NAND2_X1 U_NAND (.A(net1), .B(net2), .Y(net3));"
    
    regexp {(\\w+)\\s+(\\w+)\\s*\\(([^;]*)\\)} $inst match cell instname pins
    
    puts "Cell: $cell"
    puts "Instance: $instname"
    puts "Connections: $pins"

**Output:**

    Cell: NAND2_X1
    Instance: U_NAND
    Connections: .A(net1), .B(net2), .Y(net3)

### Wire/Reg Declaration ��

**Pattern:**

    (wire|reg)\\s*(\\[\\d+:\\d+\\])?\\s*(\\w+)

**Example:**

    set decl "wire [15:0] address_bus;"
    
    regexp {(wire|reg)\\s*(\\[(\\d+):(\\d+)\\])?\\s*(\\w+)} $decl \\
           match type range msb lsb name
    
    puts "Type: $type"
    if {$range ne ""} {
        puts "Bus width: [expr {$msb - $lsb + 1}]"
    }
    puts "Name: $name"

**Output:**

    Type: wire
    Bus width: 16
    Name: address_bus

### Assignment Statements 🎯

**Pattern for continuous assign:**

    assign\\s+(\\w+)\\s*=\\s*([^;]+);

**Example:**

    set assign "assign result = a & b;"
    
    regexp {assign\\s+(\\w+)\\s*=\\s*([^;]+)} $assign match lhs rhs
    
    puts "LHS: $lhs"
    puts "RHS: $rhs"

**Output:**

    LHS: result
    RHS: a & b

### Extract All Flipflops 🔍

**Common DFF patterns:**

    DFF.*|.*DFF.*|.*FF.*

**Example:**

    set netlist {
        NAND2_X1 U1 (.A(a), .B(b), .Y(c));
        DFFR_X1 FF_REG0 (.D(d), .CK(clk), .Q(q0));
        INV_X1 U2 (.A(c), .Y(d));
        SDFFRS_X1 FF_STATE (.D(d1), .CK(clk), .Q(q1));
    }
    
    foreach line [split $netlist "\\n"] {
        if {[regexp {(\\w*DFF\\w*)\\s+(\\w+)} $line match celltype instname]} {
            puts "Found FF: $instname (type: $celltype)"
        }
    }

**Output:**

    Found FF: FF_REG0 (type: DFFR_X1)
    Found FF: FF_STATE (type: SDFFRS_X1)

### Remove Comments 💬

**Single-line comments:**

    regsub -all {//[^\\n]*} $verilog "" clean_verilog

**Multi-line comments:**

    regsub -all {/\\*.*?\\*/} $verilog "" clean_verilog

**Example:**

    set code {
        module test; // this is a comment
        wire a; /* multi
                   line comment */
        endmodule
    }
    
    regsub -all {//[^\\n]*} $code "" temp
    regsub -all {/\\*.*?\\*/} $temp "" clean
    puts $clean

---

## 8. Liberty File Parsing ⏱️

### Cell Definition 🔬

**Pattern:**

    cell\\s*\\(\\s*"?(\\w+)"?\\s*\\)

**Example:**

    set lib_line {cell("NAND2_X1") \{}
    
    regexp {cell\\s*\\(\\s*"?(\\w+)"?\\s*\\)} $lib_line match cellname
    puts "Cell: $cellname"

**Output:**

    Cell: NAND2_X1

### Area Extraction 📐

**Pattern:**

    area\\s*:\\s*([\\d.]+)

**Example:**

    set area_line "    area : 2.5;"
    
    regexp {area\\s*:\\s*([\\d.]+)} $area_line match area
    puts "Area: $area"

**Output:**

    Area: 2.5

### Pin Definition 📌

**Pattern:**

    pin\\s*\\(\\s*"?(\\w+)"?\\s*\\)\\s*\\{

**Extract pin with direction:**

    set pin_block {
        pin(A) {
            direction : input;
            capacitance : 0.01;
        }
    }
    
    if {[regexp {pin\\s*\\(\\s*"?(\\w+)"?\\s*\\)} $pin_block match pinname]} {
        puts "Pin: $pinname"
        
        if {[regexp {direction\\s*:\\s*(\\w+)} $pin_block match dir]} {
            puts "Direction: $dir"
        }
        
        if {[regexp {capacitance\\s*:\\s*([\\d.]+)} $pin_block match cap]} {
            puts "Capacitance: $cap"
        }
    }

**Output:**

    Pin: A
    Direction: input
    Capacitance: 0.01

### Timing Arc Parsing ⏳

**Pattern:**

    related_pin\\s*:\\s*"(\\w+)"

**Example:**

    set timing {
        timing() {
            related_pin : "A";
            cell_rise(delay_template) {
                values("0.05, 0.06, 0.07");
            }
        }
    }
    
    regexp {related_pin\\s*:\\s*"(\\w+)"} $timing match related
    puts "Related pin: $related"
    
    regexp {cell_rise[^"]*"([^"]+)"} $timing match delays
    puts "Rise delays: $delays"

**Output:**

    Related pin: A
    Rise delays: 0.05, 0.06, 0.07

### Power Values 🔋

**Pattern:**

    (leakage_power|dynamic_power)\\s*:\\s*([\\d.]+)

**Example:**

    set power_line "leakage_power : 0.125;"
    
    regexp {(leakage_power|dynamic_power)\\s*:\\s*([\\d.]+)} \\
           $power_line match type value
    
    puts "Power type: $type"
    puts "Value: $value"

**Output:**

    Power type: leakage_power
    Value: 0.125

---

## 9. SDC Constraint Parsing ⚙️

### Clock Creation 🕐

**Pattern:**

    create_clock\\s+-period\\s+([\\d.]+)\\s+(\\S+)

**Example:**

    set sdc "create_clock -period 10.0 clk"
    
    regexp {create_clock\\s+-period\\s+([\\d.]+)\\s+(\\S+)} $sdc match period clkname
    
    puts "Clock: $clkname"
    puts "Period: $period ns"

**Output:**

    Clock: clk
    Period: 10.0 ns

### Input Delay ⏲️

**Pattern:**

    set_input_delay\\s+([\\d.]+)\\s+-clock\\s+(\\w+)\\s+\\[get_ports\\s+([^\\]]+)\\]

**Example:**

    set sdc "set_input_delay 0.5 -clock clk [get_ports {din*}]"
    
    regexp {set_input_delay\\s+([\\d.]+)\\s+-clock\\s+(\\w+)\\s+\\[get_ports\\s+\\{?([^\\}\\]]+)} \\
           $sdc match delay clk ports
    
    puts "Input delay: $delay"
    puts "Clock: $clk"
    puts "Ports: $ports"

**Output:**

    Input delay: 0.5
    Clock: clk
    Ports: din*

### Output Delay ⏱️

**Similar pattern:**

    set_output_delay\\s+([\\d.]+)\\s+-clock\\s+(\\w+)\\s+\\[get_ports\\s+([^\\]]+)\\]

### Load Capacitance 📊

**Pattern:**

    set_load\\s+([\\d.]+)\\s+\\[get_ports\\s+([^\\]]+)\\]

**Example:**

    set sdc "set_load 0.05 [all_outputs]"
    
    regexp {set_load\\s+([\\d.]+)\\s+\\[([^\\]]+)\\]} $sdc match load target
    
    puts "Load: $load pF"
    puts "Target: $target"

**Output:**

    Load: 0.05 pF
    Target: all_outputs

### Wildcard Port Selection 🎯

**get_ports with wildcards:**

    \\[get_ports\\s+\\{?([^\\}\\]]+)\\}?\\]

**Example:**

    set patterns {
        [get_ports din*]
        [get_ports {data_*}]
        [get_ports *_valid]
    }
    
    foreach pat $patterns {
        if {[regexp {\\[get_ports\\s+\\{?([^\\}\\]]+)\\}?\\]} $pat match portpat]} {
            puts "Port pattern: $portpat"
        }
    }

**Output:**

    Port pattern: din*
    Port pattern: data_*
    Port pattern: *_valid

---

## 10. Report Analysis Patterns 📋

### Timing Violation Detection 🚨

**Pattern:**

    (Setup|Hold)\\s+violation.*slack\\s+([-\\d.]+)

**Example:**

    set report {
        Path 1: Setup violation
        Endpoint: FF_reg/D
        Slack: -0.125
    }
    
    if {[regexp {(Setup|Hold)\\s+violation} $report match type]} {
        puts "Found $type violation"
        
        if {[regexp {slack\\s*:?\\s*([-\\d.]+)} $report match slack]} {
            puts "Slack: $slack ns"
            if {$slack < 0} {
                puts "VIOLATION!"
            }
        }
    }

**Output:**

    Found Setup violation
    Slack: -0.125 ns
    VIOLATION!

### Path Delay Extraction 🛤️

**Pattern:**

    Path\\s+\\d+:.*slack\\s+([-\\d.]+)

**Example:**

    set timing_report {
        Path 1: clk -> FF1/D   slack: 0.45
        Path 2: clk -> FF2/D   slack: -0.12
        Path 3: clk -> FF3/D   slack: 1.23
    }
    
    set violations 0
    foreach line [split $timing_report "\\n"] {
        if {[regexp {Path\\s+(\\d+):.*slack\\s*:?\\s*([-\\d.]+)} $line match pathnum slack]} {
            if {$slack < 0} {
                puts "Path $pathnum VIOLATES by [expr {abs($slack)}] ns"
                incr violations
            }
        }
    }
    puts "Total violations: $violations"

**Output:**

    Path 2 VIOLATES by 0.12 ns
    Total violations: 1

### Cell Delay Parsing 🕰️

**Pattern:**

    (\\w+)\\s+\\(([^)]+)\\)\\s+([\\d.]+)\\s+([\\d.]+)

**Example:**

    set path_line "NAND2_X1 (U123)    0.05    0.15"
    
    regexp {(\\w+)\\s+\\(([^)]+)\\)\\s+([\\d.]+)\\s+([\\d.]+)} \\
           $path_line match celltype inst incr_delay arrival
    
    puts "Cell: $celltype"
    puts "Instance: $inst"
    puts "Delay: $incr_delay"
    puts "Arrival: $arrival"

**Output:**

    Cell: NAND2_X1
    Instance: U123
    Delay: 0.05
    Arrival: 0.15

### Warning/Error Messages ⚠️

**Pattern:**

    \\[(WARNING|ERROR)\\]\\s*:?\\s*(.+)

**Example:**

    set log {
        [INFO] : Starting analysis
        [WARNING] : High fanout on net clk (fanout=150)
        [ERROR] : Cannot find library cell INV_X99
    }
    
    foreach line [split $log "\\n"] {
        if {[regexp {\\[(WARNING|ERROR)\\]\\s*:?\\s*(.+)} $line match level msg]} {
            puts "$level: $msg"
        }
    }

**Output:**

    WARNING: High fanout on net clk (fanout=150)
    ERROR: Cannot find library cell INV_X99

### Power Report Parsing 🔋

**Pattern:**

    (\\w+)\\s+([\\d.]+)\\s+(\\w+)\\s+([\\d.]+)%

**Example:**

    set power_report {
        Instance        Power    Type      Percentage
        CPU_core        125.5    dynamic   45.2%
        Memory_ctrl     85.3     leakage   30.7%
    }
    
    foreach line [split $power_report "\\n"] {
        if {[regexp {(\\w+)\\s+([\\d.]+)\\s+(\\w+)\\s+([\\d.]+)%} $line \\
                    match inst power type pct]} {
            puts "$inst: $power mW ($type, $pct%)"
        }
    }

**Output:**

    CPU_core: 125.5 mW (dynamic, 45.2%)
    Memory_ctrl: 85.3 mW (leakage, 30.7%)

---

## 11. Bus Notation and Hierarchical Paths 🚌

### Bus Parsing 🎯

**Pattern for range:**

    \\[(\\d+):(\\d+)\\]

**Example:**

    set bus "data_bus[7:0]"
    
    regexp {(\\w+)\\[(\\d+):(\\d+)\\]} $bus match name msb lsb
    
    puts "Bus name: $name"
    puts "Width: [expr {$msb - $lsb + 1}] bits"
    puts "Range: \[$msb:$lsb\]"

**Output:**

    Bus name: data_bus
    Width: 8 bits
    Range: [7:0]

### Expand Bus to Individual Bits 💫

    proc expand_bus {bus_spec} {
        if {[regexp {(\\w+)\\[(\\d+):(\\d+)\\]} $bus_spec match name msb lsb]} {
            set bits {}
            if {$msb >= $lsb} {
                for {set i $msb} {$i >= $lsb} {incr i -1} {
                    lappend bits "${name}\[${i}\]"
                }
            } else {
                for {set i $msb} {$i <= $lsb} {incr i} {
                    lappend bits "${name}\[${i}\]"
                }
            }
            return $bits
        }
        return $bus_spec
    }
    
    set expanded [expand_bus "data[7:0]"]
    puts $expanded

**Output:**

    data[7] data[6] data[5] data[4] data[3] data[2] data[1] data[0]

### Hierarchical Path Parsing 🌳

**Pattern:**

    ([\\w/]+)/(\\w+)

**Example:**

    set hier_path "top/cpu_core/alu/reg_file/data_reg"
    
    if {[regexp {([\\w/]+)/(\\w+)$} $hier_path match parent leaf]} {
        puts "Parent hierarchy: $parent"
        puts "Leaf cell: $leaf"
    }
    
    set levels [split $hier_path "/"]
    puts "Hierarchy depth: [llength $levels]"
    puts "Top module: [lindex $levels 0]"

**Output:**

    Parent hierarchy: top/cpu_core/alu/reg_file
    Leaf cell: data_reg
    Hierarchy depth: 5
    Top module: top

### Extract Hierarchy Level 📊

    proc get_hierarchy_level {path level} {
        set parts [split $path "/"]
        if {$level < [llength $parts]} {
            return [lindex $parts $level]
        }
        return ""
    }
    
    set path "top/cpu/alu/adder/FA_0"
    puts "Level 0: [get_hierarchy_level $path 0]"
    puts "Level 2: [get_hierarchy_level $path 2]"

**Output:**

    Level 0: top
    Level 2: alu

### Match Hierarchical Wildcards 🎭

**Pattern:**

    top/cpu_.*/alu.*

**Example:**

    proc match_hier_pattern {path pattern} {
        set regex [string map {* {.*} ? {.}} $pattern]
        return [regexp $regex $path]
    }
    
    set paths {
        top/cpu_0/alu_add/U1
        top/cpu_1/alu_sub/U2
        top/mem_ctrl/decoder/U3
    }
    
    foreach p $paths {
        if {[match_hier_pattern $p "top/cpu*/alu*"]} {
            puts "Match: $p"
        }
    }

**Output:**

    Match: top/cpu_0/alu_add/U1
    Match: top/cpu_1/alu_sub/U2

---

## 12. Advanced Techniques 🚀

### Lookahead and Lookbehind 👀

**Positive lookahead (?=...)** - Match if followed by...

    \\w+(?=\\s*\\()

**Matches word followed by "(" but doesn't consume "("**

**Example:**

    set inst "NAND2_X1 U123 (.A(n1))"
    regexp {(\\w+)(?=\\s+\\w+\\s*\\()} $inst match celltype
    puts "Cell type: $celltype"

**Output:**

    Cell type: NAND2_X1

**Negative lookahead (?!...)** - Match if NOT followed by...

**Positive lookbehind (?<=...)** - Match if preceded by...

**Negative lookbehind (?<!...)** - Match if NOT preceded by...

**Note:** TCL regexp has limited lookbehind support. Use carefully.

### Non-Capturing Groups (?:...) 🎯

**Don't create capture variable:**

    regexp {(?:input|output)\\s+(\\w+)} $line match name

**Only $name is captured, not the direction**

### Multi-line Matching 📜

**Use -line option:**

    regexp -line {^module} $text

**Or handle newlines explicitly:**

    regexp {module[^;]*;} $text

**Example:**

    set verilog {
        module counter (
            input clk,
            output [7:0] count
        );
    }
    
    regexp {module\\s+(\\w+)\\s*\\(([^)]+)\\)} $verilog match modname ports
    puts "Module: $modname"

**Output:**

    Module: counter

### Case-Insensitive Matching 🔤

**Use -nocase:**

    regexp -nocase {module} $text

**Example:**

    set text "MODULE counter"
    if {[regexp -nocase {module\\s+(\\w+)} $text match name]} {
        puts "Found module: $name"
    }

**Output:**

    Found module: counter

### Extracting All Matches 🔍

**Use -all -inline:**

    set numbers [regexp -all -inline {\\d+} $text]

**Example:**

    set report "Delays: 0.5, 1.2, 0.8, 2.1 ns"
    set delays [regexp -all -inline {[\\d.]+} $report]
    
    puts "Found [llength $delays] delay values:"
    foreach d $delays {
        puts "  $d"
    }

**Output:**

    Found 4 delay values:
      0.5
      1.2
      0.8
      2.1

### Complex Verilog Instance Parsing 🏗️

**Handle parameters and multi-line:**

    proc parse_instance {inst_text} {
        set pattern {(\\w+)\\s+(?:#\\s*\\(([^)]+)\\)\\s*)?(\\w+)\\s*\\(([^;]+)\\)}
        
        if {[regexp $pattern $inst_text match cell params inst pins]} {
            set result [dict create]
            dict set result cell $cell
            dict set result instance $inst
            dict set result pins $pins
            
            if {$params ne ""} {
                dict set result params $params
            }
            
            return $result
        }
        return {}
    }
    
    set inst {adder #(.WIDTH(8)) U_ADD (.a(in1), .b(in2), .sum(out));}
    set parsed [parse_instance $inst]
    
    puts "Cell: [dict get $parsed cell]"
    puts "Instance: [dict get $parsed instance]"
    if {[dict exists $parsed params]} {
        puts "Parameters: [dict get $parsed params]"
    }

**Output:**

    Cell: adder
    Instance: U_ADD
    Parameters: .WIDTH(8)

---

## 13. Performance Optimization ⚡

### Compile Regexp for Repeated Use 🔄

**TCL automatically caches regexp patterns, but you can help:**

    Instead of calling regexp in tight loop with string pattern,
    use a pre-defined variable

**Good:**

    set pattern {\\d+}
    foreach line $lines {
        regexp $pattern $line match
    }

**Better (minimal impact, TCL optimizes anyway):**

    Use same pattern string repeatedly - TCL caches it

### Avoid Backtracking 🔙

**Problematic (catastrophic backtracking):**

    .*.*=.*

**Better:**

    [^=]*=[^=]*

**Example:**

    Instead of:   .*keyword.*
    Use:          [^\\n]*keyword[^\\n]*

### Use Character Classes Instead of Alternation 📦

**Slower:**

    (a|b|c|d|e)

**Faster:**

    [a-e]

### Anchor Patterns When Possible ⚓

**Slower:**

    module\\s+(\\w+)

**Faster if you know it's at line start:**

    ^module\\s+(\\w+)

### Use Non-Capturing Groups (?:...) 🎯

**When you don't need the capture:**

    regexp {(?:input|output)\\s+(\\w+)} $line match name

**Slightly faster than:**

    regexp {(input|output)\\s+(\\w+)} $line match dir name

### Process Line-by-Line for Large Files 📚

**Bad (loads entire file):**

    set fh [open $file r]
    set content [read $fh]
    close $fh
    foreach line [split $content "\\n"] {
        regexp $pattern $line
    }

**Good (streams):**

    set fh [open $file r]
    while {[gets $fh line] >= 0} {
        if {[regexp $pattern $line match]} {
            # Process match
        }
    }
    close $fh

---

## 14. Real-world Examples 🌍

### Example 1: Count All Cell Types in Netlist 📊

    proc count_cell_types {netlist_file} {
        set cell_counts [dict create]
        
        set fh [open $netlist_file r]
        while {[gets $fh line] >= 0} {
            if {[regexp {^\\s*(\\w+)\\s+(\\w+)\\s*\\(} $line match celltype inst]} {
                if {[dict exists $cell_counts $celltype]} {
                    dict incr cell_counts $celltype
                } else {
                    dict set cell_counts $celltype 1
                }
            }
        }
        close $fh
        
        return $cell_counts
    }
    
    set counts [count_cell_types "design.v"]
    dict for {cell count} $counts {
        puts [format "%-20s : %5d" $cell $count]
    }

**Output example:**

    NAND2_X1             :   145
    INV_X1               :    89
    DFFR_X1              :    32
    NOR2_X1              :    67

### Example 2: Find Critical Paths from Report 🔥

    proc find_critical_paths {report_file threshold} {
        set critical_paths {}
        
        set fh [open $report_file r]
        set path_num 0
        set current_slack 0
        
        while {[gets $fh line] >= 0} {
            if {[regexp {Path\\s+(\\d+):} $line match num]} {
                set path_num $num
            }
            
            if {[regexp {slack\\s*:?\\s*([-\\d.]+)} $line match slack]} {
                set current_slack $slack
                if {$slack < $threshold} {
                    lappend critical_paths [list $path_num $slack]
                }
            }
        }
        close $fh
        
        return [lsort -real -index 1 $critical_paths]
    }
    
    set critical [find_critical_paths "timing.rpt" 0.1]
    
    puts "Critical paths (slack < 0.1):"
    foreach path $critical {
        lassign $path num slack
        puts [format "  Path %3d: slack = %6.3f ns" $num $slack]
    }

**Output example:**

    Critical paths (slack < 0.1):
      Path   2: slack = -0.125 ns
      Path  15: slack = -0.050 ns
      Path  47: slack =  0.025 ns
      Path  89: slack =  0.075 ns

### Example 3: Parse Liberty and Build Cell Database 📚

    proc build_cell_database {liberty_file} {
        set db [dict create]
        
        set fh [open $liberty_file r]
        set content [read $fh]
        close $fh
        
        set cell_pattern {cell\\s*\\(\\s*"?(\\w+)"?\\s*\\)\\s*\\{([^}]+(?:\\{[^}]+\\}[^}]+)*?)\\}}
        
        set cells [regexp -all -inline $cell_pattern $content]
        
        for {set i 0} {$i < [llength $cells]} {incr i 3} {
            set cell_name [lindex $cells [expr {$i + 1}]]
            set cell_body [lindex $cells [expr {$i + 2}]]
            
            set cell_info [dict create]
            
            if {[regexp {area\\s*:\\s*([\\d.]+)} $cell_body match area]} {
                dict set cell_info area $area
            }
            
            if {[regexp {leakage_power\\s*:\\s*([\\d.]+)} $cell_body match power]} {
                dict set cell_info leakage $power
            }
            
            dict set db $cell_name $cell_info
        }
        
        return $db
    }
    
    set lib_db [build_cell_database "cells.lib"]
    
    dict for {cell info} $lib_db {
        puts "$cell:"
        puts "  Area: [dict get $info area]"
        if {[dict exists $info leakage]} {
            puts "  Leakage: [dict get $info leakage]"
        }
    }

### Example 4: Modify SDC Constraints Programmatically ✏️

    proc scale_delays {sdc_file scale_factor output_file} {
        set fh [open $sdc_file r]
        set out [open $output_file w]
        
        while {[gets $fh line] >= 0} {
            if {[regexp {(set_input_delay|set_output_delay)\\s+([\\d.]+)(.+)} \\
                        $line match cmd delay rest]} {
                set new_delay [expr {$delay * $scale_factor}]
                puts $out "$cmd $new_delay$rest"
            } else {
                puts $out $line
            }
        }
        
        close $fh
        close $out
    }
    
    scale_delays "original.sdc" 1.2 "scaled.sdc"
    puts "SDC delays scaled by 1.2x"

### Example 5: Extract Hierarchical Timing Paths 🌳

    proc extract_hier_paths {report_file output_file} {
        set fh [open $report_file r]
        set out [open $output_file w]
        
        set in_path 0
        set current_path {}
        
        while {[gets $fh line] >= 0} {
            if {[regexp {^Path\\s+\\d+:} $line]} {
                set in_path 1
                set current_path {}
            }
            
            if {$in_path && [regexp {([\\w/]+)\\s+\\(([^)]+)\\)} $line match hier inst]} {
                lappend current_path $hier
            }
            
            if {$in_path && [regexp {slack} $line]} {
                set in_path 0
                if {[llength $current_path] > 0} {
                    puts $out [join $current_path " -> "]
                }
            }
        }
        
        close $fh
        close $out
    }

### Example 6: Bus Expansion for Constraint Generation 🚌

    proc generate_bus_constraints {bus_spec constraint_template} {
        set constraints {}
        
        if {[regexp {(\\w+)\\[(\\d+):(\\d+)\\]} $bus_spec match name msb lsb]} {
            if {$msb >= $lsb} {
                for {set i $msb} {$i >= $lsb} {incr i -1} {
                    set bit_name "${name}\[${i}\]"
                    set constraint [string map [list %BIT% $bit_name] $constraint_template]
                    lappend constraints $constraint
                }
            }
        }
        
        return $constraints
    }
    
    set template "set_input_delay 0.5 -clock clk \[get_ports %BIT%\]"
    set constraints [generate_bus_constraints "data[7:0]" $template]
    
    foreach c $constraints {
        puts $c
    }

**Output:**

    set_input_delay 0.5 -clock clk [get_ports data[7]]
    set_input_delay 0.5 -clock clk [get_ports data[6]]
    ...
    set_input_delay 0.5 -clock clk [get_ports data[0]]

---

## 15. Practice Exercises 🎯

### Exercise 1: Verilog Module Extractor 📦

**Task:** Parse a Verilog file and extract all module names with their port counts.

**Input file:** design.v

**Expected output:**

    Module: counter
      Input ports: 3
      Output ports: 1
    
    Module: and_gate
      Input ports: 2
      Output ports: 1

**Hint:** Use pattern `module\\s+(\\w+)` and count `input|output` declarations.

---

### Exercise 2: Liberty Cell Area Report 📊

**Task:** Parse Liberty file and generate area report sorted by area.

**Input file:** cells.lib

**Expected output:**

    Cell Area Report
    ================
    NAND2_X1    :   4.5
    INV_X1      :   2.5
    DFFR_X1     :   8.2

**Hint:** Extract `cell(name)` and `area : value` patterns.

---

### Exercise 3: SDC Delay Analyzer ⏱️

**Task:** Read SDC file and report min/max/average input delays.

**Input file:** constraints.sdc

**Expected output:**

    Input Delay Statistics:
      Minimum: 0.3 ns
      Maximum: 0.8 ns
      Average: 0.55 ns
      Total constraints: 5

**Hint:** Use `set_input_delay\\s+([\\d.]+)` pattern.

---

### Exercise 4: Timing Violation Filter 🚨

**Task:** Parse timing report and output only violating paths with slack < -0.05.

**Input file:** timing.rpt

**Expected output:**

    CRITICAL VIOLATIONS (slack < -0.05):
    =====================================
    Path 2: slack = -0.125 ns
    Path 15: slack = -0.087 ns

**Hint:** Use `Path\\s+(\\d+):.*slack\\s+([-\\d.]+)` pattern.

---

### Exercise 5: Netlist Instance Counter 🔢

**Task:** Count instances per cell type and calculate total area (assume each cell area from Liberty).

**Input files:** netlist.v, cells.lib

**Expected output:**

    Cell Type       Count   Area/cell   Total Area
    ================================================
    NAND2_X1          145      4.5         652.5
    INV_X1             89      2.5         222.5
    DFFR_X1            32      8.2         262.4
    ================================================
    TOTAL                                 1137.4

---

### Exercise 6: Bus Constraint Generator 🚌

**Task:** Read a list of bus signals and generate individual bit constraints.

**Input:**

    data_in[7:0]
    addr[15:0]
    ctrl[3:0]

**Expected output:**

    set_input_delay 0.5 -clock clk [get_ports data_in[7]]
    set_input_delay 0.5 -clock clk [get_ports data_in[6]]
    ...
    set_input_delay 0.5 -clock clk [get_ports addr[15]]
    ...

---

### Exercise 7: Hierarchical Path Reporter 🌳

**Task:** Extract all unique hierarchical levels from timing paths.

**Input file:** timing.rpt

**Expected output:**

    Hierarchy Analysis:
    ===================
    Level 0: top
    Level 1: cpu_core, memory_ctrl
    Level 2: alu, reg_file, decoder
    Level 3: adder, multiplier

---

### Exercise 8: Comment Stripper 💬

**Task:** Remove all comments (// and /* */) from Verilog file.

**Input file:** design.v

**Expected output:** Clean Verilog without comments

**Hint:** Use `regsub -all {//[^\\n]*} and regsub -all {/\\*.*?\\*/}`

---

### Exercise 9: Liberty Pin Capacitance Extractor 📌

**Task:** Extract all pins with their capacitance values.

**Input file:** cells.lib

**Expected output:**

    Cell: NAND2_X1
      Pin A: cap = 0.01 pF
      Pin B: cap = 0.01 pF
      Pin Y: cap = 0.00 pF (output)
    
    Cell: INV_X1
      Pin A: cap = 0.01 pF
      Pin Y: cap = 0.00 pF (output)

---

### Exercise 10: Power Report Summarizer 🔋

**Task:** Parse power report and calculate total/average power by type.

**Input file:** power.rpt

**Expected output:**

    Power Summary:
    ==============
    Dynamic Power: 125.5 mW (45.2%)
    Leakage Power:  85.3 mW (30.7%)
    Static Power:   67.2 mW (24.1%)
    --------------
    Total Power:   278.0 mW

---

## Summary 📚

You've learned regexp for Physical Design:

✅ **TCL regexp fundamentals** (regexp, regsub, options)
✅ **Pattern syntax** (metacharacters, quantifiers, groups)
✅ **Verilog parsing** (modules, ports, instances, buses)
✅ **Liberty parsing** (cells, pins, timing, power)
✅ **SDC parsing** (clocks, delays, loads, wildcards)
✅ **Report analysis** (violations, paths, delays)
✅ **Hierarchical paths** and bus expansion
✅ **Advanced techniques** (lookahead, non-capturing, optimization)
✅ **Real-world examples** ready to use

---

## What's Next? 🚀

**Lesson 06: Arrays and Dictionaries**

You'll learn:
- Array operations for storing cell data
- Dictionary operations (TCL 8.5+)
- Nested data structures
- Building databases of timing/power/area info

**Then:** Apply ALL techniques in Phase 0 Final Project! 🎯

---

## Quick Reference Card 📇

**Common PD Patterns:**

    Module:       module\\s+(\\w+)
    Port:         (input|output)\\s+(\\[\\d+:\\d+\\])?\\s*(\\w+)
    Instance:     (\\w+)\\s+(\\w+)\\s*\\(
    Bus:          (\\w+)\\[(\\d+):(\\d+)\\]
    Hier path:    ([\\w/]+)/(\\w+)
    
    Liberty cell: cell\\s*\\(\\s*"?(\\w+)"?\\s*\\)
    Area:         area\\s*:\\s*([\\d.]+)
    Pin:          pin\\s*\\(\\s*"?(\\w+)"?\\s*\\)
    
    SDC clock:    create_clock\\s+-period\\s+([\\d.]+)\\s+(\\S+)
    Input delay:  set_input_delay\\s+([\\d.]+)
    Load:         set_load\\s+([\\d.]+)
    
    Slack:        slack\\s*:?\\s*([-\\d.]+)
    Violation:    (Setup|Hold)\\s+violation

**Good luck with exercises!** 💪🚀


---

## Exercise Templates 📝

### Exercise 1 Template: Module Extractor

    #!/usr/bin/env tclsh
    
    # Exercise 1: Module Extractor
    # Extract all module names from a Verilog file
    
    # TODO 1: Open the file design.v
    
    
    # TODO 2: Read all lines into a variable
    
    
    # TODO 3: Use regexp to find all module declarations
    # Pattern: module followed by module_name
    
    
    # TODO 4: Store module names in a list
    
    
    # TODO 5: Print results
    puts "Modules found:"
    # foreach module $module_list { ... }
    
    
    # TODO 6: Count total modules
    
    
    puts "\nTotal modules: ???"

---

### Exercise 2 Template: Cell Area Report

    #!/usr/bin/env tclsh
    
    # Exercise 2: Cell Area Report
    # Parse Liberty file and extract cell areas
    
    # TODO 1: Open cells.lib file
    
    
    # TODO 2: Initialize array for storing cell data
    
    
    # TODO 3: Read file line by line
    
    
    # TODO 4: Find cell definitions
    # Pattern: cell(CELL_NAME)
    
    
    # TODO 5: Extract area values
    # Pattern: area : VALUE ;
    
    
    # TODO 6: Store in array
    # cell_area(CELL_NAME) = VALUE
    
    
    # TODO 7: Calculate total area
    
    
    # TODO 8: Print report sorted by area
    puts "Cell Area Report"
    puts "================\n"
    # foreach cell [lsort ...] { ... }
    
    
    puts "\nTotal area: ??? um^2"

---

### Exercise 3 Template: SDC Analyzer

    #!/usr/bin/env tclsh
    
    # Exercise 3: SDC Constraint Analyzer
    # Parse SDC file and categorize constraints
    
    # TODO 1: Open constraints.sdc
    
    
    # TODO 2: Initialize counters
    set clocks 0
    set input_delays 0
    set output_delays 0
    set loads 0
    
    # TODO 3: Read file and count each constraint type
    
    
    # TODO 4: Extract clock periods
    # Pattern: create_clock -period VALUE
    
    
    # TODO 5: Find all input delay values
    # Pattern: set_input_delay VALUE
    
    
    # TODO 6: Print summary
    puts "SDC Constraint Summary"
    puts "=====================\n"
    puts "Clock definitions: $clocks"
    puts "Input delays: $input_delays"
    puts "Output delays: $output_delays"
    puts "Load constraints: $loads"
    
    # TODO 7: Print clock details
    puts "\nClock Details:"
    # foreach {name period} $clock_data { ... }

---

### Exercise 4 Template: Violation Filter

    #!/usr/bin/env tclsh
    
    # Exercise 4: Timing Violation Filter
    # Extract paths with setup violations from timing report
    
    # TODO 1: Open timing.rpt
    
    
    # TODO 2: Read entire file
    
    
    # TODO 3: Find all paths with VIOLATED
    # Pattern: slack \(VIOLATED\)
    
    
    # TODO 4: Extract slack values for violations
    # Pattern: slack (VIOLATED) followed by negative number
    
    
    # TODO 5: Extract path numbers
    # Pattern: Path N:
    
    
    # TODO 6: Sort violations by slack (worst first)
    
    
    # TODO 7: Print violation report
    puts "Setup Violations Report"
    puts "======================\n"
    # foreach violation $sorted_list { ... }
    
    
    puts "\nTotal violations: ???"
    puts "Worst slack: ???"

---

### Exercise 5 Template: Instance Counter

    #!/usr/bin/env tclsh
    
    # Exercise 5: Cell Instance Counter
    # Count instances of each cell type in netlist
    
    # TODO 1: Open netlist.v
    
    
    # TODO 2: Initialize array for counting
    
    
    # TODO 3: Read file and find all instances
    # Pattern: CELL_TYPE INSTANCE_NAME (
    
    
    # TODO 4: Count each cell type
    
    
    # TODO 5: Open cells.lib to get area per cell
    
    
    # TODO 6: Calculate total area per cell type
    
    
    # TODO 7: Print report with counts and areas
    puts "Instance Count Report"
    puts "====================\n"
    puts [format "%-15s %8s %12s" "Cell Type" "Count" "Total Area"]
    puts [string repeat "-" 40]
    # foreach cell [lsort ...] { ... }
    
    
    puts "\nTotal instances: ???"
    puts "Total area: ??? um^2"

---

### Exercise 6 Template: Bus Expander

    #!/usr/bin/env tclsh
    
    # Exercise 6: Bus Signal Expander
    # Convert bus notation to individual bit signals
    
    # TODO 1: Open bus_signals.txt
    
    
    # TODO 2: Read all bus definitions
    
    
    # TODO 3: For each bus, extract name and range
    # Pattern: BUS_NAME[MSB:LSB]
    
    
    # TODO 4: Expand to individual bits
    # data[7:0] -> data[7] data[6] ... data[0]
    
    
    # TODO 5: Print expanded signals
    puts "Bus Expansion Report"
    puts "===================\n"
    # foreach bus $bus_list { ... }

---

### Exercise 7 Template: Hierarchy Reporter

    #!/usr/bin/env tclsh
    
    # Exercise 7: Hierarchical Path Analyzer
    # Analyze and report on hierarchical design structure
    
    # TODO 1: Open hier_paths.txt
    
    
    # TODO 2: Read all paths
    
    
    # TODO 3: Extract hierarchy levels
    # Split path by / to get levels
    
    
    # TODO 4: Count instances per module
    
    
    # TODO 5: Find leaf cells (last level)
    
    
    # TODO 6: Build hierarchy tree
    
    
    # TODO 7: Print hierarchy report
    puts "Hierarchy Analysis Report"
    puts "========================\n"
    puts "Top module: ???"
    puts "Hierarchy depth: ???"
    puts "\nModule instance counts:"
    # foreach module [lsort ...] { ... }
    
    
    puts "\nLeaf cells: ???"

---

### Exercise 8 Template: Comment Stripper

    #!/usr/bin/env tclsh
    
    # Exercise 8: Verilog Comment Remover
    # Remove all comments from Verilog file
    
    # TODO 1: Open design.v for reading
    
    
    # TODO 2: Open output file for writing
    
    
    # TODO 3: Process each line
    
    
    # TODO 4: Remove single-line comments (//)
    # Use regsub to replace // and everything after
    
    
    # TODO 5: Handle multi-line comments (/* */)
    # Track state: in_comment or not
    
    
    # TODO 6: Write cleaned line to output
    
    
    # TODO 7: Print statistics
    puts "Comment Removal Statistics"
    puts "=========================\n"
    puts "Original lines: ???"
    puts "Comments removed: ???"
    puts "Output lines: ???"
    puts "\nCleaned file: design_clean.v"

---

### Exercise 9 Template: Pin Capacitance Extractor

    #!/usr/bin/env tclsh
    
    # Exercise 9: Pin Capacitance Report
    # Extract pin capacitances from Liberty file
    
    # TODO 1: Open cells.lib
    
    
    # TODO 2: Track current cell being processed
    
    
    # TODO 3: Find pin definitions within cells
    # Pattern: pin(PIN_NAME)
    
    
    # TODO 4: Extract capacitance values
    # Pattern: capacitance : VALUE ;
    
    
    # TODO 5: Store as cell(pin) -> capacitance
    
    
    # TODO 6: Find max and min capacitances
    
    
    # TODO 7: Print report
    puts "Pin Capacitance Report"
    puts "=====================\n"
    puts [format "%-15s %-10s %10s" "Cell" "Pin" "Cap (pF)"]
    puts [string repeat "-" 40]
    # foreach key [lsort ...] { ... }
    
    
    puts "\nMax capacitance: ??? pF (???)"
    puts "Min capacitance: ??? pF (???)"

---

### Exercise 10 Template: Power Summary Generator

    #!/usr/bin/env tclsh
    
    # Exercise 10: Power Report Summarizer
    # Parse power report and generate summary
    
    # TODO 1: Open power.rpt
    
    
    # TODO 2: Extract total power
    # Pattern: Total Power: VALUE mW
    
    
    # TODO 3: Extract power breakdown
    # Dynamic, Leakage, Static power values and percentages
    
    
    # TODO 4: Extract top power consumers
    # Pattern: Instance followed by Power value
    
    
    # TODO 5: Calculate statistics
    
    
    # TODO 6: Generate summary report
    puts "Power Analysis Summary"
    puts "=====================\n"
    puts "Total Power: ??? mW"
    puts "\nBreakdown:"
    puts "  Dynamic: ??? mW (???%)"
    puts "  Leakage: ??? mW (???%)"
    puts "  Static:  ??? mW (???%)"
    puts "\nTop 5 Power Consumers:"
    # foreach consumer $top5 { ... }
    
    
    # TODO 7: Identify optimization opportunities
    puts "\nOptimization Suggestions:"
    # if {dynamic > 50%} { puts "- Consider clock gating" }

