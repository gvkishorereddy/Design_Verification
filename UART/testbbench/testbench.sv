module tb;

    uart_if #(
        .CLK_FREQ (1_000_000),
        .BAUD_RATE(9_600)
    ) vif();


    uart_top #(
        .CLK_FREQ (1_000_000),
        .BAUD_RATE(9_600)
    ) dut (

        .clk    (vif.clk),
        .rst    (vif.rst),

        // RX
        .rx     (vif.rx),
        .doutrx (vif.doutrx),
        .donerx (vif.donerx),

        // TX
        .dintx  (vif.dintx),
        .newd   (vif.newd),
        .tx     (vif.tx),
        .donetx (vif.donetx)

    );


    environment env;


    // 1 MHz => 1 us period
    initial begin
        vif.clk = 1'b0;
        forever
            #500 vif.clk = ~vif.clk;
    end


    initial begin
        env = new(vif);
        env.run();
    end


    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule