// Synthesized netlist example
module top (
    input clk,
    input rst,
    input [7:0] data_in,
    output [7:0] data_out
);

    wire n1, n2, n3, n4, n5;
    wire [7:0] reg_out;
    
    // Standard cell instances
    NAND2_X1 U1 (.A(data_in[0]), .B(data_in[1]), .Y(n1));
    NAND2_X1 U2 (.A(data_in[2]), .B(data_in[3]), .Y(n2));
    INV_X1 U3 (.A(n1), .Y(n3));
    INV_X1 U4 (.A(n2), .Y(n4));
    NOR2_X1 U5 (.A(n3), .B(n4), .Y(n5));
    
    // Flipflops
    DFFR_X1 FF_0 (.D(n5), .CK(clk), .RN(rst), .Q(reg_out[0]));
    DFFR_X1 FF_1 (.D(data_in[4]), .CK(clk), .RN(rst), .Q(reg_out[1]));
    DFFR_X1 FF_2 (.D(data_in[5]), .CK(clk), .RN(rst), .Q(reg_out[2]));
    DFFR_X1 FF_3 (.D(data_in[6]), .CK(clk), .RN(rst), .Q(reg_out[3]));
    SDFFRS_X1 FF_STATE (.D(data_in[7]), .CK(clk), .RN(rst), .SN(1'b1), .Q(reg_out[4]));
    
    // More combinational logic
    NAND2_X1 U6 (.A(reg_out[0]), .B(reg_out[1]), .Y(data_out[0]));
    NAND2_X1 U7 (.A(reg_out[2]), .B(reg_out[3]), .Y(data_out[1]));
    INV_X1 U8 (.A(reg_out[4]), .Y(data_out[2]));
    NOR2_X1 U9 (.A(data_out[0]), .B(data_out[1]), .Y(data_out[3]));
    
    // Buffer chain
    BUF_X1 U10 (.A(data_in[0]), .Y(data_out[4]));
    BUF_X2 U11 (.A(data_out[4]), .Y(data_out[5]));
    BUF_X4 U12 (.A(data_out[5]), .Y(data_out[6]));
    
    // XOR gates
    XOR2_X1 U13 (.A(n1), .B(n2), .Y(data_out[7]));
    
endmodule

// Hierarchical design
module cpu_core (
    input clk,
    input rst,
    input [31:0] instruction,
    output [31:0] result
);

    wire [31:0] alu_out;
    wire [4:0] reg_addr;
    
    alu U_ALU (.a(instruction[15:0]), .b(instruction[31:16]), .result(alu_out));
    
    reg_file U_REGS (.addr(reg_addr), .data(alu_out), .out(result));
    
endmodule

module alu (
    input [15:0] a,
    input [15:0] b,
    output [31:0] result
);
    
    NAND2_X1 U_NAND1 (.A(a[0]), .B(b[0]), .Y(result[0]));
    NAND2_X1 U_NAND2 (.A(a[1]), .B(b[1]), .Y(result[1]));
    
endmodule

module reg_file (
    input [4:0] addr,
    input [31:0] data,
    output [31:0] out
);

    DFFR_X1 REG0 (.D(data[0]), .CK(clk), .RN(rst), .Q(out[0]));
    DFFR_X1 REG1 (.D(data[1]), .CK(clk), .RN(rst), .Q(out[1]));
    
endmodule
