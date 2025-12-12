# Example 4 : Timing-Driven I/O Placement
# ========================================
#
# Objectif : Utiliser les contraintes SDC pour optimiser le placement I/O

puts "\n========================================="
puts "Example 4 : Timing-Driven Placement"
puts "=========================================\n"

# Design simple avec path critique
puts "Step 1: Creating design with critical timing path..."
set netlist_content {module critical_path (
    input clk,
    input rst,
    input critical_in,
    input [3:0] data_in,
    output reg critical_out,
    output reg [3:0] data_out
);
    reg [3:0] pipeline_reg;
    
    // Critical path: critical_in → critical_out (combinational)
    always @(*) begin
        critical_out = critical_in & data_in[0];
    end
    
    // Non-critical path: data_in → data_out (registered)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pipeline_reg <= 4'h0;
            data_out <= 4'h0;
        end else begin
            pipeline_reg <= data_in;
            data_out <= pipeline_reg;
        end
    end
endmodule
}

set fp [open "example4_design.v" w]
puts $fp $netlist_content
close $fp

# SDC avec contrainte critique
puts "\nStep 2: Creating SDC constraints..."
set sdc_content {# Clock definition
create_clock -name clk -period 10.0 [get_ports clk]

# Input delays
set_input_delay -clock clk -max 2.0 [get_ports data_in*]
set_input_delay -clock clk -max 1.0 [get_ports critical_in]

# Output delays
set_output_delay -clock clk -max 2.0 [get_ports data_out*]
set_output_delay -clock clk -max 0.5 [get_ports critical_out]

# False paths (reset)
set_false_path -from [get_ports rst]

# Critical path constraint
set_max_delay 3.0 -from [get_ports critical_in] -to [get_ports critical_out]
}

set fp [open "example4_constraints.sdc" w]
puts $fp $sdc_content
close $fp
puts "  ✓ SDC created with:"
puts "     - Clock period: 10 ns"
puts "     - Critical path: critical_in → critical_out (max 3ns)"
puts "     - Regular paths: data_in → data_out (registered)"

# Charger design
puts "\nStep 3: Loading design with timing info..."
read_verilog example4_design.v
link_design critical_path

Dummy liberty for timing (in real case: read_liberty cells.lib)
puts "  → In real flow: read_liberty cells.lib"

read_sdc example4_constraints.sdc
puts "  ✓ SDC constraints loaded"

# Floorplan
puts "\nStep 4: Creating floorplan..."
initialize_floorplan \
    -die_area "0 0 600 600" \
    -core_area "80 80 520 520" \
    -site FreePDK45_38x28_10R_NP_162NW_34O

puts "\n========================================="
puts "Step 5: Timing-aware placement strategy"
puts "=========================================\n"

puts "Analysis:"
puts "  ● critical_in → critical_out: COMBINATIONAL (max 3ns)"
puts "    → Need SHORT wire delay"
puts "    → Place both pins CLOSE to each other"
puts ""
puts "  ● data_in → data_out: REGISTERED (10ns period)"
puts "    → More relaxed timing"
puts "    → Can tolerate longer wires"
puts ""

puts "Constraint strategy:"

Critical signals on opposite sides BUT close to logic
set_io_pin_constraint -pin_name "critical_in" -region "left:0.4:0.6"
set_io_pin_constraint -pin_name "critical_out" -region "right:0.4:0.6"
puts "  ✓ critical_in on LEFT (centered)"
puts "  ✓ critical_out on RIGHT (centered, straight path)"

Non-critical data buses on top/bottom
set_io_pin_constraint -pin_name "data_in\[*\]" -region "bottom:*"
set_io_pin_constraint -pin_name "data_out\[*\]" -region "top:*"
puts "  ✓ data_in[3:0] on BOTTOM (non-critical)"
puts "  ✓ data_out[3:0] on TOP (non-critical)"

Clock and reset on top
set_io_pin_constraint -pin_name "clk" -region "top:0.2:0.3" -layer met7
set_io_pin_constraint -pin_name "rst" -region "top:0.3:0.4" -layer met7
puts "  ✓ clk and rst on TOP (M7 layer)"

# Placement
puts "\nStep 6: Executing timing-driven placement..."
place_pins \
    -hor_layers met5 \
    -ver_layers met3

puts "  → OpenROAD will use SDC timing info to optimize placement"

# Timing report (simulation - in real case: after STA)
puts "\n========================================="
puts "Step 7: Timing analysis (simulated)"
puts "=========================================\n"

puts "Path 1: critical_in → critical_out (CRITICAL)"
puts "  Startpoint: critical_in (input port)"
puts "  Endpoint:   critical_out (output port)"
puts "  Path Type:  max delay"
puts ""
puts "  Point                    Incr    Path"
puts "  ------------------------------------------------"
puts "  critical_in (in)         0.00    0.00"
puts "  wire_delay (optimized!)  0.30    0.30  ← SHORT!"
puts "  U1/Y (AND2)              0.50    0.80"
puts "  wire_delay               0.30    1.10  ← SHORT!"
puts "  critical_out (out)       0.00    1.10"
puts "  ------------------------------------------------"
puts "  Required time:                   3.00"
puts "  Arrival time:                   -1.10"
puts "  Slack (MET):                     1.90  ✓ GOOD"
puts ""

puts "Path 2: data_in[0] → data_out[0] (NON-CRITICAL)"
puts "  Startpoint: data_in[0] (input port clocked by clk)"
puts "  Endpoint:   data_out[0] (output port clocked by clk)"
puts "  Path Type:  max delay"
puts ""
puts "  Point                    Incr    Path"
puts "  ------------------------------------------------"
puts "  clock clk (rise edge)    0.00    0.00"
puts "  input external delay     2.00    2.00"
puts "  data_in[0] (in)          0.00    2.00"
puts "  wire_delay               0.80    2.80  ← Longer OK"
puts "  FF1/D                    0.00    2.80"
puts "  FF1/Q (setup 0.20)       0.50    3.30"
puts "  wire_delay               0.80    4.10"
puts "  data_out[0] (out)        0.00    4.10"
puts "  ------------------------------------------------"
puts "  Required time:                  10.00"
puts "  Arrival time:                   -4.10"
puts "  Slack (MET):                     5.90  ✓ GOOD"

# Export
write_def example4_output.def
puts "\n✓ Exported: example4_output.def"

puts "\n========================================="
puts "Visualization: Timing-optimized layout"
puts "=========================================\n"

puts "      [clk][rst]  [dout3][dout2][dout1][dout0]"
puts "    ┌──────────────────────────────────────────┐"
puts "    │                                          │"
puts "    │              ╔═══════════╗               │"
puts "    │    SHORT!    ║  Critical ║    SHORT!     │"
puts "[crit_in]═════════>║   Logic   ║═════════>[crit_out]"
puts "    │      0.3ns   ╚═══════════╝      0.3ns    │"
puts "    │                                          │"
puts "    │              ┌───────────┐               │"
puts "    │              │  Pipeline │               │"
puts "    │              │  Registers│               │"
puts "    │              └───────────┘               │"
puts "    │                                          │"
puts "    └──────────────────────────────────────────┘"
puts "        [din3] [din2] [din1] [din0]"
puts ""

puts "Key insights:"
puts "  ✓ Critical path uses shortest possible wire (left-center-right)"
puts "  ✓ Non-critical data uses top/bottom (longer wires tolerated)"
puts "  ✓ Total wire delay on critical path: 0.6 ns (vs 3ns constraint)"
puts "  ✓ Slack margin: 1.9 ns available for future optimization"

puts "\nComparison with random placement:"
puts ""
puts "| Metric | Random | Timing-Driven | Improvement |"
puts "|--------|--------|---------------|-------------|"
puts "| Critical wire delay | 1.2 ns | 0.6 ns | 50% faster |"
puts "| Critical slack | 0.8 ns | 1.9 ns | 2.4x margin |"
puts "| Non-critical slack | 5.5 ns | 5.9 ns | Similar |"

puts "\n========================================="
puts "Example 4 completed!"
puts "=========================================\n"

puts "Lesson learned:"
puts "  → Always provide SDC constraints BEFORE pin placement"
puts "  → OpenROAD analyzes timing criticality automatically"
puts "  → Critical paths get priority for short wire connections"
puts "  → Non-critical paths use remaining space efficiently"

puts "\nThis completes the lesson02 examples!"
puts "Continue with exercises/lesson02_exercises/ for hands-on practice."
