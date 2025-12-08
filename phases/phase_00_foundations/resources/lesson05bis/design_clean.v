
module counter (
    input        clk,     
    input        rst,     
    input        enable,  
    output reg [7:0] count 
);
    reg [3:0] state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 8'b0;
            state <= 4'b0;
        end else if (enable) begin
            count <= count + 1;
            state <= state + 1;
        end
    end
endmodule
module and_gate (
    input  a,
    input  b,
    output y
);
    assign y = a & b;
endmodule
module adder #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] sum
);
    assign sum = a + b;
endmodule

