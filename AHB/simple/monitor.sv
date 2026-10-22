// Independent bus observer: no driver messages or internal DUT signals.
class monitor;
  virtual ahb_if vif;
  transaction tr;
  mailbox #(transaction) mbxms;
  bit pending;

  function new(mailbox #(transaction) mbxms);
    this.mbxms = mbxms;
  endfunction

  task run();
    forever begin
      @(posedge vif.clk);
      if (!vif.hresetn) pending = 0;
      else if (vif.hready) begin
        // Complete the transfer whose address was captured previously.
        if (pending) begin
          tr.hwdata = vif.hwdata;
          tr.hrdata = vif.hrdata;
          tr.hresp = vif.hresp;
          mbxms.put(tr);
        end

        // Capture the next address only if its transfer type is valid.
        pending = vif.hsel && vif.htrans[1];
        if (pending) begin
          tr = new();
          tr.haddr = vif.haddr;
          tr.hwrite = vif.hwrite;
          tr.hsize = vif.hsize;
          tr.hburst = vif.hburst;
        end
      end
    end
  endtask
endclass
