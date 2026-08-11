class monitor;

    virtual uart_if vif;
    mailbox #(transaction) mon_sco;

    function new(
        mailbox #(transaction) mon_sco,
        virtual uart_if vif
    );
        this.mon_sco = mon_sco;
        this.vif     = vif;
    endfunction


    task monitor_tx();

        transaction tm;

        forever begin

            // Detect actual UART START bit
            @(negedge vif.tx);

            tm = new();

            // Move to middle of START bit
            repeat(vif.CLKS_PER_BIT / 2)
                @(posedge vif.clk);

            // Validate START
            if(vif.tx != 1'b0) begin
                $error("[MON][TX] False START");
                continue;
            end

            // Sample DATA bits
            for(int i = 0; i < 8; i++) begin

                repeat(vif.CLKS_PER_BIT)
                    @(posedge vif.clk);

                tm.doutrx[i] = vif.tx;

            end

            mon_sco.put(tm.copy());

            $display(
                "[MON][TX] Observed = %0h",
                tm.doutrx
            );

        end

    endtask


    task monitor_rx();

        transaction tm;

        forever begin

            @(posedge vif.donerx);

            tm = new();
            tm.doutrx = vif.doutrx;

            mon_sco.put(tm.copy());

            $display(
                "[MON][RX] Observed = %0h",
                tm.doutrx
            );

        end

    endtask


    task run();

        fork
            monitor_tx();
            monitor_rx();
        join

    endtask

endclass
