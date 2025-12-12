# Example 3 : Constraint-Driven Placement
# ========================================
#
# Objectif : Placer les pins avec contrôle précis (bus grouping, edge assignment)

puts "\n========================================="
puts "Example 3 : Constraint-Driven Placement"
puts "=========================================\n"

# Design : Interface mémoire
puts "Step 1: Creating memory interface design..."
set netlist_content {module mem_interface (
    input clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input [15:0] addr,
    input [7:0] data_in,
    output [7:0] data_out,
    output ready,
    output error
);
    reg [7:0] mem[0:255];
    reg [7:0] data_out_reg;
    reg ready_reg;
    reg error_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= 8'h00;
            ready_reg <= 1'b0;
            error_reg <= 1'b0;
        end else begin
            if (wr_en) begin
                mem[addr[7:0]] <= data_in;
                ready_reg <= 1'b1;
            end else if (rd_en) begin
                data_out_reg <= mem[addr[7:0]];
                ready_reg <= 1'b1;
            end else begin
                ready_reg <= 1'b0;
            end
            error_reg <= (addr[15:8] != 8'h00);
        end
    end
    
    assign data_out = data_out_reg;
    assign ready = ready_reg;
    assign error = error_reg;
endmodule
}

set fp [open "example3_design.v" w]
puts $fp $netlist_content
close $fp

puts "  -> Design: Memory Interface"
puts "  -> Pins breakdown:"
puts "     - Control: clk, rst_n, wr_en, rd_en (4)"
puts "     - Address: addr[15:0] (16)"
puts "     - Data in: data_in[7:0] (8)"
puts "     - Data out: data_out[7:0] (8)"
puts "     - Status: ready, error (2)"
puts "     TOTAL: 38 pins"

# Charger
puts "\nStep 2: Loading design..."
read_verilog example3_design.v
link_design mem_interface

# Floorplan
puts "\nStep 3: Creating floorplan (1200x1200 um)..."
initialize_floorplan \
    -die_area "0 0 1200 1200" \
    -core_area "150 150 1050 1050" \
    -site FreePDK45_38x28_10R_NP_162NW_34O

puts "\n========================================="
puts "Step 4: Defining I/O constraints"
puts "=========================================\n"

puts "Strategy:"
puts "  TOP edge    → Control signals (clk, rst, enables)"
puts "  LEFT edge   → Address bus addr[15:0] (MSB-first)"
puts "  BOTTOM edge → Data input bus data_in[7:0]"
puts "  RIGHT edge  → Data output bus data_out[7:0] + status"
puts ""

# TOP: Control signals (centrés)
puts "Constraining TOP edge (control signals)..."
set_io_pin_constraint -pin_name "clk" -region "top:0.35:0.40" -layer met7
set_io_pin_constraint -pin_name "rst_n" -region "top:0.40:0.45" -layer met7
set_io_pin_constraint -pin_name "wr_en" -region "top:0.50:0.55"
set_io_pin_constraint -pin_name "rd_en" -region "top:0.55:0.60"
puts "  ✓ clk and rst_n on M7 (critical)"
puts "  ✓ wr_en and rd_en centered"

# LEFT: Address bus (16-bit, MSB-first)
puts "\nConstraining LEFT edge (address bus)..."
set_io_pin_constraint -pin_name "addr\[*\]" -region "left:0.2:0.8"
puts "  ✓ addr[15:0] grouped on left"
puts "  ✓ MSB-first ordering (automatic)"

# BOTTOM: Data input (8-bit)
puts "\nConstraining BOTTOM edge (data input)..."
set_io_pin_constraint -pin_name "data_in\[*\]" -region "bottom:0.3:0.7"
puts "  ✓ data_in[7:0] grouped on bottom"

# RIGHT: Data output + status
puts "\nConstraining RIGHT edge (data output + status)..."
set_io_pin_constraint -pin_name "data_out\[*\]" -region "right:0.2:0.6"
set_io_pin_constraint -pin_name "ready" -region "right:0.7:0.75"
set_io_pin_constraint -pin_name "error" -region "right:0.75:0.8"
puts "  ✓ data_out[7:0] grouped on right"
puts "  ✓ ready and error at bottom-right corner"

# Placement
puts "\n========================================="
puts "Step 5: Executing pin placement"
puts "=========================================\n"

place_pins \
    -hor_layers met5 \
    -ver_layers met3 \
    -min_distance 2.5

puts "  ✓ Horizontal layers: M5"
puts "  ✓ Vertical layers: M3"
puts "  ✓ Minimum spacing: 2.5 µm"

# Rapport
puts "\nStep 6: Design report..."
report_design_area

# Export
write_def example3_output.def
puts "\n✓ Exported: example3_output.def"

puts "\n========================================="
puts "Visualization of final placement"
puts "=========================================\n"

puts "         [clk][rst_n]  [wr_en][rd_en]"
puts "    ┌─────────────────────────────────────┐"
puts "    │                                     │"
puts "[a15]│                                     │[d_out7]"
puts "[a14]│                                     │[d_out6]"
puts "[a13]│                                     │[d_out5]"
puts "[a12]│         ┌─────────────┐             │[d_out4]"
puts "[a11]│         │   Memory    │             │[d_out3]"
puts "[a10]│         │  Interface  │             │[d_out2]"
puts " [a9]│         │    Logic    │             │[d_out1]"
puts " [a8]│         └─────────────┘             │[d_out0]"
puts " [a7]│                                     │"
puts " [a6]│                                     │[ready]"
puts " [a5]│                                     │[error]"
puts " [a4]│                                     │"
puts " [a3]│                                     │"
puts " [a2]│                                     │"
puts " [a1]│                                     │"
puts " [a0]│                                     │"
puts "    └─────────────────────────────────────┘"
puts "       [d_in7][d_in6]...[d_in1][d_in0]"
puts ""

puts "Benefits of this layout:"
puts "  ✓ Address bus on left → short connection to memory array"
puts "  ✓ Data buses on opposite sides → no crossing wires"
puts "  ✓ Control signals centered top → balanced fanout"
puts "  ✓ Critical clk/rst on M7 → low skew, low resistance"

puts "\nNext: See example4_timing.tcl for timing-driven placement"
