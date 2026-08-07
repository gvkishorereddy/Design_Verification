class monitor;

  transaction tm;
  virtual vif vif;
  mailbox #(transaction) mon_sco;
  bit [11:0] srx;

  event mon_done;

  function new(virtual vif vif,
               mailbox #(transaction) mon_sco,
               event mon_done);
    this.vif      = vif;
    this.mon_sco  = mon_sco;
    this.mon_done = mon_done;
  endfunction

  task run();
    forever begin
      // Start of SPI frame
      wait (vif.cs === 1'b0);

      tm  = new();
      srx = '0;

      // Capture 12 bits, LSB first
      for (int i = 0; i < 12; i++) begin
        @(posedge vif.sclk);
        #1step;
        srx[i] = vif.mosi;
      end

      // Wait for end of frame before publishing
      wait (vif.cs === 1'b1);

      tm.cs       = vif.cs;
      tm.mosi     = vif.mosi;
      tm.data_out = srx;

      tm.display("[MON]");
      mon_sco.put(tm.copy());

      // Allow generator to send next transaction
      -> mon_done;
    end
  endtask

endclass
