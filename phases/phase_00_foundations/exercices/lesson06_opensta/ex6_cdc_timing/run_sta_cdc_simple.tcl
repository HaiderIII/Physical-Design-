# Script OpenSTA - Analyse CDC Simple (Ex6)

puts "\n=========================================="
puts "  INITIALISATION OpenSTA - Ex6 CDC"
puts "=========================================="

set LIB_PATH    "phases/phase_00_foundations/resources/lesson06_opensta/ex6_cdc_simple/sky130_fd_sc_hd__tt_025C_1v80.lib"
set VERILOG_PATH "phases/phase_00_foundations/resources/lesson06_opensta/ex6_cdc_simple/design_cdc_simple.v"
set SDC_PATH    "phases/phase_00_foundations/resources/lesson06_opensta/ex6_cdc_simple/design_cdc_simple.sdc"

puts "\nChargement de la library : [file normalize $LIB_PATH]"
read_liberty $LIB_PATH

puts "Chargement du netlist : [file normalize $VERILOG_PATH]"
read_verilog $VERILOG_PATH
link_design cdc_simple

puts "Chargement des contraintes : [file normalize $SDC_PATH]"
read_sdc $SDC_PATH

puts "\n=========================================="
puts "  RAPPORT TIMING CDC - Ex6 Simple"
puts "=========================================="

puts "\n--- HORLOGES DEFINIES ---"
foreach clk [all_clocks] {
    set clk_name [get_property $clk full_name]
    set clk_period [get_property $clk period]
    puts "  $clk_name : Période = $clk_period ns"
}

puts "\n--- 1. CHEMIN D'ENTRÉE (data_in -> domain_a_ff) ---"
report_checks -from [get_ports data_in] -to [get_pins domain_a_ff/D] -path_delay max -format full_clock_expanded

puts "\n--- 2. CHEMIN CDC CROSSING (domain_a_ff -> sync_ff1) ---"
puts "    ⚠️  Chemins asynchrones - Utilisation de set_max_delay"
report_checks -from [get_pins domain_a_ff/Q] -to [get_pins sync_ff1/D] -path_delay max -format full_clock_expanded -unconstrained

puts "\n--- 3. SYNCHRONIZER Stage 1->2 (sync_ff1 -> sync_ff2) ---"
report_checks -from [get_pins sync_ff1/Q] -to [get_pins sync_ff2/D] -path_delay max -format full_clock_expanded

puts "\n--- 4. SYNCHRONIZER Stage 2->Out (sync_ff2 -> domain_b_ff) ---"
report_checks -from [get_pins sync_ff2/Q] -to [get_pins domain_b_ff/D] -path_delay max -format full_clock_expanded

puts "\n--- 5. CHEMIN DE SORTIE (domain_b_ff -> data_out) ---"
report_checks -from [get_pins domain_b_ff/Q] -to [get_ports data_out] -path_delay max -format full_clock_expanded

puts "\n=========================================="
puts "  RÉSUMÉ GLOBAL"
puts "=========================================="

puts "\n--- TOP 5 CHEMINS CRITIQUES (clk_slow) ---"
report_checks -to [get_clocks clk_slow] -path_delay max -group_count 5

puts "\n--- RÉSUMÉ DES SLACKS (Tous groupes) ---"
report_checks -path_delay max -format summary

puts "\n--- STATISTIQUES DES CHEMINS ---"
report_clock_skew
report_clock_min_period

puts "\n=========================================="
puts "  ✓ ANALYSE CDC TERMINEE"
puts "=========================================="

exit
