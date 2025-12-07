// Simple counter design with comments
module counter (
    input clk,           // Clock input
    input rst,           // Reset signal
    input enable,        // Enable counting
    output reg [7:0] count  // 8-bit counter output
);

    wire internal_clk;
    reg [3:0] state;
    
    /* Multi-line comment
       This is the main
       counter logic */
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

// AND gate module
module and_gate (
    input a,
    input b,
    output y
);

    wire temp;
    assign y = a & b;
    
endmodule

// Adder with parameters
module adder #(
    parameter WIDTH = 8
) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] sum
);

    assign sum = a + b;

endmodule
