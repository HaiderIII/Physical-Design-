// Design CDC Simple - Synchronizer 2-FF (Gate-level netlist)

module cdc_simple (
    clk_fast,
    clk_slow,
    rst_n,
    data_in,
    data_out
);

    input clk_fast;
    input clk_slow;
    input rst_n;
    input data_in;
    output data_out;

    wire net_cdc_signal;
    wire net_sync_ff1_q;
    wire net_sync_ff2_q;

    // Domain A - Source flip-flop
    sky130_fd_sc_hd__dfxtp_1 domain_a_ff (
        .CLK(clk_fast),
        .D(data_in),
        .Q(net_cdc_signal)
    );

    // Domain B - Synchronizer Stage 1
    sky130_fd_sc_hd__dfxtp_1 sync_ff1 (
        .CLK(clk_slow),
        .D(net_cdc_signal),
        .Q(net_sync_ff1_q)
    );

    // Domain B - Synchronizer Stage 2
    sky130_fd_sc_hd__dfxtp_1 sync_ff2 (
        .CLK(clk_slow),
        .D(net_sync_ff1_q),
        .Q(net_sync_ff2_q)
    );

    // Domain B - Destination flip-flop
    sky130_fd_sc_hd__dfxtp_1 domain_b_ff (
        .CLK(clk_slow),
        .D(net_sync_ff2_q),
        .Q(data_out)
    );

endmodule
