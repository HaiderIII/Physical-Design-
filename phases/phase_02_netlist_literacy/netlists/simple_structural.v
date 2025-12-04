module simple_block (
    input  clk,
    input  a,
    input  b,
    output y
);

wire n1;
wire n2;

AND2 U1 ( .A(a), .B(b), .Y(n1) );
INV  U2 ( .A(n1), .Y(n2) );
DFF  U3 ( .D(n2), .CLK(clk), .Q(y) );

endmodule
