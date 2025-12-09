# ==============================================================================
# Script: ex4_analysis.tcl
# Description: Clock uncertainty analysis - ALL timing paths
# ==============================================================================

puts "\n=========================================="
puts "EXERCISE 4: CLOCK UNCERTAINTY ANALYSIS"
puts "Circuit: d_in → FF1 → AND2 → FF2 → q_out"
puts "==========================================\n"

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
set RESOURCES_DIR "phases/phase_00_foundations/resources/lesson06_opensta"
set LIB_FILE "$RESOURCES_DIR/ex4_clock_uncertainty/clock_uncertainty.lib"
set VERILOG_FILE "$RESOURCES_DIR/ex4_clock_uncertainty/clock_uncertainty_ff2ff.v"
set SDC_FILE "$RESOURCES_DIR/ex4_clock_uncertainty/constraints.sdc"

# ------------------------------------------------------------------------------
# LOAD DESIGN
# ------------------------------------------------------------------------------
puts "INFO: Loading technology library..."
read_liberty $LIB_FILE
puts "✓ Library loaded: clock_uncertainty.lib\n"

set cells [get_lib_cells */*]
puts "Available cells: [join [lmap c $cells {get_name $c}] {, }]\n"

puts "INFO: Reading Verilog netlist..."
read_verilog $VERILOG_FILE
link_design clock_uncertainty_ff2ff
puts "✓ Design linked: clock_uncertainty_ff2ff\n"

puts "INFO: Applying SDC constraints..."
source $SDC_FILE
puts "✓ Constraints loaded (clock period = 10 ns)\n"

# ------------------------------------------------------------------------------
# HELPER PROCEDURE: Report timing with path enumeration
# ------------------------------------------------------------------------------
proc report_scenario {scenario_name uncertainty_ns} {
    puts "\n=========================================="
    puts "SCENARIO: $scenario_name (Uncertainty = $uncertainty_ns ns)"
    puts "==========================================\n"
    
    # Apply uncertainty
    set_clock_uncertainty -setup $uncertainty_ns [get_clocks clk]
    set_clock_uncertainty -hold $uncertainty_ns [get_clocks clk]
    
    # SETUP Analysis
    puts "--- SETUP TIMING (Critical Path) ---"
    report_checks -path_delay max -fields {slew cap input fanout} -format full_clock
    
    puts "\n--- ALL SETUP PATHS (Summary) ---"
    set setup_paths [find_timing_paths -path_delay max -sort_by_slack]
    if {[llength $setup_paths] > 0} {
        set path_num 1
        foreach path $setup_paths {
            set start [get_property $path startpoint]
            set end [get_property $path endpoint]
            set slack [get_property $path slack]
            puts [format "  Path %d: %-10s → %-10s  Slack: %7.3f ns %s" \
                $path_num \
                [get_name $start] \
                [get_name $end] \
                $slack \
                [expr {$slack < 0 ? "(VIOLATED)" : "(MET)"}]]
            incr path_num
        }
    } else {
        puts "  No setup paths found."
    }
    
    # HOLD Analysis
    puts "\n--- HOLD TIMING (Critical Path) ---"
    report_checks -path_delay min -fields {slew cap input fanout} -format full_clock
    
    puts "\n--- ALL HOLD PATHS (Summary) ---"
    set hold_paths [find_timing_paths -path_delay min -sort_by_slack]
    if {[llength $hold_paths] > 0} {
        set path_num 1
        foreach path $hold_paths {
            set start [get_property $path startpoint]
            set end [get_property $path endpoint]
            set slack [get_property $path slack]
            puts [format "  Path %d: %-10s → %-10s  Slack: %7.3f ns %s" \
                $path_num \
                [get_name $start] \
                [get_name $end] \
                $slack \
                [expr {$slack < 0 ? "(VIOLATED)" : "(MET)"}]]
            incr path_num
        }
    } else {
        puts "  No hold paths found."
    }
    
    puts ""
}

# ------------------------------------------------------------------------------
# RUN SCENARIOS
# ------------------------------------------------------------------------------
report_scenario "BASELINE" 0.0
report_scenario "LOW UNCERTAINTY" 0.2
report_scenario "MEDIUM UNCERTAINTY" 0.5
report_scenario "HIGH UNCERTAINTY" 1.0

# ------------------------------------------------------------------------------
# SUMMARY TABLE
# ------------------------------------------------------------------------------
puts "\n=========================================="
puts "SUMMARY: Clock Uncertainty Impact"
puts "==========================================\n"

puts [format "%-25s %-20s %-20s" "Scenario" "Setup Slack (ns)" "Hold Slack (ns)"]
puts [format "%-25s %-20s %-20s" "-------------------------" "--------------------" "--------------------"]

foreach {scenario unc} {
    "Baseline (0.0 ns)"        0.0
    "Low (0.2 ns)"             0.2
    "Medium (0.5 ns)"          0.5
    "High (1.0 ns)"            1.0
} {
    set_clock_uncertainty -setup $unc [get_clocks clk]
    set_clock_uncertainty -hold $unc [get_clocks clk]
    
    # Get worst setup slack
    set setup_paths [find_timing_paths -path_delay max -sort_by_slack]
    if {[llength $setup_paths] > 0} {
        set setup_slack [format "%.3f" [get_property [lindex $setup_paths 0] slack]]
    } else {
        set setup_slack "N/A"
    }
    
    # Get worst hold slack
    set hold_paths [find_timing_paths -path_delay min -sort_by_slack]
    if {[llength $hold_paths] > 0} {
        set hold_slack [format "%.3f" [get_property [lindex $hold_paths 0] slack]]
    } else {
        set hold_slack "N/A"
    }
    
    puts [format "%-25s %-20s %-20s" $scenario $setup_slack $hold_slack]
}

puts "\n=========================================="
puts "KEY OBSERVATIONS:"
puts "  • Setup slack DECREASES with uncertainty"
puts "  • Hold slack DECREASES with uncertainty"
puts "  • High uncertainty = stricter timing"
puts "==========================================\n"

puts "✅ Analysis completed successfully!\n"
