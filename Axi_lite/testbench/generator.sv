class generator;
  transaction tg;
  mailbox #(transaction) gen_drv;
  
  function new(mailbox #(transaction) gen_drv);
    this.gen_drv=gen_drv;
    tg=new();
  endfunction
  
  event next_input;
  int count = 0;
  
  task run();
    repeat (count) begin
      assert (tg.randomize()) else $error("Randomization failed");
      gen_drv.put(tg);
      $display("[GEN] : OP : %0b awaddr : %0d wdata : %0d araddr : %0d",tg.op, tg.awaddr, tg.wdata, tg.araddr);
      @(next_input);
    end
  endtask
  
endclass