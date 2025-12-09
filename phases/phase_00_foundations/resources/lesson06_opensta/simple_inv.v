// Simple inverter for OpenSTA tutorial
module inverter (
    input  A,
    output Y
);

// Inverter instantiation
INV inv_inst (
    .A(A),
    .Y(Y)
);

endmodule
