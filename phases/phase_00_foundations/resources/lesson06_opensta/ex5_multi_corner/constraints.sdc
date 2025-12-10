# ==============================================================================
# SDC Constraints: Multi-Corner Pipeline (HOLD-AWARE VERSION)
# Target Frequency: 200 MHz (Period = 5.0 ns)
# ==============================================================================

# Clock definition (200 MHz)
create_clock -period 5.0 -name clk [get_ports clk]

# ==============================================================================
# INPUT CONSTRAINTS (Setup + Hold)
# ==============================================================================
# Max delay: External source takes up to 1.0 ns to deliver stable data
set_input_delay -clock clk -max 1.0 [get_ports d_in]

# Min delay: External source delivers data at least 0.3 ns after clock edge
# (ensures hold margin at FF1/D input)
set_input_delay -clock clk -min 0.3 [get_ports d_in]

# ==============================================================================
# OUTPUT CONSTRAINTS (Setup + Hold)
# ==============================================================================
# Max delay: External load requires data stable 1.0 ns before next clock
set_output_delay -clock clk -max 1.0 [get_ports q_out]

# Min delay: External load requires data to arrive at least 0.5 ns after clock
# (prevents hold violations at receiving end)
set_output_delay -clock clk -min 0.5 [get_ports q_out]

# ==============================================================================
# CLOCK UNCERTAINTY
# ==============================================================================
# Clock uncertainty (accounts for jitter + skew variation)
# 0.3 ns = 6% of period (typical for PLL-based clocks)
set_clock_uncertainty 0.3 [get_clocks clk]

# ==============================================================================
# DRIVE & LOAD CONDITIONS
# ==============================================================================
# Drive strength for input ports (assume external driver = INV strength)
set_driving_cell -lib_cell INV [get_ports d_in]

# Load capacitance for output ports (assume external load = 0.05 pF)
set_load 0.05 [get_ports q_out]
