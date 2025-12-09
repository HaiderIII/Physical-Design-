// Multi-path circuit for timing analysis
module multi_path (
    input  wire A,
    input  wire B,
    input  wire sel,
    output wire Y
);

    wire and_out, or_out;

    // Path 1: AND gate
    AND2 u_and (
        .A(A),
        .B(B),
        .Y(and_out)
    );

    // Path 2: OR gate
    OR2 u_or (
        .A(A),
        .B(B),
        .Y(or_out)
    );

    // Multiplexer selects between paths
    MUX2 u_mux (
        .A(and_out),
        .B(or_out),
        .S(sel),
        .Y(Y)
    );

endmodule
