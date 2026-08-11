class environment;

    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard sco;

    mailbox #(transaction) gen_drv;
    mailbox #(transaction) drv_sco;
    mailbox #(transaction) mon_sco;

    virtual uart_if vif;


    function new(virtual uart_if vif);

        this.vif = vif;

        gen_drv = new();
        drv_sco = new();
        mon_sco = new();

        gen = new(gen_drv);

        drv = new(
            gen_drv,
            drv_sco,
            vif
        );

        mon = new(
            mon_sco,
            vif
        );

        sco = new(
            drv_sco,
            mon_sco
        );

        gen.next_input = sco.next_input;

    endfunction


    task pre_test();
        drv.reset();
    endtask


    task test();
        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join_none
    endtask


    task post_test();

        wait(sco.count == gen.count);

        $display("--------------------------------------");
        $display("ALL TRANSACTIONS COMPLETED");
        $display("--------------------------------------");

        $finish;

    endtask


    task run();
        pre_test();
        test();
        post_test();
    endtask

endclass