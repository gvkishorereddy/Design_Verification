module tb;

    parameter int ADDR_WIDTH  = 8;
    parameter int DATA_WIDTH  = 32;
    parameter int WAIT_CYCLES = 2;

    apb_if #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) vif();

    apb_slave_fsm #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .WAIT_CYCLES (WAIT_CYCLES)
    ) dut (
        .PCLK    (vif.PCLK),
        .PRESETn (vif.PRESETn),
        .PADDR   (vif.PADDR),
        .PSEL    (vif.PSEL),
        .PENABLE (vif.PENABLE),
        .PWRITE  (vif.PWRITE),
        .PWDATA  (vif.PWDATA),
        .PRDATA  (vif.PRDATA),
        .PREADY  (vif.PREADY),
        .PSLVERR (vif.PSLVERR)
    );

    environment env;

    initial begin
        vif.PCLK = 1'b0;
        forever #5 vif.PCLK = ~vif.PCLK;
    end

    initial begin
        env = new(vif);
        env.gen.count = 20;
        env.run();
    end

    initial begin
        $dumpfile("apb_tb.vcd");
        $dumpvars(0, tb);
    end

endmodule