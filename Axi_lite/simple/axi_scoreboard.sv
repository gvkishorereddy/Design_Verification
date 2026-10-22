class scoreboard;
  transaction ts;
  mailbox #(transaction) mon_sco;
  event next_input;
  bit [31:0] data [0:127];
  int count, errors, writes, reads;

  function new(mailbox #(transaction) mon_sco);
    this.mon_sco = mon_sco;
    foreach (data[i]) data[i] = 0;
  endfunction

  task run();
    forever begin
      mon_sco.get(ts);
      if (ts.op == 1) begin
        writes++;
        if (ts.wresp !== 2'b00) begin
          errors++;
          $error("Write response error: %b", ts.wresp);
        end else begin
          data[ts.awaddr / 4] = ts.wdata;
          $display("[SCO] WRITE addr=%0d data=%0d", ts.awaddr, ts.wdata);
        end
      end else begin
        reads++;
        if (ts.rresp !== 2'b00 || ts.rdata !== data[ts.araddr / 4]) begin
          errors++;
          $error("Read mismatch addr=%0d expected=%0d actual=%0d resp=%b",
                 ts.araddr, data[ts.araddr / 4], ts.rdata, ts.rresp);
        end else
          $display("[SCO] READ matched addr=%0d data=%0d", ts.araddr, ts.rdata);
      end
      count++;
      -> next_input;
    end
  endtask
endclass
