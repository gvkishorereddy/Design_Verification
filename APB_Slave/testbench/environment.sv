class environment;

    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard sco;

    mailbox #(transaction) gen_drv;
    mailbox #(transaction) mon_sco;

    event next_stimuli;

    virtual apb_if vif;

    function new(virtual apb_if vif);
        this.vif = vif;

        gen_drv = new();
        mon_sco = new();

        gen = new(gen_drv);
        drv = new(gen_drv, vif);
        mon = new(mon_sco, vif);
        sco = new(mon_sco);

        gen.next_stimuli = next_stimuli;
        sco.next_stimuli = next_stimuli;
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
        join_any
    endtask

    task post_test();
        wait (sco.count == gen.count);

        $display("----------------------------------------");
        $display("[ENV] Transactions = %0d", sco.count);
        $display("[ENV] Passed       = %0d", sco.pass_count);
        $display("[ENV] Failed       = %0d", sco.fail_count);
        $display("----------------------------------------");

        #20;
        $finish;
    endtask

    task run();
        pre_test();
        test();
        post_test();
    endtask

endclass
