class driver;

  virtual vif vif;
  mailbox #(transaction) gen_drv;
  transaction td;

  function new(virtual vif vif,
               mailbox #(transaction) gen_drv);
    this.vif     = vif;
    this.gen_drv = gen_drv;
  endfunction

  task reset();
    vif.rst  <= 1'b1;
    vif.newd <= 1'b0;
    vif.din  <= '0;
    repeat (2) @(posedge vif.clk);
    vif.rst  <= 1'b0;
    $display("Reset Done");
  endtask

  task run();
    forever begin
      gen_drv.get(td);

      // Wait until bus is idle before starting a new transfer
      wait (vif.cs === 1'b1);

      @(posedge vif.clk);
      vif.din  <= td.din;
      vif.newd <= 1'b1;

      // DUT accepts transaction on sclk edge and pulls cs low
      wait (vif.cs === 1'b0);

      @(posedge vif.clk);
      vif.newd <= 1'b0;

      // Wait for transaction to finish
      wait (vif.cs === 1'b1);

      td.cs   = vif.cs;
      td.mosi = vif.mosi;
      td.display("[DRV]");
    end
  endtask

endclass
