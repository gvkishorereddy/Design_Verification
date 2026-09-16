class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  event done; ///gen completed sending requested no. of transaction
  event drvnext; /// dr complete its wor;
  event sconext; ///scoreboard complete its work
 
   int count = 0;
  
  function new( mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;   
    tr =new();
  endfunction
  
    task run();
    
      for(int i=0; i< count; i++) begin
      assert(tr.randomize) else $error("Randomization Failed"); 
      $display("------------------------------------------");
      tr.display("GEN");
      mbxgd.put(tr.copy); 
      @(drvnext);
      @(sconext);
      end
      
    ->done;
      
  endtask
  
   
endclass
