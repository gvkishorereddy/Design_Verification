
class scoreboard;

    transaction expected;
    transaction actual;

    mailbox #(transaction) drv_sco;
    mailbox #(transaction) mon_sco;

    event next_input;

    int count = 0;


    function new(
        mailbox #(transaction) drv_sco,
        mailbox #(transaction) mon_sco
    );

        this.drv_sco = drv_sco;
        this.mon_sco = mon_sco;

    endfunction


    task run();

        forever begin

            drv_sco.get(expected);
            mon_sco.get(actual);

            $display("--------------------------------------");

            $display(
                "[SCO] Expected = %0h",
                expected.dintx
            );

            $display(
                "[SCO] Actual   = %0h",
                actual.doutrx
            );


            if(expected.dintx == actual.doutrx) begin
                $display("[SCO] TEST PASSED");
            end
            else begin
                $display("[SCO] TEST FAILED");
            end

            count++;

            -> next_input;

        end

    endtask

endclass