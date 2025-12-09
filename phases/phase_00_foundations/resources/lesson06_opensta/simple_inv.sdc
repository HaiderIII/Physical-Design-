# Timing constraints for simple inverter

# Create a virtual clock (no physical port needed)
create_clock -name clk -period 10.0

# Input delay relative to virtual clock
set_input_delay -clock clk 2.0 [get_ports A]

# Output delay relative to virtual clock
set_output_delay -clock clk 2.0 [get_ports Y]

# Set input transition time
set_input_transition 0.1 [get_ports A]

# Set load capacitance on output
set_load 0.05 [get_ports Y]
