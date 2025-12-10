# ==============================================================================
# MASTER SCRIPT: Run all 3 corners sequentially
# ==============================================================================

puts "\n============================================================"
puts "MULTI-CORNER TIMING ANALYSIS - ALL CORNERS"
puts "Circuit: 3-Stage Pipeline (FF1 → FF2 → FF3)"
puts "============================================================\n"

set RESOURCES_DIR "phases/phase_00_foundations/resources/lesson06_opensta/ex5_multi_corner"

# ==============================================================================
# CORNER 1: SLOW (SS, 0.9V, 125°C)
# ==============================================================================
puts "\n=========================================="
puts "CORNER 1/3: SLOW (SS, 0.9V, 125°C)"
puts "==========================================\n"

read_liberty $RESOURCES_DIR/multi_corner_slow.lib
read_verilog $RESOURCES_DIR/multi_corner_pipeline.v
link_design multi_corner_pipeline
read_sdc $RESOURCES_DIR/constraints.sdc

puts "--- SETUP TIMING ---"
report_checks -path_delay max -format full_clock_expanded

puts "\n--- HOLD TIMING ---"
report_checks -path_delay min -format full_clock_expanded

puts "\n--- WORST SLACK (SLOW) ---"
report_worst_slack -max
report_worst_slack -min

# Save slack values for comparison
set slow_setup [sta::worst_slack -max]
set slow_hold [sta::worst_slack -min]

# Clear design for next corner
delete_from_memory -all

# ==============================================================================
# CORNER 2: TYPICAL (TT, 1.0V, 25°C)
# ==============================================================================
puts "\n=========================================="
puts "CORNER 2/3: TYPICAL (TT, 1.0V, 25°C)"
puts "==========================================\n"

read_liberty $RESOURCES_DIR/multi_corner_typical.lib
read_verilog $RESOURCES_DIR/multi_corner_pipeline.v
link_design multi_corner_pipeline
read_sdc $RESOURCES_DIR/constraints.sdc

puts "--- SETUP TIMING ---"
report_checks -path_delay max -format full_clock_expanded

puts "\n--- HOLD TIMING ---"
report_checks -path_delay min -format full_clock_expanded

puts "\n--- WORST SLACK (TYPICAL) ---"
report_worst_slack -max
report_worst_slack -min

# Save slack values
set typical_setup [sta::worst_slack -max]
set typical_hold [sta::worst_slack -min]

# Clear design for next corner
delete_from_memory -all

# ==============================================================================
# CORNER 3: FAST (FF, 1.1V, 0°C)
# ==============================================================================
puts "\n=========================================="
puts "CORNER 3/3: FAST (FF, 1.1V, 0°C)"
puts "==========================================\n"

read_liberty $RESOURCES_DIR/multi_corner_fast.lib
read_verilog $RESOURCES_DIR/multi_corner_pipeline.v
link_design multi_corner_pipeline
read_sdc $RESOURCES_DIR/constraints.sdc

puts "--- SETUP TIMING ---"
report_checks -path_delay max -format full_clock_expanded

puts "\n--- HOLD TIMING ---"
report_checks -path_delay min -format full_clock_expanded

puts "\n--- WORST SLACK (FAST) ---"
report_worst_slack -max
report_worst_slack -min

# Save slack values
set fast_setup [sta::worst_slack -max]
set fast_hold [sta::worst_slack -min]

# ==============================================================================
# COMPARATIVE SUMMARY TABLE
# ==============================================================================
puts "\n============================================================"
puts "MULTI-CORNER SLACK COMPARISON"
puts "============================================================\n"

puts [format "%-12s | %-15s | %-15s" "Corner" "Setup Slack" "Hold Slack"]
puts "-------------|-----------------|------------------"
puts [format "%-12s | %+14.2f ns | %+14.2f ns" "SLOW" $slow_setup $slow_hold]
puts [format "%-12s | %+14.2f ns | %+14.2f ns" "TYPICAL" $typical_setup $typical_hold]
puts [format "%-12s | %+14.2f ns | %+14.2f ns" "FAST" $fast_setup $fast_hold]

puts "\n============================================================"
puts "EXPECTED CORNER CHARACTERISTICS"
puts "============================================================\n"

puts "┌─────────────┬──────────────┬────────────┬──────────────┐"
puts "│   Corner    │ Process/V/T  │ Delay      │ Critical For │"
puts "├─────────────┼──────────────┼────────────┼──────────────┤"
puts "│ SLOW        │ SS/0.9V/125°C│ LONGEST    │ SETUP        │"
puts "│ TYPICAL     │ TT/1.0V/25°C │ NOMINAL    │ BOTH         │"
puts "│ FAST        │ FF/1.1V/0°C  │ SHORTEST   │ HOLD         │"
puts "└─────────────┴──────────────┴────────────┴──────────────┘"
puts ""

puts "KEY OBSERVATIONS:"
puts "  ✓ SLOW corner  → Smallest setup slack (worst case for max delay)"
puts "  ✓ FAST corner  → Smallest hold slack (worst case for min delay)"
puts "  ✓ TYPICAL corner → Nominal conditions"
puts ""
puts "  ⚠️  Design MUST pass ALL corners for tape-out!"
puts ""

# Determine worst corners
if {$slow_setup < $typical_setup && $slow_setup < $fast_setup} {
    puts "  🔴 SETUP: Worst in SLOW corner ([format %.2f $slow_setup] ns) ← CRITICAL"
} elseif {$typical_setup < $fast_setup} {
    puts "  🟡 SETUP: Worst in TYPICAL corner ([format %.2f $typical_setup] ns)"
} else {
    puts "  🟢 SETUP: Worst in FAST corner ([format %.2f $fast_setup] ns)"
}

if {$fast_hold < $typical_hold && $fast_hold < $slow_hold} {
    puts "  🔴 HOLD: Worst in FAST corner ([format %.2f $fast_hold] ns) ← CRITICAL"
} elseif {$typical_hold < $slow_hold} {
    puts "  🟡 HOLD: Worst in TYPICAL corner ([format %.2f $typical_hold] ns)"
} else {
    puts "  🟢 HOLD: Worst in SLOW corner ([format %.2f $slow_hold] ns)"
}

puts "\n============================================================\n"

# Pass/Fail analysis
set all_pass 1
if {$slow_setup < 0} {
    puts "❌ SETUP VIOLATION in SLOW corner: [format %.2f $slow_setup] ns"
    set all_pass 0
}
if {$typical_setup < 0} {
    puts "❌ SETUP VIOLATION in TYPICAL corner: [format %.2f $typical_setup] ns"
    set all_pass 0
}
if {$fast_setup < 0} {
    puts "❌ SETUP VIOLATION in FAST corner: [format %.2f $fast_setup] ns"
    set all_pass 0
}
if {$slow_hold < 0} {
    puts "❌ HOLD VIOLATION in SLOW corner: [format %.2f $slow_hold] ns"
    set all_pass 0
}
if {$typical_hold < 0} {
    puts "❌ HOLD VIOLATION in TYPICAL corner: [format %.2f $typical_hold] ns"
    set all_pass 0
}
if {$fast_hold < 0} {
    puts "❌ HOLD VIOLATION in FAST corner: [format %.2f $fast_hold] ns"
    set all_pass 0
}

if {$all_pass} {
    puts "✅ ALL CORNERS PASS! Design is ready for tape-out.\n"
} else {
    puts "⚠️  TIMING VIOLATIONS DETECTED! Needs fixing.\n"
}

puts "📁 Full report saved to: ex5_all_corners_output.log\n"
