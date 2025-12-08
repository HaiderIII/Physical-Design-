module data_reg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'h00;
        else
            data_out <= data_in;
    end
endmodule

module logic_block (
    input  wire [7:0] in_data,
    output wire [7:0] out_data
);
    assign out_data = in_data + 8'h01;
endmodule

module hier_design (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);
    wire [7:0] reg_out;
    wire [7:0] logic_out;
    
    data_reg u_reg (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(reg_out)
    );
    
    logic_block u_logic (
        .in_data(reg_out),
        .out_data(logic_out)
    );
    
    data_reg u_out_reg (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(logic_out),
        .data_out(data_out)
    );
endmodule
