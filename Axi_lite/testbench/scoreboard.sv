

class scoreboard;
  transaction ts;
  mailbox #(transaction) mon_sco;
  int count = 0;
  event next_input;
  
  bit [31:0] temp;
  bit [31:0] data[128] = '{default:0};
  
  function new(mailbox #(transaction) mon_sco);
    this.mon_sco = mon_sco;
  endfunction
  
  task run();
    forever begin
      mon_sco.get(ts);
      if(ts.op == 1'b1) begin
        $display("[SCO] : OP : %0b awaddr : %0d wdata : %0d wresp : %0d",ts.op, ts.awaddr, ts.wdata, ts.wresp);
        if(ts.wresp == 3)
        	$display("[SCO] DEC Error");
        else begin
          data[ts.awaddr] = ts.wdata;
          $display("[SCO] : DATA STORED ADDR :%0d and DATA :%0d", ts.awaddr, ts.wdata);
        end
      end
      else begin
        $display("[SCO] : OP : %0b araddr : %0d rdata : %0d rresp : %0d",ts.op, ts.araddr, ts.rdata, ts.rresp);
        temp = data[ts.araddr];
        if(ts.rresp == 3) 
          $display("[SCO] DEc ERRor");
        else begin
          if(temp == ts.rdata  && ts.rresp==0)
            $display("[SCO] Data matched");
          else
            $display("[SCO] Data mismatch");
        end
      end
      count++;
      ->next_input;
    end
  endtask
endclass