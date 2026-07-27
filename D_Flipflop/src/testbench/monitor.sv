class monitor;
  transaction tm; //monitor data from dut interface
  virtual dif dif;
  mailbox #(transaction) mbx_ms;
  
  function new(mailbox #(transaction) mbx_ms);
    this.mbx_ms=mbx_ms;
    tm=new();
  endfunction
  
  task run();
    forever begin
      repeat(2) @(posedge dif.clk);
      tm.dout = dif.dout;
      mbx_ms.put(tm.copy());
      tm.display("MON");
    end
  endtask
endclass