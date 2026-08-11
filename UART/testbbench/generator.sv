class generator;

    transaction tg;

    mailbox #(transaction) gen_drv;

    int count = 10;

    event next_input;


    function new(mailbox #(transaction) gen_drv);

        this.gen_drv = gen_drv;
        tg = new();

    endfunction


    task run();

        repeat(count) begin

            assert(tg.randomize())
                else $error("[GEN] Randomization Failed");

            $display("--------------------------------------");
            $display("[GEN] Operation = %s", tg.oper.name());
            $display("[GEN] Data      = %0h", tg.dintx);

            gen_drv.put(tg.copy());

            // Wait until scoreboard finishes current transaction
            @(next_input);

        end

    endtask

endclass
