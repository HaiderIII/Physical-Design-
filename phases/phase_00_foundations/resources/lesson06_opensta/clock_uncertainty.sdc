# ============================================
# Clock Uncertainty Analysis - SDC Constraints
# ============================================

# Clock Definition
create_clock -name clk -period 10.0 [get_ports clk]

# ========================================
# I/O Delays (for original I/O path)
# ========================================
set_input_delay -clock clk -max 2.0 [get_ports {a_in b_in}]
set_output_delay -clock clk -max 2.0 [get_ports y_out]

# ========================================
# Clock Uncertainty Scenarios
# ========================================
# Scenario 1: Ideal (no uncertainty) - baseline
# → Pas de commande, uncertainty = 0

# Scenario 2: With Jitter (200ps)
# set_clock_uncertainty 0.2 [get_clocks clk]

# Scenario 3: With Jitter + Skew (500ps)
# set_clock_uncertainty 0.5 [get_clocks clk]

# Note: Script will apply these incrementally
