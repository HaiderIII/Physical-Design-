module top_module (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);
    wire [7:0] stage1_out;
    wire [7:0] stage2_out;
    pipeline_stage stage1 (.clk(clk), .rst_n(rst_n), .din(data_in), .dout(stage1_out));
    pipeline_stage stage2 (.clk(clk), .rst_n(rst_n), .din(stage1_out), .dout(stage2_out));
    pipeline_stage stage3 (.clk(clk), .rst_n(rst_n), .din(stage2_out), .dout(data_out));
endmodule

module pipeline_stage (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] din,
    output reg  [7:0] dout
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 8'h00;
        else
            dout <= din;
    end
endmodule
