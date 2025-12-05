# Lesson 05: File Operations in TCL

## Table of Contents
1. Introduction to File I/O
2. Opening Files
3. Reading Files
4. Writing Files
5. Closing Files
6. File Existence and Properties
7. Directory Operations
8. Reading Files Line by Line
9. Processing Configuration Files
10. Parsing Verilog Files
11. Parsing Liberty Files
12. Writing Reports
13. Error Handling
14. Best Practices
15. Practice Exercises

---

## 1. Introduction to File I/O

### Why File Operations? 📁

In Physical Design, you constantly work with files:
- **Verilog** netlists (.v) 🔌
- **Liberty** timing libraries (.lib) ⏱️
- **SDC** constraints (.sdc) ⚙️
- **DEF** layout files (.def) 📐
- **SPEF** parasitics (.spef) 📊
- **Reports** (.rpt, .txt) 📋
- **Scripts** (.tcl) 🔧

### Basic File Operations Flow 🔄

    1. Open file    → get file handle
    2. Read/Write   → process data
    3. Close file   → release handle

---

## 2. Opening Files

### Open Command Syntax 🔓

    set file_handle [open filename mode]

### File Access Modes 📝

| Mode | Description | File must exist? | Overwrites? |
|------|-------------|------------------|-------------|
| r | Read only | Yes ✅ | No |
| w | Write (create/overwrite) | No | Yes ⚠️ |
| a | Append | No | No |
| r+ | Read and write | Yes ✅ | No |
| w+ | Read and write (create) | No | Yes ⚠️ |
| a+ | Read and append | No | No |

### Example: Open for Reading 📖

    set fh [open "design.v" r]
    # ... read operations ...
    close $fh

### Example: Open for Writing ✍️

    set fh [open "report.txt" w]
    puts $fh "Timing Report"
    puts $fh "============="
    close $fh

### Example: Open for Appending ➕

    set fh [open "log.txt" a]
    puts $fh "[clock format [clock seconds]]: Script started"
    close $fh

---

## 3. Reading Files

### Read Entire File 📚

    set fh [open "config.txt" r]
    set content [read $fh]
    close $fh
    puts $content

Example file config.txt:

    clock_period 10.0
    input_delay 0.5
    output_delay 0.3

Output: entire file content as one string ✅

### Read Specific Number of Bytes 🔢

    set fh [open "data.bin" r]
    set chunk [read $fh 100]
    close $fh

Reads exactly 100 bytes from file.

### Read One Line 📄

    set fh [open "pins.txt" r]
    set line [gets $fh]
    puts "First line: $line"
    close $fh

### Read Line by Line (Loop) 🔁

    set fh [open "netlist.v" r]
    while {[gets $fh line] >= 0} {
        puts "Line: $line"
    }
    close $fh

**Important**: gets returns ⚠️
- Number of characters read (≥ 0) if successful ✅
- -1 if end of file reached 🛑

---

## 4. Writing Files

### Write String to File ✍️

    set fh [open "output.txt" w]
    puts $fh "Hello, World!"
    close $fh

### Write Without Newline 📝

    set fh [open "data.txt" w]
    puts -nonewline $fh "No newline here"
    puts $fh " - continued"
    close $fh

Result in file:

    No newline here - continued

### Write Formatted Output 📊

    set fh [open "timing.rpt" w]
    puts $fh "================================"
    puts $fh "      TIMING REPORT"
    puts $fh "================================"
    puts $fh ""
    puts $fh [format "%-20s %10s" "Path" "Slack"]
    puts $fh [format "%-20s %10s" "----" "-----"]
    puts $fh [format "%-20s %10.2f" "clk->Q" 0.123]
    puts $fh [format "%-20s %10.2f" "input->output" -0.050]
    close $fh

Result in timing.rpt:

    ================================
          TIMING REPORT
    ================================
    
    Path                      Slack
    ----                      -----
    clk->Q                     0.12
    input->output             -0.05

Beautiful formatted report! 🎨

---

## 5. Closing Files

### Close Command 🔒

    close $file_handle

### Why Close Files? 🤔

- Release system resources 💾
- Ensure data is written (flushed) 💿
- Prevent file corruption 🛡️
- Avoid "too many open files" error ⚠️

