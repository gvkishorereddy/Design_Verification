class driver;
  transaction td;
  mailbox #(transaction) gen_drv;
  virtual spi_if vif;
  bit [11:0] temp;
  function new(mailbox #(transaction) gen_drv,virtual spi_if vif);
    this.gen_drv=gen_drv;
    this.vif=vif;
  endfunction
  
  task reset();
    vif.rst = 1'b1;
    vif.cs=1'b1;
    vif.mosi='0;
    repeat(2) @(posedge vif.sclk);
    vif.rst = 1'b0;
  endtask
  
  task run();
  forever begin
    gen_drv.get(td);

    @(negedge vif.sclk);
    vif.cs   <= 1'b0;
    vif.mosi <= td.din[0];

    for (int i = 1; i < 12; i++) begin
      @(negedge vif.sclk);
      vif.mosi <= td.din[i];
    end

    @(negedge vif.sclk);
    vif.cs <= 1'b1;
  end
endtask

  
endclass