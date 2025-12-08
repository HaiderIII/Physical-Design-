module pipeline_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  data_in,
    output reg  [3:0]  data_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 4'b0000;
        else
            data_out <= data_in;
    end
endmodule
