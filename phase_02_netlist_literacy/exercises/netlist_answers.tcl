# ------------------------------------------------------------
# netlist_answers.tcl
# Phase 2 — Netlist Literacy
#
# Goal:
# Read a structural netlist as a topology, not as code.
# No EDA tool. No simulation. Pure text-level reasoning.
# ------------------------------------------------------------

# ------------------------------------------------------------
# CONCEPT DEFINITIONS
# ------------------------------------------------------------
# Instance: Concrete occurrence of a cell type in the design.
# Type: Logical/physical class (AND2, INV, DFF, etc.)
# Net: Named electrical connection between pins.
# Driver: Pin producing signal (heuristic: Y or Q)
# Load: Pin consuming signal (heuristic: A, B, D)
# Combinational logic: no state, output depends on current inputs
# Sequential logic: contains state, clocked (flip-flops, latches)
# ------------------------------------------------------------

# ------------------------------------------------------------
# INPUT NETLIST
# ------------------------------------------------------------
set netlist_file "/home/faiz/projects/Physical-Design-/phase_02_netlist_literacy/netlists/simple_structural.v"

# Read file into memory
set fh [open $netlist_file r]
set netlist_data [read $fh]
close $fh
set lines [split $netlist_data "\n"]

# ------------------------------------------------------------
# STEP 1 — STRUCTURES
# ------------------------------------------------------------
array set instances {}   ;# key=inst_name, value=cell_type
array set seq_flags {}   ;# key=inst_name, value=1 sequential, 0 combinational
array set nets {}        ;# key=net_name, value=driver
array set loads {}       ;# key=net_name, value=list of loads

# ------------------------------------------------------------
# STEP 2 — EXTRACT INSTANCES
# ------------------------------------------------------------
puts "=== INSTANCES ==="
foreach line $lines {
    set line [string trim $line]
    if {$line eq ""} { continue }

    if {[regexp {^([A-Z0-9_]+)\s+(U[0-9]+)} $line match cell_type inst_name]} {
        puts "Instance: $inst_name | Type: $cell_type"
        set instances($inst_name) $cell_type
        if {[string match *FF* $cell_type]} {
            set seq_flags($inst_name) 1
        } else {
            set seq_flags($inst_name) 0
        }
    }
}

# ------------------------------------------------------------
# STEP 3 — EXTRACT NETS
# ------------------------------------------------------------
puts "\n=== NETS ==="
foreach line $lines {
    set line [string trim $line]
    if {$line eq ""} { continue }

    if {[regexp {^wire\s+([a-zA-Z0-9_]+)} $line match net_name]} {
        puts "Net: $net_name"
        set nets($net_name) ""
        set loads($net_name) ""
    }
}

# ------------------------------------------------------------
# STEP 4 — DRIVER / LOAD APPROXIMATION
# ------------------------------------------------------------
foreach line $lines {
    set line [string trim $line]
    if {[regexp {^([A-Z0-9_]+)\s+(U[0-9]+)\s*\((.*)\);} $line match type inst pin_list]} {
        set pins [split $pin_list ","]
        foreach pin $pins {
            set pin [string trim $pin]
            if {[regexp {\.(\w+)\((\w+)\)} $pin _ pin_name net]} {
                # Ensure arrays exist
                if {![info exists nets($net)]} { set nets($net) "" }
                if {![info exists loads($net)]} { set loads($net) {} }

                if {$pin_name eq "Y" || $pin_name eq "Q"} {
                    set nets($net) "$pin_name from $inst"
                } else {
                    lappend loads($net) "$pin_name from $inst"
                }
            }
        }
    }
}

puts "\n=== DRIVER / LOAD PER NET ==="
foreach net [array names nets] {
    if {[info exists nets($net)]} {
        set drv $nets($net)
    } else { set drv "" }
    if {[info exists loads($net)]} {
        set lds $loads($net)
    } else { set lds "" }
    puts "Net: $net | Driver: $drv | Loads: $lds"
}

# ------------------------------------------------------------
# STEP 5 — LOGIC CLASSIFICATION
# ------------------------------------------------------------
puts "\n=== LOGIC CLASSIFICATION ==="
foreach inst [array names instances] {
    if {$seq_flags($inst)} {
        puts "Sequential Instance: $inst | Type: $instances($inst)"
    } else {
        puts "Combinational Instance: $inst | Type: $instances($inst)"
    }
}

puts "\nSequential boundary:"
puts "Combinational: AND2 U1, INV U2"
puts "Sequential: DFF U3 (D receives combinational net, clocked by clk)"

# ------------------------------------------------------------
# STEP 6 — PRIMARY INPUTS / OUTPUTS
# ------------------------------------------------------------
puts "\n=== PRIMARY INPUTS / OUTPUTS ==="
puts "Inputs: clk, a, b"
puts "Output: y"

# ------------------------------------------------------------
# STEP 7 — LOGICAL DIRECTED GRAPH
# ------------------------------------------------------------
puts "\n=== DIRECTED GRAPH (logical) ==="
puts "a,b -> U1 --n1--> U2 --n2--> U3 -> y"

# ------------------------------------------------------------
# STEP 8 — TIMING PATH CATEGORIES
# ------------------------------------------------------------
puts "\n=== TIMING PATHS ==="
puts "IN -> FF : a/b -> U1 -> U2 -> U3 D"
puts "FF -> FF : none"
puts "FF -> OUT: U3 Q -> y"
puts "Explanation: IN->FF checks input arrival; FF->FF requires launch/capture checks; FF->OUT checks output timing to primary output."
