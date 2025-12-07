# Clock definition
create_clock -period 10.0 -name clk [get_ports clk]
create_clock -period 5.0 -name fast_clk [get_ports fast_clk]

# Input delays
set_input_delay 0.5 -clock clk [get_ports rst]
set_input_delay 0.3 -clock clk [get_ports enable]
set_input_delay 0.8 -clock clk [get_ports data_in[*]]
set_input_delay 0.4 -clock clk [get_ports {addr[15:0]}]
set_input_delay 0.6 -clock fast_clk [get_ports ctrl[*]]

# Output delays
set_output_delay 0.3 -clock clk [get_ports data_out[*]]
set_output_delay 0.5 -clock clk [get_ports result[*]]
set_output_delay 0.2 -clock fast_clk [get_ports status]

# Load capacitances
set_load 0.05 [get_ports data_out[*]]
set_load 0.03 [all_outputs]

# Input drive
set_driving_cell -lib_cell INV_X1 [all_inputs]

# Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks clk]
set_clock_uncertainty 0.1 [get_clocks fast_clk]

# Multi-cycle paths
set_multicycle_path 2 -from [get_pins FF_*] -to [get_pins REG*]

# False paths
set_false_path -from [get_ports rst] -to [get_pins */RN]

# Max delay
set_max_delay 5.0 -from [get_ports data_in*] -to [get_ports data_out*]

# Group paths
group_path -name INPUTS -from [all_inputs]
group_path -name OUTPUTS -to [all_outputs]
group_path -name REGS -from [all_registers] -to [all_registers]