### Force Flush Without Closing 🚀

    set fh [open "log.txt" w]
    puts $fh "Line 1"
    flush $fh
    puts $fh "Line 2"
    close $fh

Flush forces immediate write to disk! 💿

---

## 6. File Existence and Properties

### Check if File Exists ✅

    if {[file exists "design.v"]} {
        puts "File exists!"
    } else {
        puts "File not found!"
    }

### Check File Type 📋

    if {[file isfile "data.txt"]} {
        puts "Regular file"
    }
    
    if {[file isdirectory "libs"]} {
        puts "Directory"
    }

### Get File Size 📏

    set size [file size "netlist.v"]
    puts "File size: $size bytes"

### Get File Modification Time 🕐

    set mtime [file mtime "design.v"]
    puts "Last modified: [clock format $mtime]"

### Get File Extension 🏷️

    set ext [file extension "design.v"]
    puts "Extension: $ext"

Output: .v

### Get Filename Without Path 📄

    set filename [file tail "/home/user/design.v"]
    puts $filename

Output: design.v

### Get Directory Name 📂

    set dir [file dirname "/home/user/design.v"]
    puts $dir

Output: /home/user

### Get Absolute Path 🗺️

    set abs [file normalize "../design.v"]
    puts $abs

Output: /full/path/to/design.v

---

## 7. Directory Operations

### List Files in Directory 📂

    set files [glob "*.v"]
    foreach f $files {
        puts "Verilog file: $f"
    }

### List All Files (including subdirectories) 🗂️

    set all_files [glob -nocomplain *]
    foreach f $all_files {
        if {[file isfile $f]} {
            puts "File: $f"
        } elseif {[file isdirectory $f]} {
            puts "Dir: $f"
        }
    }

### Create Directory 🏗️

    file mkdir "reports"
    file mkdir "results/timing"

Creates nested directories automatically! ✅

### Delete File 🗑️

    if {[file exists "old_report.txt"]} {
        file delete "old_report.txt"
    }

### Copy File 📋

    file copy "design.v" "design_backup.v"

### Rename/Move File 🔄

    file rename "old_name.v" "new_name.v"

---

## 8. Reading Files Line by Line

### Pattern 1: Process Each Line 🔁

    proc process_file {filename} {
        set fh [open $filename r]
        set line_num 0
        
        while {[gets $fh line] >= 0} {
            incr line_num
            puts "Line $line_num: $line"
        }
        
        close $fh
        puts "Total lines: $line_num"
    }
    
    process_file "data.txt"

### Pattern 2: Search for Pattern 🔍

    proc find_in_file {filename pattern} {
        set fh [open $filename r]
        set matches {}
        set line_num 0
        
        while {[gets $fh line] >= 0} {
            incr line_num
            if {[string match "*$pattern*" $line]} {
                lappend matches [list $line_num $line]
            }
        }
        
        close $fh
        return $matches
    }
    
    set results [find_in_file "netlist.v" "input"]
    foreach match $results {
        set num [lindex $match 0]
        set text [lindex $match 1]
        puts "Line $num: $text"
    }

### Pattern 3: Parse Structured File 📊

    proc parse_config {filename} {
        set fh [open $filename r]
        array set config {}
        
        while {[gets $fh line] >= 0} {
            set line [string trim $line]
            if {$line eq "" || [string index $line 0] eq "#"} {
                continue
            }
            
            set parts [split $line]
            if {[llength $parts] == 2} {
                set key [lindex $parts 0]
                set value [lindex $parts 1]
                set config($key) $value
            }
        }
        
        close $fh
        return [array get config]
    }

Example config.txt file:

    clock_period 10.0
    # This is a comment
    input_delay 0.5

Usage:

    array set cfg [parse_config "config.txt"]
    puts "Clock period: $cfg(clock_period)"

---

## 9. Processing Configuration Files

### Example: Read SDC-like Constraints ⚙️

File constraints.sdc:

    create_clock -period 10.0 clk
    set_input_delay 0.5 -clock clk [all_inputs]
    set_output_delay 0.3 -clock clk [all_outputs]

