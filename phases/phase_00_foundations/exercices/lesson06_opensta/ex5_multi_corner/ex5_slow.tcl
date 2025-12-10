# ==============================================================================
# EXERCISE 5: MULTI-CORNER TIMING ANALYSIS
# ==============================================================================

puts "\n=========================================="
puts "EXERCISE 5: MULTI-CORNER TIMING ANALYSIS"
puts "Circuit: 3-Stage Pipeline (FF1 → FF2 → FF3)"
puts "==========================================\n"

# ==============================================================================
# SLOW CORNER ANALYSIS (SS, 0.9V, 125°C)
# ==============================================================================

puts "\n=========================================="
puts "CORNER: SLOW (SS, 0.9V, 125°C)"
puts "==========================================\n"

set RESOURCES_DIR "phases/phase_00_foundations/resources/lesson06_opensta/ex5_multi_corner"

puts "INFO: Loading library for SLOW (SS, 0.9V, 125°C)..."
read_liberty $RESOURCES_DIR/multi_corner_slow.lib
puts "✓ Library loaded\n"

puts "INFO: Reading Verilog netlist..."
read_verilog $RESOURCES_DIR/multi_corner_pipeline.v
link_design multi_corner_pipeline
puts "✓ Design linked\n"

puts "INFO: Applying SDC constraints..."
read_sdc $RESOURCES_DIR/constraints.sdc
puts "✓ Constraints applied\n"

puts "--- SETUP TIMING (Max Delay Analysis) ---"
report_checks -path_delay max -format full_clock_expanded

puts "\n--- HOLD TIMING (Min Delay Analysis) ---"
report_checks -path_delay min -format full_clock_expanded

puts "\n--- TOP 5 SETUP PATHS ---"
report_checks -path_delay max -format full_clock_expanded -path_group clk -group_count 5

puts "\n--- TOP 5 HOLD PATHS ---"
report_checks -path_delay min -format full_clock_expanded -path_group clk -group_count 5

puts "\n--- TIMING SUMMARY ---"
report_check_types -max_slew -max_capacitance -max_fanout -violators

puts "\n--- WORST SLACK (SETUP) ---"
report_worst_slack -max

puts "\n--- WORST SLACK (HOLD) ---"
report_worst_slack -min

puts "\n--- TNS (Total Negative Slack) ---"
report_tns

puts "\n--- WNS (Worst Negative Slack) ---"
report_wns

puts "\n✅ SLOW corner analysis completed!\n"

# ==============================================================================
# Create scripts for other corners
# ==============================================================================

puts "INFO: Creating analysis scripts for other corners...\n"

# TYPICAL corner script
set fp [open "phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_typical.tcl" w]
puts $fp "# TYPICAL CORNER ANALYSIS (TT, 1.0V, 25°C)"
puts $fp "puts \"\\n==========================================\""
puts $fp "puts \"CORNER: TYPICAL (TT, 1.0V, 25°C)\""
puts $fp "puts \"==========================================\\n\""
puts $fp "set RESOURCES_DIR \"phases/phase_00_foundations/resources/lesson06_opensta/ex5_multi_corner\""
puts $fp "read_liberty \$RESOURCES_DIR/multi_corner_typical.lib"
puts $fp "read_verilog \$RESOURCES_DIR/multi_corner_pipeline.v"
puts $fp "link_design multi_corner_pipeline"
puts $fp "read_sdc \$RESOURCES_DIR/constraints.sdc"
puts $fp "puts \"\\n--- SETUP TIMING ---\""
puts $fp "report_checks -path_delay max -format full_clock_expanded"
puts $fp "puts \"\\n--- HOLD TIMING ---\""
puts $fp "report_checks -path_delay min -format full_clock_expanded"
puts $fp "puts \"\\n--- WORST SLACK ---\""
puts $fp "report_worst_slack -max"
puts $fp "report_worst_slack -min"
puts $fp "puts \"\\n✅ TYPICAL corner completed!\\n\""
close $fp

# FAST corner script
set fp [open "phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_fast.tcl" w]
puts $fp "# FAST CORNER ANALYSIS (FF, 1.1V, 0°C)"
puts $fp "puts \"\\n==========================================\""
puts $fp "puts \"CORNER: FAST (FF, 1.1V, 0°C)\""
puts $fp "puts \"==========================================\\n\""
puts $fp "set RESOURCES_DIR \"phases/phase_00_foundations/resources/lesson06_opensta/ex5_multi_corner\""
puts $fp "read_liberty \$RESOURCES_DIR/multi_corner_fast.lib"
puts $fp "read_verilog \$RESOURCES_DIR/multi_corner_pipeline.v"
puts $fp "link_design multi_corner_pipeline"
puts $fp "read_sdc \$RESOURCES_DIR/constraints.sdc"
puts $fp "puts \"\\n--- SETUP TIMING ---\""
puts $fp "report_checks -path_delay max -format full_clock_expanded"
puts $fp "puts \"\\n--- HOLD TIMING ---\""
puts $fp "report_checks -path_delay min -format full_clock_expanded"
puts $fp "puts \"\\n--- WORST SLACK ---\""
puts $fp "report_worst_slack -max"
puts $fp "report_worst_slack -min"
puts $fp "puts \"\\n✅ FAST corner completed!\\n\""
close $fp

puts "✓ Created: ex5_typical.tcl"
puts "✓ Created: ex5_fast.tcl\n"

puts "\n=========================================="
puts "MULTI-CORNER ANALYSIS GUIDE"
puts "==========================================\n"

puts "To analyze other corners, run:"
puts "  sta -exit phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_typical.tcl 2>&1 | tee phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_typical_output.log"
puts ""
puts "  sta -exit phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_fast.tcl 2>&1 | tee phases/phase_00_foundations/exercices/lesson06_opensta/ex5_multi_corner/ex5_fast_output.log"
puts ""

puts "KEY OBSERVATIONS:"
puts "  • SLOW corner → Worst for SETUP (longest delays)"
puts "  • FAST corner → Worst for HOLD (shortest delays)"
puts "  • TYPICAL corner → Nominal conditions"
puts "  • Design must pass ALL corners for tape-out"
puts "==========================================\n"

puts "✅ Multi-corner analysis script completed!\n"
