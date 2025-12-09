// ============================================
// Clock Uncertainty Analysis Circuit
// ============================================
// Complete circuit with FF-to-FF path
// Original I/O path preserved + new register path

module clock_uncertainty (
    input wire clk,
    input wire rst_n,
    input wire a_in,
    input wire b_in,
    output wire y_out,
    output wire q_out   // New output from FF2
);

// ========================================
// ORIGINAL I/O PATH (preserved)
// ========================================
wire inv1_out, inv2_out, and_out;

INV inv1 (
    .A(a_in),
    .Y(inv1_out)
);

INV inv2 (
    .A(inv1_out),
    .Y(inv2_out)
);

AND2 and_gate (
    .A(inv2_out),
    .B(b_in),
    .Y(and_out)
);

INV inv3 (
    .A(and_out),
    .Y(y_out)
);

// ========================================
// NEW FF-TO-FF PATH (as per README)
// ========================================
wire ff1_q, and2_out;

// Launch Flip-Flop (FF1)
DFF ff1 (
    .D(a_in),
    .CLK(clk),
    .Q(ff1_q)
);

// Combinational Logic (AND2)
AND2 and2_logic (
    .A(ff1_q),
    .B(b_in),
    .Y(and2_out)
);

// Capture Flip-Flop (FF2)
DFF ff2 (
    .D(and2_out),
    .CLK(clk),
    .Q(q_out)
);

endmodule
