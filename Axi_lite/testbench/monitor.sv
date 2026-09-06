

class monitor;
  transaction td_m,tm_s;
  mailbox #(transaction) drv_mon;
  mailbox #(transaction) mon_sco;
  virtual axi_if vif;
  
  function new(mailbox #(transaction) drv_mon,mailbox #(transaction) mon_sco);
    this.drv_mon=drv_mon;
    this.mon_sco=mon_sco;
  endfunction
  
  task run();
    tm_s=new();
    forever begin
      @(posedge vif.clk);
      drv_mon.get(td_m);
      if(td_m.op==1'b1) begin
        tm_s.op = td_m.op;
        tm_s.awaddr = td_m.awaddr;
        tm_s.wdata = td_m.wdata;
        @(posedge vif.bvalid);
        tm_s.wresp = vif.wresp;
        @(negedge vif.bvalid);
        $display("[MON] : OP : %0b awaddr : %0d wdata : %0d wresp:%0d",tm_s.op, tm_s.awaddr, tm_s.wdata, tm_s.wresp);
        mon_sco.put(tm_s);
      end
      else begin
        tm_s.op = td_m.op;
        tm_s.araddr = td_m.araddr;
        @(posedge vif.rvalid);
        tm_s.rdata = vif.rdata;
        tm_s.rresp = vif.rresp;
        @(negedge vif.rvalid);
        $display("[MON] : OP : %0b araddr : %0d rdata : %0d rresp:%0d",tm_s.op, tm_s.araddr, tm_s.rdata, tm_s.rresp);
        mon_sco.put(tm_s);
      end
    end
  endtask
endclass