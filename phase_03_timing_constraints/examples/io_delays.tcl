# Set input delays
set_input_delay -clock clk_main 2.0 [get_ports data_in]
set_input_delay -clock clk_main 1.5 [get_ports data_in2]

# Set output delays
set_output_delay -clock clk_main 3.0 [get_ports data_out]
set_output_delay -clock clk_main 2.5 [get_ports data_out2]

puts "Input and output delays set for all I/Os."
