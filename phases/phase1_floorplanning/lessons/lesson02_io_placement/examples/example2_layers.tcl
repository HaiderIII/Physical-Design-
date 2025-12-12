# Example 2 : Contrôle des metal layers
# ======================================
#
# Objectif : Démontrer l'impact du choix de layers sur le placement

puts "\n========================================="
puts "Example 2 : Layer Assignment Control"
puts "=========================================\n"

# Créer un design avec plus de pins
puts "Step 1: Creating 8-bit design..."
set netlist_content {module alu8 (
    input clk,
    input rst,
    input [7:0] data_in,
    input [2:0] opcode,
    output [7:0] result,
    output valid
);
    reg [7:0] result_reg;
    reg valid_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result_reg <= 8'h00;
            valid_reg <= 1'b0;
        end else begin
            case (opcode)
                3'b000: result_reg <= data_in;
                3'b001: result_reg <= ~data_in;
                default: result_reg <= 8'h00;
            endcase
            valid_reg <= 1'b1;
        end
    end
    
    assign result = result_reg;
    assign valid = valid_reg;
endmodule
}

set fp [open "example2_design.v" w]
puts $fp $netlist_content
close $fp
puts "  -> Design: 8-bit ALU"
puts "  -> Pins: 2 control + 8 inputs + 3 opcode + 8 outputs + 1 valid = 22 total"

# Charger
puts "\nStep 2: Loading design..."
read_verilog example2_design.v
link_design alu8

# Floorplan
puts "\nStep 3: Creating floorplan (800x800 um)..."
initialize_floorplan \
    -die_area "0 0 800 800" \
    -core_area "100 100 700 700" \
    -site FreePDK45_38x28_10R_NP_162NW_34O

puts "\n========================================="
puts "SCENARIO A: All pins on M3 (thin layer)"
puts "=========================================\n"

place_pins \
    -hor_layers met3 \
    -ver_layers met3 \
    -random \
    -random_seed 100

write_def example2_scenario_a.def
puts "  ✓ Exported: example2_scenario_a.def"
puts "  → Problem: M3 is thin, high resistance for I/O"
puts "  → Risk: Routing congestion with internal signals"

puts "\n========================================="
puts "SCENARIO B: Optimal layer assignment"
puts "=========================================\n"

Reload to reset
read_verilog example2_design.v
link_design alu8
initialize_floorplan \
    -die_area "0 0 800 800" \
    -core_area "100 100 700 700" \
    -site FreePDK45_38x28_10R_NP_162NW_34O

place_pins \
    -hor_layers met5 \
    -ver_layers met3 \
    -random \
    -random_seed 100

write_def example2_scenario_b.def
puts "  ✓ Exported: example2_scenario_b.def"
puts "  → M5 for horizontal (top/bottom): Thick, low resistance"
puts "  → M3 for vertical (left/right): Adequate, avoids M1/M2"

puts "\n========================================="
puts "SCENARIO C: Maximum performance (M7)"
puts "=========================================\n"

Reload
read_verilog example2_design.v
link_design alu8
initialize_floorplan \
    -die_area "0 0 800 800" \
    -core_area "100 100 700 700" \
    -site FreePDK45_38x28_10R_NP_162NW_34O

Clock and critical signals on M7
set_io_pin_constraint -pin_name "clk" -region "top:*" -layer met7
set_io_pin_constraint -pin_name "rst" -region "top:*" -layer met7

Other pins on M5/M3
place_pins \
    -hor_layers met5 \
    -ver_layers met3 \
    -random \
    -random_seed 100

write_def example2_scenario_c.def
puts "  ✓ Exported: example2_scenario_c.def"
puts "  → Critical signals (clk, rst) on M7: Maximum thickness"
puts "  → Other signals on M5/M3: Good balance"

puts "\n========================================="
puts "Layer Comparison Summary"
puts "=========================================\n"

puts "| Layer | Thickness | Resistance | Use Case              |"
puts "|-------|-----------|------------|-----------------------|"
puts "| M1    | 0.14 µm   | HIGH       | Intra-cell only       |"
puts "| M2    | 0.14 µm   | HIGH       | Local routing         |"
puts "| M3    | 0.30 µm   | MEDIUM     | I/O minimum           |"
puts "| M5    | 0.80 µm   | LOW        | I/O recommended       |"
puts "| M7    | 1.60 µm   | VERY LOW   | Power / Critical I/O  |"

puts "\nRecommendation:"
puts "  ✓ Use M5 for horizontal I/O pins (top/bottom edges)"
puts "  ✓ Use M3 for vertical I/O pins (left/right edges)"
puts "  ✓ Use M7 for clock and critical signals"

puts "\nNext: See example3_constraints.tcl for constraint-driven placement"
