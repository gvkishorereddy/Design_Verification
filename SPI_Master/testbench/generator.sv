class generator;
  transaction t;
  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;

  int count = 10;
  event mon_done;

  function new(mailbox #(transaction) gen_drv,
               mailbox #(transaction) gen_sco,
               event mon_done);
    this.gen_drv  = gen_drv;
    this.gen_sco  = gen_sco;
    this.mon_done = mon_done;
  endfunction

  task run();
    repeat (count) begin
      t = new();

      if (!t.randomize())
        $fatal(1, "Randomization failed");

      t.newd = 1'b1;

      gen_drv.put(t.copy());
      gen_sco.put(t.copy());

      // Wait until monitor finishes this transaction
      @(mon_done);
    end
  endtask

endclass