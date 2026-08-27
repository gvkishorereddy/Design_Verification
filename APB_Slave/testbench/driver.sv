class driver;

    virtual apb_if vif;

    transaction td;
    mailbox #(transaction) gen_drv;

    function new(
        mailbox #(transaction) gen_drv,
        virtual apb_if vif
    );
        this.gen_drv = gen_drv;
        this.vif     = vif;
    endfunction

    task reset();
        vif.PRESETn <= 1'b0;
        vif.PADDR   <= '0;
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PWDATA  <= '0;

        repeat (2) @(posedge vif.PCLK);

        @(negedge vif.PCLK);
        vif.PRESETn <= 1'b1;

        $display("[DRV] Reset completed");
    endtask

    task drive_transfer();
        // SETUP phase
        @(negedge vif.PCLK);

        vif.PADDR   <= td.paddr;
        vif.PWRITE  <= td.pwrite;
        vif.PWDATA  <= td.pwdata;
        vif.PSEL    <= 1'b1;
        vif.PENABLE <= 1'b0;

        // ACCESS phase
        @(negedge vif.PCLK);
        vif.PENABLE <= 1'b1;
		td.display("DRV");
        // APB completion edge
        do begin
            @(posedge vif.PCLK);
        end while (vif.PREADY !== 1'b1);

        

        // Return to IDLE
        @(negedge vif.PCLK);

        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= '0;
        vif.PWDATA  <= '0;
    endtask

    task run();
        forever begin
            gen_drv.get(td);
            drive_transfer();
        end
    endtask

endclass
