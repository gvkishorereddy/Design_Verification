class generator;
  
  transaction tg;
  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;
  
  int count = 2;
  event next_input;
  
  function new(mailbox #(transaction) gen_drv,mailbox #(transaction) gen_sco);
    this.gen_drv=gen_drv;
    this.gen_sco=gen_sco;
    tg=new();
  endfunction
  
  task run();
    repeat(count) begin
      if (!tg.randomize())
        $fatal(1, "Randomization failed");
      gen_drv.put(tg.copy());
      gen_sco.put(tg.copy());
      $display("Input at Generator %0d",tg.din);
      @(next_input);
    end
  endtask
endclass
