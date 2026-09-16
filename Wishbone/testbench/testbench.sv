module tb;
   
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
 
  event drvnext, sconext;
  event done;
  
  mailbox #(transaction) mbxgd;
  mailbox #(transaction) mbxms;
  
  wb_if vif();
  mem_wb dut (vif.clk, vif.we, vif.strb, vif.rst, vif.addr, vif.wdata, vif.rdata, vif.ack);
 
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;
  
  initial begin
 
    mbxgd = new();
    mbxms = new();
    gen = new(mbxgd);
    drv = new(mbxgd);
    mon = new(mbxms);
    sco = new(mbxms);
    gen.count = 10;
    drv.vif = vif;
    mon.vif = vif;
    
    drv.drvnext = drvnext;
    gen.drvnext = drvnext;
    
    gen.sconext = sconext;
    sco.sconext = sconext;
    
  end
  
  initial begin
      drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none  
    wait(gen.done.triggered);
    $finish();
  end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;   
  end
 
 
endmodule
