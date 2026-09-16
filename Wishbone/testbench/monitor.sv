class monitor;
    
  virtual wb_if vif;
  transaction tr;
  
  mailbox #(transaction) mbxms;
 
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    tr = new();
    
    forever 
      begin 
        wait( vif.rst == 1'b0); 
       repeat(5) @(posedge vif.clk);
        @(posedge vif.clk);
        if(vif.strb == 1'b0)
        begin
        tr.strb = vif.strb;
        repeat(2) @(vif.clk);
        $display("[MON] : STRB IS ZERO");
        mbxms.put(tr);  
        end
        else
        begin
        @(posedge vif.ack);
        tr.we = vif.we;
        tr.strb = vif.strb;
        tr.wdata = vif.wdata;
        tr.addr = vif.addr;
        tr.rdata = vif.rdata; 
        @(posedge vif.clk);
        $display("[MON] : STRB IS VALID");
        mbxms.put(tr);  
        end
      end 
  endtask
 
endclass
