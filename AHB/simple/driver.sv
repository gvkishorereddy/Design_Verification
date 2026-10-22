class driver;
  virtual ahb_if vif;
  transaction tr;
  mailbox #(transaction) mbxgd;

  function new(mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;
  endfunction

  task reset();
    vif.hresetn = 0;
    vif.hsel = 0; vif.htrans = `IDLE;
    vif.hwrite = 0; vif.haddr = 0; vif.hwdata = 0;
    vif.hsize = 3'b010; vif.hburst = 3'b000;
    repeat (5) @(negedge vif.clk);
    vif.hresetn = 1;
  endtask

  task transfer();
    // Address phase: place address/control before the sampling clock edge.
    @(negedge vif.clk);
    vif.hsel = 1;
    vif.htrans = `NON_SEQ;
    vif.haddr = tr.haddr;
    vif.hwrite = tr.hwrite;
    vif.hsize = tr.hsize;
    vif.hburst = tr.hburst;
    do @(posedge vif.clk); while (!vif.hready);

    // Data phase: the address was accepted; offer IDLE for the next request.
    @(negedge vif.clk);
    vif.hsel = 0;
    vif.htrans = `IDLE;
    vif.hwdata = tr.hwdata;
    do @(posedge vif.clk); while (!vif.hready);

    @(negedge vif.clk);
    vif.hwdata = 0;
  endtask

  task run();
    forever begin
      mbxgd.get(tr);
      transfer();
    end
  endtask
endclass
