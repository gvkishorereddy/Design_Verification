class monitor;
  mailbox #(transaction) mon_sco;
  virtual spi_if vif;
  transaction tm;
  
  function new(mailbox #(transaction) mon_sco,virtual spi_if vif);
    this.mon_sco=mon_sco;
    this.vif=vif;
  endfunction
  
  task run();
    forever begin
      @(posedge vif.done);
		tm = new();
		tm.dout = vif.dout;
		mon_sco.put(tm.copy());
    end
  endtask
endclass