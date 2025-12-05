create_clock -period 10.0 clk
set_input_delay 0.5 -clock clk [all_inputs]
set_output_delay 0.3 -clock clk [all_outputs]
set_load 0.05 [all_outputs]
