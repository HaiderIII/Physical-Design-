# Timing constraints for multi-path circuit

# Create a virtual clock (not connected to any port)
create_clock -name clk -period 10.0

# Input delays (arriving 2ns after clock edge)
set_input_delay -clock clk -max 2.0 [get_ports {A B sel}]
set_input_delay -clock clk -min 1.0 [get_ports {A B sel}]

# Output delays (2ns before next clock edge)
set_output_delay -clock clk -max 2.0 [get_ports Y]
set_output_delay -clock clk -min 1.0 [get_ports Y]

# Input transition time
set_input_transition 0.5 [get_ports {A B sel}]

# Load capacitance on output
set_load 0.05 [get_ports Y]
