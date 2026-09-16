class driver;
 
virtual wb_if vif;
transaction tr;
event drvnext;
 
  mailbox #(transaction) mbxgd;
 
  
  function new( mailbox #(transaction) mbxgd );
    this.mbxgd = mbxgd; 
  endfunction
  
   task reset();
   vif.rst   <= 1'b1;
   vif.we    <= 0;
   vif.addr  <= 0;
   vif.wdata <= 0;
   vif.strb  <= 0;
   repeat(10) @(posedge vif.clk);
   vif.rst <= 1'b0;
   repeat(5) @(posedge vif.clk);
   $display("[DRV] : RESET DONE");
  endtask
 
  task write();
  @(posedge vif.clk);
  $display("[DRV] : DATA WRITE MODE");
  vif.rst   <= 1'b0;
  vif.we    <= 1'b1;
  vif.strb  <= 1'b1;
  vif.addr  <= tr.addr;
  vif.wdata <= tr.wdata;
  @(posedge vif.ack);
  @(posedge vif.clk);
  ->drvnext;
  endtask
  
  task read();
  @(posedge vif.clk);
  $display("[DRV] : DATA READ MODE");
  vif.rst   <= 1'b0;
  vif.we    <= 1'b0;
  vif.strb  <= 1'b1;
  vif.addr  <= tr.addr;
  @(posedge vif.ack);
  @(posedge vif.clk);
  ->drvnext;
  endtask
  
  task random();
  @(posedge vif.clk);
  $display("[DRV] : RANDOM MODE");
  vif.rst   <= 1'b0;
  vif.we    <= tr.we;
  vif.strb  <= tr.strb;
  vif.addr  <= tr.addr;
  if(tr.we == 1'b1)
  begin
  vif.wdata <= tr.wdata;
  end
  repeat(2)@(posedge vif.clk);
  ->drvnext;
  endtask
  
  
  task run();
   forever begin
     mbxgd.get(tr);
     if(tr.opmode == 0) 
     begin
       write();
     end  
     else if (tr.opmode == 1) 
     begin
       read();
     end  
     else if(tr.opmode == 2) 
     begin
       random();
     end  
   end
  endtask
  
 
endclass
