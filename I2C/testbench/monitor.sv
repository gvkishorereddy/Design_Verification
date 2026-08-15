class monitor;
  transaction tm;
  mailbox #(transaction) mon_sco;
  virtual i2c_if vif;

  function new(mailbox #(transaction) mon_sco, virtual i2c_if vif);
    this.mon_sco = mon_sco;
    this.vif     = vif;
    tm           = new();
  endfunction

  task run();
    forever begin
      @(posedge vif.done); // sample output state when done pulses

      tm.din     = vif.din;
      tm.addr    = vif.addr;
      tm.op      = vif.op;
      tm.dout    = vif.dout;
      tm.ack_err = vif.ack_err;
		@(posedge vif.clk);
      mon_sco.put(tm.copy());

      $display("[MON] OP:%s ADDR:0x%0h DATA:0x%0h ACK_ERR:%0b",
               (tm.op ? "READ" : "WRITE"), tm.addr, (tm.op ? tm.dout : tm.din), tm.ack_err);
    end
  endtask
endclass
