class driver;
  transaction td;
  mailbox #(transaction) gen_drv;
  virtual i2c_if vif;

  function new(mailbox #(transaction) gen_drv, virtual i2c_if vif);
    this.gen_drv = gen_drv;
    this.vif     = vif;
  endfunction

  task reset();
    vif.rst  <= 1'b1;
    vif.newd <= 1'b0;
    vif.addr <= '0;
    vif.op   <= 1'b0;
    vif.din  <= '0;
    repeat(5) @(posedge vif.clk);
    vif.rst  <= 1'b0;
    @(posedge vif.clk);
    $display("[DRV] Reset done");
  endtask

  task write();
    vif.rst  <= 1'b0;
    vif.op   <= 1'b0;
    vif.newd <= 1'b1;
    vif.addr <= td.addr;
    vif.din  <= td.din;

    @(posedge vif.clk);
    vif.newd <= 1'b0; // 1 cycle start pulse

    @(posedge vif.done);
    $display("[DRV] WRITE done | ADDR:0x%0h DIN:0x%0h", td.addr, td.din);
  endtask

  task read();
    vif.rst  <= 1'b0;
    vif.op   <= 1'b1;
    vif.newd <= 1'b1;
    vif.addr <= td.addr;
    vif.din  <= '0;

    @(posedge vif.clk);
    vif.newd <= 1'b0;

    @(posedge vif.done);
    $display("[DRV] READ done  | ADDR:0x%0h DOUT:0x%0h", td.addr, vif.dout);
  endtask

  task run();
    forever begin
      gen_drv.get(td);
      if (td.op == 1'b0)
        write();
      else
        read();
    end
  endtask
endclass

