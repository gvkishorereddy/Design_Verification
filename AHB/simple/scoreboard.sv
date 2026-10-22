class scoreboard;
  transaction tr;
  mailbox #(transaction) mbxms;
  event sconext;
  bit [31:0] data [0:63];
  int count, errors, writes, reads;

  function new(mailbox #(transaction) mbxms);
    this.mbxms = mbxms;
    foreach (data[i]) data[i] = 32'h0c0c0c0c;
  endfunction

  task run();
    forever begin
      mbxms.get(tr);
      if (tr.hresp !== 1'b0) begin
        errors++;
        $error("Unexpected response: %b", tr.hresp);
      end else if (tr.hwrite) begin
        writes++;
        data[tr.haddr / 4] = tr.hwdata;
        $display("[SCO] WRITE addr=%0d data=%0d", tr.haddr, tr.hwdata);
      end else begin
        reads++;
        if (tr.hrdata !== data[tr.haddr / 4]) begin
          errors++;
          $error("READ mismatch addr=%0d expected=%0d actual=%0d",
                 tr.haddr, data[tr.haddr / 4], tr.hrdata);
        end else
          $display("[SCO] READ matched addr=%0d data=%0d", tr.haddr, tr.hrdata);
      end
      count++;
      -> sconext;
    end
  endtask
endclass