Parser procedure:

    proc parse_sdc {filename} {
        set fh [open $filename r]
        
        while {[gets $fh line] >= 0} {
            set line [string trim $line]
            
            if {[string match "create_clock*" $line]} {
                if {[regexp {-period\s+(\S+)} $line match period]} {
                    puts "Clock period: $period ns"
                }
            } elseif {[string match "set_input_delay*" $line]} {
                if {[regexp {set_input_delay\s+(\S+)} $line match delay]} {
                    puts "Input delay: $delay ns"
                }
            }
        }
        
        close $fh
    }
    
    parse_sdc "constraints.sdc"

Output:

    Clock period: 10.0 ns
    Input delay: 0.5 ns

---

## 10. Parsing Verilog Files

### Example: Extract Module Ports 🔌

File counter.v:

    module counter (
        input clk,
        input rst,
        input enable,
        output reg [7:0] count
    );
        // ... module body ...
    endmodule

Parser procedure:

    proc parse_verilog_ports {filename} {
        set fh [open $filename r]
        set in_module 0
        set ports {}
        
        while {[gets $fh line] >= 0} {
            set line [string trim $line]
            
            if {[string match "module*" $line]} {
                set in_module 1
                continue
            }
            
            if {$in_module && [string match "*);*" $line]} {
                break
            }
            
            if {$in_module} {
                if {[regexp {(input|output|inout)\s+(.+)} $line match dir rest]} {
                    set port_name [lindex [split $rest] end]
                    set port_name [string trim $port_name ","]
                    lappend ports [list $dir $port_name]
                }
            }
        }
        
        close $fh
        return $ports
    }
    
    set ports [parse_verilog_ports "counter.v"]
    foreach port $ports {
        set dir [lindex $port 0]
        set name [lindex $port 1]
        puts "$dir: $name"
    }

Output:

    input: clk
    input: rst
    input: enable
    output: count

Perfect port extraction! ✅

---

## 11. Parsing Liberty Files

### Example: Extract Cell Timing Info ⏱️

File cells.lib (simplified):

    cell(INV_X1) {
        area : 2.5;
        pin(A) {
            direction : input;
            capacitance : 0.01;
        }
        pin(Y) {
            direction : output;
            timing() {
                related_pin : "A";
                cell_rise : 0.05;
                cell_fall : 0.04;
            }
        }
    }

Parser procedure:

    proc parse_liberty_cell {filename cell_name} {
        set fh [open $filename r]
        set in_cell 0
        array set cell_info {}
        
        while {[gets $fh line] >= 0} {
            set line [string trim $line]
            
            if {[string match "cell($cell_name)*" $line]} {
                set in_cell 1
                continue
            }
            
            if {$in_cell && [string match "*area*" $line]} {
                regexp {area\s*:\s*([0-9.]+)} $line match area
                set cell_info(area) $area
            }
            
            if {$in_cell && [string match "*cell_rise*" $line]} {
                regexp {cell_rise\s*:\s*([0-9.]+)} $line match rise
                set cell_info(rise_delay) $rise
            }
            
            if {$in_cell && [string match "*cell_fall*" $line]} {
                regexp {cell_fall\s*:\s*([0-9.]+)} $line match fall
                set cell_info(fall_delay) $fall
            }
            
            if {$in_cell && $line eq "\}"} {
                break
            }
        }
        
        close $fh
        return [array get cell_info]
    }
    
    array set info [parse_liberty_cell "cells.lib" "INV_X1"]
    puts "Cell: INV_X1"
    puts "  Area: $info(area)"
    puts "  Rise delay: $info(rise_delay) ns"
    puts "  Fall delay: $info(fall_delay) ns"

Output:

    Cell: INV_X1
      Area: 2.5
      Rise delay: 0.05 ns
      Fall delay: 0.04 ns

---

## 12. Writing Reports

