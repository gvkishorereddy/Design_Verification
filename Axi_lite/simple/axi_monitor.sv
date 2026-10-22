// All observations come from interface handshakes, not the driver.
class monitor;
  transaction tw, tr;
  mailbox #(transaction) mon_sco;
  virtual axi_lite_if vif;

  function new(mailbox #(transaction) mon_sco, virtual axi_lite_if vif);
    this.mon_sco = mon_sco;
    this.vif = vif;
  endfunction

  task run();
    tw = new();
    tr = new();
    forever begin
      @(posedge vif.aclk);
      if (vif.aresetn) begin
        if (vif.awvalid && vif.awready) tw.awaddr = vif.awaddr;
        if (vif.wvalid && vif.wready) tw.wdata = vif.wdata;
        if (vif.bvalid && vif.bready) begin
          tw.op = 1;
          tw.wresp = vif.bresp;
          mon_sco.put(tw);
          tw = new(); // Separate object for the next write.
        end

        if (vif.arvalid && vif.arready) tr.araddr = vif.araddr;
        if (vif.rvalid && vif.rready) begin
          tr.op = 0;
          tr.rdata = vif.rdata;
          tr.rresp = vif.rresp;
          mon_sco.put(tr);
          tr = new();
        end
      end
    end
  endtask
endclass
