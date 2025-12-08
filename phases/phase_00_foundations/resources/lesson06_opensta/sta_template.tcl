puts "========================================="
puts "OpenSTA Analysis Template"
puts "========================================="

# Read liberty library
puts "\nReading liberty library..."
read_liberty simple.lib

# Read verilog design
puts "\nReading verilog design..."
read_verilog design.v

# Link design
puts "\nLinking design..."
link_design top_module

# Read SDC constraints
puts "\nReading SDC constraints..."
read_sdc constraints.sdc

# Report timing
puts "\n========================================="
puts "Setup Analysis (Max Delay)"
puts "========================================="
report_checks -path_delay max -format full_clock_expanded

puts "\n========================================="
puts "Hold Analysis (Min Delay)"
puts "========================================="
report_checks -path_delay min -format full_clock_expanded

puts "\n========================================="
puts "Worst Slack Summary"
puts "========================================="
report_worst_slack -max
report_worst_slack -min

puts "\n========================================="
puts "Analysis Complete"
puts "========================================="
