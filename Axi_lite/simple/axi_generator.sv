class generator;
  transaction tg;
  mailbox #(transaction) gen_drv;
  event next_input;
  int count = 100;

  function new(mailbox #(transaction) gen_drv);
    this.gen_drv = gen_drv;
  endfunction

  task run();
    repeat (count) begin
      tg = new();
      if (!tg.randomize()) $fatal(1, "Randomization failed");
      gen_drv.put(tg);
      $display("[GEN] op=%0b awaddr=%0d wdata=%0d araddr=%0d",
               tg.op, tg.awaddr, tg.wdata, tg.araddr);
      @(next_input);
    end
  endtask
endclass
