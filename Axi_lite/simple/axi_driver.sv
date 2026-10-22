class driver;
  transaction td;
  mailbox #(transaction) gen_drv;
  virtual axi_lite_if vif;

  function new(mailbox #(transaction) gen_drv, virtual axi_lite_if vif);
    this.gen_drv = gen_drv;
    this.vif = vif;
  endfunction

  task reset();
    vif.aresetn = 0;
    vif.awvalid = 0; vif.awaddr = 0;
    vif.wvalid = 0; vif.wdata = 0;
    vif.bready = 0;
    vif.arvalid = 0; vif.araddr = 0;
    vif.rready = 0;
    repeat (5) @(negedge vif.aclk);
    vif.aresetn = 1;
  endtask

  task write(transaction td);
    // Send address and hold it until accepted at a rising clock edge.
    @(negedge vif.aclk);
    vif.awaddr = td.awaddr;
    vif.awvalid = 1;
    do @(posedge vif.aclk); while (!vif.awready);
    @(negedge vif.aclk);
    vif.awvalid = 0;

    // Then send data. AW-first is a legal, simple AXI-Lite write.
    vif.wdata = td.wdata;
    vif.wvalid = 1;
    do @(posedge vif.aclk); while (!vif.wready);
    @(negedge vif.aclk);
    vif.wvalid = 0;

    // Accept the write response.
    vif.bready = 1;
    do @(posedge vif.aclk); while (!vif.bvalid);
    @(negedge vif.aclk);
    vif.bready = 0;
  endtask

  task read(transaction td);
    @(negedge vif.aclk);
    vif.araddr = td.araddr;
    vif.arvalid = 1;
    do @(posedge vif.aclk); while (!vif.arready);
    @(negedge vif.aclk);
    vif.arvalid = 0;

    vif.rready = 1;
    do @(posedge vif.aclk); while (!vif.rvalid);
    @(negedge vif.aclk);
    vif.rready = 0;
  endtask

  task run();
    forever begin
      gen_drv.get(td);
      if (td.op == 1) write(td);
      else read(td);
    end
  endtask
endclass
