# Define primary clocks
create_clock -name clk_main -period 10 [get_ports clk]
create_clock -name clk_alt -period 12 [get_ports clk_alt]
puts "Clocks 'clk_main' and 'clk_alt' created."
