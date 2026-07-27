class generator;
  transaction t; //gen 2 drv and gen 2 sco
  mailbox #(transaction) mbx_gd;
  mailbox #(transaction) mbx_gs;
  
  int count;//number of stimulus
  
  event sconext;
  event done;
  
  function new(mailbox #(transaction) mbx_gd,mailbox #(transaction) mbx_gs);
    this.mbx_gd=mbx_gd;
    this.mbx_gs=mbx_gs;
    t=new();
  endfunction
  
  task run();
    repeat(count) begin
      assert(t.randomize()) else $display("Randomization Failed");
      mbx_gd.put(t.copy());
      mbx_gs.put(t.copy());
      t.display("GEN");
      @(sconext);
    end
    ->done;
  endtask
endclass