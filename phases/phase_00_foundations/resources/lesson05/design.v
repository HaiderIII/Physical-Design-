// Simple counter module
module counter (
    input clk,
    input rst,
    input enable,
    output reg [7:0] count
);

    wire internal_signal;
    reg state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 8'b0;
        end else if (enable) begin
            count <= count + 1;
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
