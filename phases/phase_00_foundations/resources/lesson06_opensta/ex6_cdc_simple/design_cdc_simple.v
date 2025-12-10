// Design CDC Simple - Synchronizer 2-FF
// Domain A (clk_fast) -> Domain B (clk_slow)

module cdc_simple (
    input  wire clk_fast,       // 100 MHz
    input  wire clk_slow,       // 50 MHz
    input  wire rst_n,
    input  wire data_in,        // Signal dans domain A
    output wire data_out        // Signal synchronise dans domain B
);

    // Domain A - Flip-flop source
    reg domain_a_ff;
    
    always @(posedge clk_fast or negedge rst_n) begin
        if (!rst_n)
            domain_a_ff <= 1'b0;
        else
            domain_a_ff <= data_in;
    end

    // Signal asynchrone qui traverse le CDC
    wire cdc_signal;
    assign cdc_signal = domain_a_ff;

    // Domain B - Synchronizer 2-FF
    reg sync_ff1;  // Premier FF du synchronizer (peut devenir metastable)
    reg sync_ff2;  // Deuxieme FF du synchronizer (sortie sure)
    
    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= cdc_signal;  // Echantillonnage asynchrone
            sync_ff2 <= sync_ff1;    // Re-synchronisation
        end
    end

    // Domain B - Flip-flop destination
    reg domain_b_ff;
    
    always @(posedge clk_slow or negedge rst_n) begin
        if (!rst_n)
            domain_b_ff <= 1'b0;
        else
            domain_b_ff <= sync_ff2;
    end

    assign data_out = domain_b_ff;

endmodule
