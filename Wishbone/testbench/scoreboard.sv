class scoreboard;
  transaction tr;
  event sconext;
  
  mailbox #(transaction) mbxms;
  
  bit [7:0] data[256] = '{default:0};
  
    
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  task run();
   forever begin
    mbxms.get(tr);
    if(tr.strb == 1'b0) 
            begin
            $display("[SCO] : INVALID STROBE");
            end
    else 
      begin
          
          if(tr.we == 1'b1)
                      begin
                       data[tr.addr] = tr.wdata;
                        $display("[SCO] : DATA WRITE DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                      end  
          else 
             begin
                    if(tr.rdata == 8'h11)
                     begin
                     $display("[SCO] : DATA MATCHED : DEFAULT VALUE READ");
                     end
                     else if (tr.rdata == data[tr.addr])
                     begin
                       $display("[SCO] : DATA MATCHED DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                     end
                     else
                     begin
                       $display("[SCO] : DATA MISMATCHED DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                     end 
             end
        end
      $display("------------------------------------------");
     ->sconext; 
   end
  endtask
endclass
