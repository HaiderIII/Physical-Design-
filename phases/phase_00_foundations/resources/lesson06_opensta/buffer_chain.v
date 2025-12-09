// ============================================
// Buffer Chain using Inverters (INV cells)
// ============================================
// Configuration: 4 inverters in series = 2-stage buffer
// A → inv1 → inv2 → inv3 → inv4 → Y

module buffer_chain (
    input  A,
    output Y
);

    wire n1, n2, n3;

    // Stage 1: First inverter
    INV inv1 (
        .A(A),
        .Y(n1)
    );

    // Stage 2: Second inverter
    INV inv2 (
        .A(n1),
        .Y(n2)
    );

    // Stage 3: Third inverter
    INV inv3 (
        .A(n2),
        .Y(n3)
    );

    // Stage 4: Fourth inverter
    INV inv4 (
        .A(n3),
        .Y(Y)
    );

endmodule