### Example: Timing Report Generator 📊

    proc write_timing_report {filename paths} {
        set fh [open $filename w]
        
        puts $fh "========================================"
        puts $fh "         TIMING ANALYSIS REPORT"
        puts $fh "========================================"
        puts $fh "Generated: [clock format [clock seconds]]"
        puts $fh ""
        
        puts $fh [format "%-30s %10s %10s" "Path" "Delay(ns)" "Slack(ns)"]
        puts $fh [string repeat "-" 52]
        
        set violations 0
        foreach path $paths {
            set name [lindex $path 0]
            set delay [lindex $path 1]
            set slack [lindex $path 2]
            
            puts $fh [format "%-30s %10.3f %10.3f" $name $delay $slack]
            
            if {$slack < 0} {
                incr violations
            }
        }
        
        puts $fh ""
        puts $fh "========================================"
        puts $fh "Total paths: [llength $paths]"
        puts $fh "Violations: $violations"
        puts $fh "========================================"
        
        close $fh
    }

Usage example:

    set timing_paths {
        {"clk->reg1/D" 2.5 0.3}
        {"reg1/Q->reg2/D" 4.2 -0.1}
        {"input->output" 3.1 0.5}
    }
    
    write_timing_report "timing.rpt" $timing_paths

Output file timing.rpt:

    ========================================
             TIMING ANALYSIS REPORT
    ========================================
    Generated: Mon Jan 15 10:30:45 PST 2024
    
    Path                           Delay(ns)  Slack(ns)
    ----------------------------------------------------
    clk->reg1/D                        2.500      0.300
    reg1/Q->reg2/D                     4.200     -0.100
    input->output                      3.100      0.500
    
    ========================================
    Total paths: 3
    Violations: 1
    ========================================

Professional report formatting! 🎨

---

## 13. Error Handling

### Catch File Errors 🛡️

    if {[catch {open "missing.txt" r} fh]} {
        puts "ERROR: Cannot open file: $fh"
    } else {
        set content [read $fh]
        close $fh
        puts $content
    }

### Safe File Operations Procedure 🔒

    proc safe_read_file {filename} {
        if {![file exists $filename]} {
            puts "ERROR: File '$filename' not found"
            return ""
        }
        
        if {[catch {open $filename r} fh]} {
            puts "ERROR: Cannot open '$filename': $fh"
            return ""
        }
        
        if {[catch {read $fh} content]} {
            puts "ERROR: Cannot read '$filename': $content"
            close $fh
            return ""
        }
        
        close $fh
        return $content
    }
    
    set data [safe_read_file "config.txt"]
    if {$data ne ""} {
        puts "File read successfully"
    }

### Using try-finally (TCL 8.6+) 🎯

    set fh [open "data.txt" r]
    try {
        set content [read $fh]
    } finally {
        close $fh
    }

The finally block ALWAYS executes! ✅

---

## 14. Best Practices

### ✅ Always Close Files

**Bad** ❌:

    set fh [open "file.txt" r]
    set data [read $fh]

**Good** ✅:

    set fh [open "file.txt" r]
    set data [read $fh]
    close $fh

### ✅ Check File Existence First

    if {[file exists $filename]} {
        set fh [open $filename r]
        close $fh
    }

### ✅ Use Meaningful File Handles

**Bad** ❌:

    set f [open "a.txt" r]
    set f2 [open "b.txt" w]

**Good** ✅:

    set input_fh [open "design.v" r]
    set output_fh [open "report.txt" w]

### ✅ Handle Errors Gracefully

    if {[catch {open $file r} fh]} {
        puts "ERROR: $fh"
        return
    }

### ✅ Use Proper File Modes

- Read only? Use r 📖
- Append log? Use a ➕
- Create report? Use w ✍️

---

## 15. Practice Exercises

### Exercise 1: Line Counter 📏

Write a procedure to count lines in a file:

    proc count_lines {filename} {
        # TODO: Return number of lines
        # Handle file not found error
    }
    
    puts [count_lines "design.v"]

Expected output for 100-line file:

    100

### Exercise 2: Word Frequency 📊

Count word occurrences in file:

    proc word_frequency {filename} {
        # TODO: Return array with word counts
        # Ignore case
    }
    
    array set freq [word_frequency "text.txt"]
    foreach {word count} [array get freq] {
        puts "$word: $count"
    }

Expected output:

    module: 15
    input: 8
    output: 5
    wire: 23

### Exercise 3: Find and Replace 🔄

