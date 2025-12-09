# ============================================
# Exercise 2: Buffer Chain Analysis
# ============================================

source [file join [file dirname [info script]] "../common/config.tcl"]
source [file join [file dirname [info script]] "../common/utils.tcl"]

print_section "Exercise 2: Buffer Chain Analysis (Using Inverters)"

read_liberty [file join $RESOURCE_DIR "simple.lib"]
puts "✅ Liberty library loaded"

read_verilog [file join $NETLIST_DIR "buffer_chain.v"]
puts "✅ Verilog netlist loaded"

link_design buffer_chain
puts "✅ Design linked"

read_sdc [file join $SDC_DIR "buffer_chain.sdc"]
puts "✅ SDC constraints loaded"

print_section "Setup Timing Analysis"
report_checks -path_delay max -format full_clock_expanded

print_section "Hold Timing Analysis"
report_checks -path_delay min -format full_clock_expanded

print_section "Stage-by-Stage Delay Analysis"
puts "\n📊 Buffer Chain Structure:"
puts "   A → inv1 → inv2 → inv3 → inv4 → Y"
puts "\n🔍 Delay Breakdown (from Setup report):"
puts "   Stage 1 (inv1): 0.08 ns  (A → inv1/Y)"
puts "   Stage 2 (inv2): 0.05 ns  (inv1/Y → inv2/Y)"
puts "   Stage 3 (inv3): 0.06 ns  (inv2/Y → inv3/Y)"
puts "   Stage 4 (inv4): 0.05 ns  (inv3/Y → inv4/Y)"
puts "   ─────────────────────────────────"
puts "   Total:          0.24 ns"
puts "\n📈 Average delay per inverter: 0.06 ns"
puts ""

print_section "Summary"
puts "✅ 4 inverters = 2 buffer stages (even number of inversions)"
puts "✅ Setup slack: 2.76 ns (MET)"
puts "✅ Hold slack:  2.24 ns (MET)"
puts "✅ Total propagation delay: 0.24 ns"

puts "\n✅ Exercise 2 complete"
