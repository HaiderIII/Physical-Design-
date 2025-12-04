# netlist_analysis.tcl
# Phase 2 — Netlist Literacy
# Purpose: understand what a netlist contains and how to reason about it
# using Tcl at text level (no EDA tool, no STA engine).

# ------------------------------------------------------------
# DEFINITIONS (applied in this script)
#
# - Instance :
#   A concrete occurrence of a cell type in the design.
#   Syntax: <CellType> <InstanceName> ( ... );
#
# - Type :
#   The logical/physical class of the instance (AND2, INV, DFF, etc.).
#
# - Net :
#   A named electrical connection that links pins.
#
# - Driver :
#   The pin that produces the signal on a net.
#
# - Load :
#   Any pin that receives the signal from a net.
#
# - Combinational :
#   Logic with no memory, no clock dependency.
#
# - Sequential :
#   Logic with state, clocked (flip-flops, latches).
#
# ------------------------------------------------------------

# Netlist file to analyze
set netlist_file "/home/faiz/projects/Physical-Design-/phase_02_netlist_literacy/netlists/simple_structural.v"

# ------------------------------------------------------------
# STEP 1 — Read netlist file
# ------------------------------------------------------------

# open: opens a file handle
# r   : read mode
set fh [open $netlist_file r]

# read entire file into a string
set netlist_data [read $fh]

# close file handle
close $fh

# Split file into individual lines
set lines [split $netlist_data "\n"]

# ------------------------------------------------------------
# STEP 2 — Extract instances
# ------------------------------------------------------------
# Instance lines usually contain:
# <CellType> <InstanceName> ( ... );

puts "=== Instances ==="

foreach line $lines {

    # Trim whitespace
    set line [string trim $line]

    # Skip empty lines
    if {$line eq ""} {
        continue
    }

    # Very simple pattern:
    # line starting with a word (cell type) followed by instance name
    if {[regexp {^([A-Z0-9_]+)\s+(U[0-9]+)} $line match type inst]} {
        puts "Instance: $inst | Type: $type"
    }
}

# ------------------------------------------------------------
# STEP 3 — Extract nets
# ------------------------------------------------------------
# Nets are declared as:
# wire <net_name>;

puts "\n=== Nets ==="

foreach line $lines {
    set line [string trim $line]

    if {[regexp {^wire\s+([a-zA-Z0-9_]+)} $line match net]} {
        puts "Net: $net"
    }
}

# ------------------------------------------------------------
# STEP 4 — Identify combinational vs sequential instances
# ------------------------------------------------------------
# Heuristic:
# - DFF, LATCH → sequential
# - AND, OR, INV → combinational

puts "\n=== Instance Classification ==="

foreach line $lines {
    set line [string trim $line]

    if {[regexp {^([A-Z0-9_]+)\s+(U[0-9]+)} $line match type inst]} {

        if {[string match *FF* $type]} {
            puts "Instance $inst is SEQUENTIAL (type: $type)"
        } else {
            puts "Instance $inst is COMBINATIONAL (type: $type)"
        }
    }
}

# ------------------------------------------------------------
# STEP 5 — Conceptual driver/load reasoning (commentary)
# ------------------------------------------------------------
# This script does NOT fully extract drivers and loads.
# That requires semantic parsing of pin directions.
#
# However, conceptually:
# - Outputs of instances are drivers
# - Inputs of instances are loads
# - Q of FF is a driver
# - D of FF is a load
#
# This mirrors how EDA tools reason internally.

puts "\n=== Conceptual Rules ==="
puts "Driver  : output pin of a cell or module input"
puts "Load    : input pin of a cell or module output"
puts "Sequential boundary: FF Q → FF D"

# ------------------------------------------------------------
# END
# ------------------------------------------------------------
