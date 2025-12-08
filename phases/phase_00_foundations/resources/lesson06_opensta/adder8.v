module adder8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output wire [7:0] sum,
    output wire       cout
);
    wire [7:0] carry;
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : adder_loop
            if (i == 0)
                full_adder fa (.a(a[i]), .b(b[i]), .cin(cin), .sum(sum[i]), .cout(carry[i]));
            else
                full_adder fa (.a(a[i]), .b(b[i]), .cin(carry[i-1]), .sum(sum[i]), .cout(carry[i]));
        end
    endgenerate
    assign cout = carry[7];
endmodule

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule
