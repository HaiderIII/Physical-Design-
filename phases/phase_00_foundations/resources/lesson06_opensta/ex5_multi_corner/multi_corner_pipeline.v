// ============================================================================
// Module: multi_corner_pipeline
// Description: 3-stage pipeline for multi-corner timing analysis
//
// Pipeline Structure:
//   Stage 1: d_in → FF1 → INV1 → FF2
//   Stage 2: FF2 → INV2 → FF3
//   Stage 3: FF3 → q_out
//
// Critical Paths:
//   Setup: FF1 → FF2 → FF3 (long cumulative path)
//   Hold:  FF2 → FF3 (short path, critical in fast corner)
// ============================================================================

module multi_corner_pipeline (
    input  wire clk,
    input  wire d_in,
    output wire q_out
);

    // Internal nets
    wire ff1_q;
    wire inv1_out;
    wire ff2_q;
    wire inv2_out;

    // Stage 1: Input FF and logic
    DFF ff1 (
        .D(d_in),
        .CLK(clk),
        .Q(ff1_q)
    );

    INV inv1 (
        .A(ff1_q),
        .Y(inv1_out)
    );

    // Stage 2: Middle FF and logic
    DFF ff2 (
        .D(inv1_out),
        .CLK(clk),
        .Q(ff2_q)
    );

    INV inv2 (
        .A(ff2_q),
        .Y(inv2_out)
    );

    // Stage 3: Output FF
    DFF ff3 (
        .D(inv2_out),
        .CLK(clk),
        .Q(q_out)
    );

endmodule
