class scoreboard;
  
  transaction tr;
  event sconext;
  
  mailbox #(transaction) mbxms; 
  
  bit [7:0] data[256] = '{default:12};
  
  int count = 0;
  int len   = 0;
  bit [31:0] rdata;
  
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    forever 
      begin  
        
      
      mbxms.get(tr);
        
         if(tr.hwrite == 1'b1) begin
           $display("[SCO] : DATA WRITE");
           data[tr.haddr] = tr.hwdata[7:0];
           data[tr.haddr + 1] = tr.hwdata[15:8];
           data[tr.haddr + 2] = tr.hwdata[23:16];
           data[tr.haddr + 3] = tr.hwdata[31:24];                               
           end
 
        if(tr.hwrite == 1'b0) begin
            rdata = {data[tr.haddr + 3], data[tr.haddr + 2], data[tr.haddr + 1], data[tr.haddr]};
             if(tr.hrdata == 32'h0c0c0c0c)    
             $display("[SCO] : EMPTY LOCATION READ");
             else if (tr.hrdata == rdata)
             $display("[SCO] : DATA MATCHED");
             else    
             $display("[SCO] : DATA MISMATCHED");
         end
         
         
         ->sconext;  
    end
  endtask
  
  
endclass
