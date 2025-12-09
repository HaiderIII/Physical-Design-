# ============================================
# Timing Constraints for Buffer Chain
# ============================================

# Clock definition (10 ns period = 100 MHz)
create_clock -name clk -period 10.0 [get_ports A]

# Input delay (20% of clock period)
set_input_delay -clock clk -max 2.0 [get_ports A]
set_input_delay -clock clk -min 2.0 [get_ports A]

# Output delay (20% of clock period)
set_output_delay -clock clk -max 2.0 [get_ports Y]
set_output_delay -clock clk -min 2.0 [get_ports Y]

# Input transition
set_input_transition 0.1 [get_ports A]

# Load capacitance
set_load 0.05 [get_ports Y]
