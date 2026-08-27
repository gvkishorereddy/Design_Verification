class scoreboard;

    transaction ts;
    mailbox #(transaction) mon_sco;

    event next_stimuli;

    int count      = 0;
    int pass_count = 0;
    int fail_count = 0;

    bit [31:0] mem [0:255];

    function new(mailbox #(transaction) mon_sco);
        this.mon_sco = mon_sco;
    endfunction

    task run();
        forever begin
            mon_sco.get(ts);

            if (ts.pslverr === 1'b1) begin
                fail_count++;
                $error("[SCO] Slave error detected");
            end
            else if (ts.pwrite === 1'b1) begin
                mem[ts.paddr] = ts.pwdata;
                pass_count++;

                $display(
                    "[SCO] WRITE: Addr=%0d Data=%0d",
                    ts.paddr, ts.pwdata
                );
            end
            else begin
                if (ts.prdata === mem[ts.paddr]) begin
                    pass_count++;

                    $display(
                        "[SCO] READ PASS: Addr=%0d Expected=%0d Actual=%0d",
                        ts.paddr, mem[ts.paddr], ts.prdata
                    );
                end
                else begin
                    fail_count++;

                    $error(
                        "[SCO] READ FAIL: Addr=%0d Expected=%0d Actual=%0d",
                        ts.paddr, mem[ts.paddr], ts.prdata
                    );
                end
            end

            count++;

            // Generator sends the next transaction only after checking
            -> next_stimuli;
        end
    endtask

endclass

