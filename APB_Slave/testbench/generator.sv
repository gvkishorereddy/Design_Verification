class generator;

    transaction tg;
    mailbox #(transaction) gen_drv;

    int count = 0;
    event next_stimuli;

    function new(mailbox #(transaction) gen_drv);
        this.gen_drv = gen_drv;
    endfunction

    task run();
        repeat (count) begin
            tg = new();

            assert (tg.randomize())
            else $fatal(1, "[GEN] Randomization failed");

            gen_drv.put(tg);
            tg.display("GEN");

            @(next_stimuli);
        end

        $display("[GEN] Generated %0d transactions", count);
    endtask

endclass