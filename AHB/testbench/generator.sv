class generator;
  
  transaction tr;
  
  mailbox #(transaction) mbxgd;
  
  mailbox #(bit [4:0]) mbxgm;
  
  
  event done; 
  event drvnext; 
  event sconext; 
 
   int count = 0;
   
  
  function new( mailbox #(transaction) mbxgd, mailbox #(bit[4:0]) mbxgm);
    this.mbxgd = mbxgd; 
    this.mbxgm = mbxgm;  
    tr =new();
  endfunction
  
  
  
    task run();
    
   repeat(count) begin
      assert(tr.randomize) else $error("Randomization Failed"); 
      $display("[GEN] : DATA SENT TO DRV");
      mbxgd.put(tr.copy);
      mbxgm.put(tr.ulen);
      @(drvnext);
      @(sconext);
    end
    
    ->done;
  endtask
  
   
endclass
