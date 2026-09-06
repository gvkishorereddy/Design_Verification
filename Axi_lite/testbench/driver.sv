



class driver;
  transaction td;
  mailbox #(transaction) gen_drv;
  mailbox #(transaction) drv_mon;
  virtual axi_if vif;
  
  function new(mailbox #(transaction) gen_drv,mailbox #(transaction) drv_mon);
    this.gen_drv=gen_drv;
    this.drv_mon=drv_mon;
  endfunction
  
  task reset();
  vif.resetn  <= 1'b0;

  vif.awvalid <= 1'b0;
  vif.awaddr  <= 32'd0;

  vif.wvalid  <= 1'b0;
  vif.wdata   <= 32'd0;

  vif.bready  <= 1'b0;

  vif.arvalid <= 1'b0;
  vif.araddr  <= 32'd0;

  vif.rready  <= 1'b0;

  repeat (5) @(posedge vif.clk);

  vif.resetn <= 1'b1;

  repeat (2) @(posedge vif.clk);
    $display("RESET DONE");
endtask
  
  task write(input transaction td);
    $display("[DRV] : OP : %0b awaddr : %0d wdata : %0d ",td.op, td.awaddr, td.wdata);
    drv_mon.put(td);
    vif.resetn <= 1'b1;
    vif.awaddr <= td.awaddr;
    vif.awvalid <= 1'b1;
    //disable read
    vif.arvalid <= 1'b0;
    @(negedge vif.awready);
    vif.wdata <= td.wdata;
    vif.wvalid <= 1'b1;
    //diable addr control
    vif.awvalid <= 1'b0;
    vif.awaddr <= 1'b0;
    @(negedge vif.wready);
    vif.bready <= 1'b1;
    //disable wdata
    vif.wdata <= 1'b0;
    vif.wvalid <= 1'b0;
    //disable read 
    vif.rready <= 1'b0;
    @(negedge vif.bvalid);
    vif.bready <= 1'b0;
    
  endtask
  
  task read(input transaction td);
    $display("[DRV] : OP : %0b araddr : %0d ",td.op, td.araddr);
    drv_mon.put(td);
    vif.resetn <= 1'b1;
    vif.araddr <= td.araddr;
    vif.arvalid <= 1'b1;
    //disable write
    vif.awvalid <= 1'b0;
    vif.awaddr <= 1'b0;
    vif.wvalid <= 1'b0;
    vif.wdata <= 1'b0;
    vif.bready <= 1'b0;
    @(negedge vif.arready);
    vif.rready <= 1'b1;
    //diable read addr
    vif.arvalid <= 1'b0;
    vif.araddr <= 1'b0;
    @(negedge vif.rvalid);
    vif.rready <= 1'b0;
  endtask
  
  task run();
    forever begin
      gen_drv.get(td);
      @(posedge vif.clk);
      if(td.op == 1'b1)
        write(td);
      else
        read(td);
    end
  endtask
endclass