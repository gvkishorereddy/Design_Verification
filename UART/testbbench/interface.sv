interface uart_if #(
    parameter int CLK_FREQ  = 1_000_000,
    parameter int BAUD_RATE = 9_600
);

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic       clk;
    logic       rst;

    // RX side
    logic       rx;
    logic [7:0] doutrx;
    logic       donerx;

    // TX side
    logic [7:0] dintx;
    logic       newd;
    logic       tx;
    logic       donetx;

endinterface