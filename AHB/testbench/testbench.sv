`timescale 1ns / 1ps
module tb;
   
  monitor mon; 
  generator gen;
  driver drv;
  scoreboard sco;
   
 
   
  event nextgd;
  event nextgs;
  event done;
  
   mailbox #(transaction) mbxgd, mbxms;
   mailbox #(bit[4:0]) mbxgm;
  
  ahb_if vif();
 
  ahb_slave dut (vif.clk, vif.hwdata, vif.haddr, vif.hsize, vif.hburst, vif.hresetn, vif.hsel, vif.hwrite, vif.htrans, vif.hresp, vif.hready, vif.hrdata); 
 
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;
  
  initial begin
    mbxgd = new();
    mbxms = new();
    mbxgm = new();
    
    gen = new(mbxgd, mbxgm);
    drv = new(mbxgd);
    mon = new(mbxms, mbxgm);
    sco = new(mbxms);
    
    gen.count = 3;
    
    drv.vif = vif;
    mon.vif = vif;
    
    drv.drvnext = nextgd;
    gen.drvnext = nextgd;
    
    gen.sconext = nextgs;
    sco.sconext = nextgs;
      
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
 
assign vif.next_addr = dut.next_addr;
 
endmodule
