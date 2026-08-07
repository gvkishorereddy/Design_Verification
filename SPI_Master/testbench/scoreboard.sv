class scoreboard;

  transaction tg;
  transaction tm;

  mailbox #(transaction) mon_sco;
  mailbox #(transaction) gen_sco;

  int count = 0;

  function new(mailbox #(transaction) mon_sco,
               mailbox #(transaction) gen_sco);
    this.mon_sco = mon_sco;
    this.gen_sco = gen_sco;
  endfunction

  task run();
    forever begin
      gen_sco.get(tg);
      mon_sco.get(tm);

      if (tg.din === tm.data_out)
        $display("Test Passed");
      else begin
        $display("Test Failed");
        $display("Expected = %0h, Got = %0h", tg.din, tm.data_out);
      end

      count++;
    end
  endtask

endclass