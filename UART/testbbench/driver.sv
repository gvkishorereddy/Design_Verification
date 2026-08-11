class driver;

    transaction td;

    mailbox #(transaction) gen_drv;
    mailbox #(transaction) drv_sco;

    virtual uart_if vif;


    function new(
        mailbox #(transaction) gen_drv,
        mailbox #(transaction) drv_sco,
        virtual uart_if vif
    );

        this.gen_drv = gen_drv;
        this.drv_sco = drv_sco;
        this.vif     = vif;

    endfunction


    task reset();

        vif.rst   <= 1'b1;
        vif.rx    <= 1'b1;      // UART idle = HIGH
        vif.dintx <= 8'h00;
        vif.newd  <= 1'b0;

        repeat(5)
            @(posedge vif.clk);

        vif.rst <= 1'b0;

        @(posedge vif.clk);

    endtask


    task send_bit(bit value);

        vif.rx <= value;

        repeat(vif.CLKS_PER_BIT)
            @(posedge vif.clk);

    endtask


    task run();

        forever begin

            gen_drv.get(td);


            // =================================================
            // WRITE = TEST UART TRANSMITTER
            // =================================================

            if (td.oper == WRITE) begin

                $display("[DRIVER][TX] Sending = %0h", td.dintx);

                vif.dintx <= td.dintx;
                vif.newd  <= 1'b1;

                @(posedge vif.clk);

                vif.newd  <= 1'b0;

                drv_sco.put(td.copy());

                // Wait for TX pulse from DUT
                @(posedge vif.donetx);

                $display("[DRIVER][TX] Done");

            end


            // =================================================
            // READ = TEST UART RECEIVER
            // =================================================

            else begin

                $display("[DRIVER][RX] Sending serial = %0h", td.dintx);

                drv_sco.put(td.copy());

                // START BIT
                send_bit(1'b0);

                // 8 DATA BITS (LSB FIRST)
                for(int i = 0; i < 8; i++) begin
                    send_bit(td.dintx[i]);
                end

                // STOP BIT
                send_bit(1'b1);

                $display("[DRIVER][RX] Done");

            end

        end

    endtask

endclass