class generator;
  transaction tg;
  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;

  event next_stimuli;
  int count = 0;

  function new(mailbox #(transaction) gen_drv, mailbox #(transaction) gen_sco);
    this.gen_drv = gen_drv;
    this.gen_sco = gen_sco;
    tg = new();
  endfunction

  task run();
    repeat(count) begin
      assert(tg.randomize()) else $error("[GEN] Randomization failed");

      gen_drv.put(tg.copy());
      gen_sco.put(tg.copy());

      $display("[GEN] OP:%s ADDR:0x%0h DIN:0x%0h", (tg.op ? "READ" : "WRITE"), tg.addr, tg.din);

      @(next_stimuli); // wait for scoreboard check before sending next
    end
  endtask
endclass