Replace all occurrences of a string in file:

    proc replace_in_file {filename old new} {
        # TODO: Read file, replace string, write back
    }
    
    replace_in_file "netlist.v" "old_clock" "new_clock"

### Exercise 4: Merge Files 🔗

Concatenate multiple files:

    proc merge_files {output_file input_files} {
        # TODO: Combine all input files into output
    }
    
    merge_files "combined.v" {module1.v module2.v module3.v}

### Exercise 5: Extract Statistics 📈

Analyze Verilog file:

    proc verilog_stats {filename} {
        # TODO: Count:
        # - Total lines
        # - Comment lines (starting with //)
        # - Blank lines
        # - input ports
        # - output ports
        # - wire declarations
        # - reg declarations
    }
    
    verilog_stats "design.v"

Expected output:

    Total lines: 250
    Comments: 45
    Blank lines: 30
    Input ports: 8
    Output ports: 5
    Wires: 32
    Registers: 15

### Exercise 6: Config File Reader ⚙️

Parse key-value config file:

    proc read_config {filename} {
        # TODO: Parse format:
        # key = value
        # Support # comments
        # Return array
    }
    
    array set config [read_config "setup.cfg"]
    puts "Clock: $config(clock_period)"

Config file example setup.cfg:

    # Timing configuration
    clock_period = 10.0
    input_delay = 0.5
    
    # Power settings
    voltage = 1.0

### Exercise 7: Log File Analyzer 📋

Parse log file for errors/warnings:

    proc analyze_log {filename} {
        # TODO: Count ERROR and WARNING keywords
        # Print summary
    }
    
    analyze_log "synthesis.log"

Expected output:

    Log Analysis
    ============
    Total lines: 1523
    Errors: 3
    Warnings: 17
    
    Errors found at lines: 45, 234, 890

### Exercise 8: CSV to TCL List 📄

Convert CSV file to nested list:

    proc parse_csv {filename} {
        # TODO: Read CSV, return nested list
        # Handle quoted fields
    }
    
    set data [parse_csv "cells.csv"]
    foreach row $data {
        puts "Cell: [lindex $row 0], Area: [lindex $row 1]"
    }

CSV example cells.csv:

    cell_name,area,delay
    INV_X1,2.5,0.05
    NAND2_X1,4.0,0.08

Expected output:

    Cell: INV_X1, Area: 2.5
    Cell: NAND2_X1, Area: 4.0

---

## Summary Cheat Sheet

### File Operations 🗂️

| Operation | Command | Example |
|-----------|---------|---------|
| Open | open file mode | set fh [open "f.txt" r] |
| Read all | read $fh | set data [read $fh] |
| Read line | gets $fh var | gets $fh line |
| Write | puts $fh text | puts $fh "Hello" |
| Close | close $fh | close $fh |
| Exists? | file exists $file | if {[file exists "f.txt"]} |
| Size | file size $file | set sz [file size "f.txt"] |
| Delete | file delete $file | file delete "old.txt" |
| Copy | file copy $src $dst | file copy "a.txt" "b.txt" |
| List files | glob pattern | set files [glob *.v] |
| Make dir | file mkdir $dir | file mkdir "results" |

### Common Patterns 🎯

**Read entire file:**

    set fh [open $file r]
    set content [read $fh]
    close $fh

**Read line by line:**

    set fh [open $file r]
    while {[gets $fh line] >= 0} {
        # Process $line
    }
    close $fh

**Write report:**

    set fh [open $file w]
    puts $fh "Header"
    puts $fh [format "%-20s %10s" "Name" "Value"]
    close $fh

**Safe operation:**

    if {[catch {open $file r} fh]} {
        puts "Error: $fh"
    } else {
        # Use $fh
        close $fh
    }

---

## What's Next? 🚀

In Lesson 06 you will learn:

- Array basics and operations 📦
- Dictionary operations (TCL 8.5+) 📖
- Nested data structures 🏗️
- Data structure selection 🎯
- Hash tables for fast lookup ⚡
- Storing timing/power/area data 📊
- Physical design database patterns 🗄️

Ready to proceed? ✅

Complete the exercises above first, then move to:

    06_arrays_dicts.md

---

Good luck with your practice! 💪

