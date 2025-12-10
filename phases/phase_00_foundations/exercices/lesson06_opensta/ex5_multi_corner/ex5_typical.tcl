# TYPICAL CORNER ANALYSIS (TT, 1.0V, 25°C)
puts "\n=========================================="
puts "CORNER: TYPICAL (TT, 1.0V, 25°C)"
puts "==========================================\n"
set RESOURCES_DIR "phases/phase_00_foundations/resources/lesson06_opensta/ex5_multi_corner"
read_liberty $RESOURCES_DIR/multi_corner_typical.lib
read_verilog $RESOURCES_DIR/multi_corner_pipeline.v
link_design multi_corner_pipeline
read_sdc $RESOURCES_DIR/constraints.sdc
puts "\n--- SETUP TIMING ---"
report_checks -path_delay max -format full_clock_expanded
puts "\n--- HOLD TIMING ---"
report_checks -path_delay min -format full_clock_expanded
puts "\n--- WORST SLACK ---"
report_worst_slack -max
report_worst_slack -min
puts "\n✅ TYPICAL corner completed!\n"
