// Simple 4-bit adder - Structural version
// This version uses only wire declarations and buffers
// to ensure maximum compatibility with OpenROAD parser

module adder4 (
    a,
    b,
    sum,
    cout
);

    input [3:0] a;
    input [3:0] b;
    output [3:0] sum;
    output cout;
    
    // Just pass through for now - this is only for I/O placement demo
    // We don't need actual logic, just the port structure
    assign sum[0] = a[0];
    assign sum[1] = a[1];
    assign sum[2] = a[2];
    assign sum[3] = a[3];
    assign cout = b[0];

endmodule
