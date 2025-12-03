// sample_design.v — Enhanced version for learning
module sample_design(
    input clk,
    input clk_alt,
    input reset,
    input data_in,
    input data_in2,
    output data_out,
    output data_out2
);

// Flip-flops
reg ff1, ff2, ff3, ff4, ff5, ff6, ff7, ff8;
reg ff9, ff10;

// Combinational logic
wire n1, n2, n3, n4, n5, n6, n7;

// High fanout net
wire hf1;
assign hf1 = data_in2;

// Example combinational paths
assign n1 = data_in & ff1;
assign n2 = n1 | ff2;
assign n3 = ~n2;
assign n4 = n3 ^ ff3;
assign n5 = n4 & ff4;
assign n6 = hf1 | ff5;
assign n7 = n6 & ff6;

// Sequential logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        ff1 <= 0; ff2 <= 0; ff3 <= 0; ff4 <= 0;
        ff5 <= 0; ff6 <= 0; ff7 <= 0; ff8 <= 0;
        ff9 <= 0; ff10 <= 0;
    end else begin
        ff1 <= data_in;
        ff2 <= ff1;
        ff3 <= ff2;
        ff4 <= ff3;
        ff5 <= ff4;
        ff6 <= ff5;
        ff7 <= ff6;
        ff8 <= ff7;
        ff9 <= ff8;
        ff10 <= ff9;
    end
end

// Secondary clock path
always @(posedge clk_alt) begin
    ff9 <= ff10;
end

// Output logic
assign data_out = ff8 & n5;
assign data_out2 = ff10 | n7;

// Macro instance (simple combinational block)
simple_macro u_macro (
    .a(n5),
    .b(n7),
    .y(n6)
);

endmodule

// Definition of a simple macro
module simple_macro(input a, input b, output y);
assign y = a | b;
endmodule
