class scoreboard;
  transaction tr_gen, tr_mon;
  mailbox #(transaction) gen_sco;
  mailbox #(transaction) mon_sco;

  event next_stimuli;

  bit [7:0] ref_mem [128]; // reference memory model
  int pass_count = 0;
  int fail_count = 0;

  function new(mailbox #(transaction) gen_sco, mailbox #(transaction) mon_sco);
    this.gen_sco = gen_sco;
    this.mon_sco = mon_sco;
    foreach (ref_mem[i]) ref_mem[i] = '0;
  endfunction

  task run();
    forever begin
      gen_sco.get(tr_gen);
      mon_sco.get(tr_mon);

      // check unmapped address ACK error
      if (tr_gen.addr != 7'h50) begin
        if (tr_mon.ack_err == 1'b1) begin
          $display("[SCO] PASS: Invalid addr 0x%0h raised ACK_ERR", tr_gen.addr);
          pass_count++;
        end else begin
          $error("[SCO] FAIL: Invalid addr 0x%0h missed ACK_ERR", tr_gen.addr);
          fail_count++;
        end
      end
      // check valid slave transfers
      else begin
        if (tr_mon.ack_err == 1'b1) begin
          $error("[SCO] FAIL: Unexpected ACK_ERR on addr 0x%0h", tr_gen.addr);
          fail_count++;
        end
        else if (tr_gen.op == 1'b0) begin // WRITE
          ref_mem[tr_gen.addr] = tr_gen.din;
          $display("[SCO] WRITE PASS: Mem[0x%0h] = 0x%0h", tr_gen.addr, tr_gen.din);
          pass_count++;
        end
        else begin // READ
          if (tr_mon.dout == ref_mem[tr_gen.addr]) begin
            $display("[SCO] READ PASS: Addr 0x%0h Data 0x%0h matched", tr_gen.addr, tr_mon.dout);
            pass_count++;
          end else begin
            $error("[SCO] READ FAIL: Addr 0x%0h | Exp: 0x%0h, Got: 0x%0h",
                   tr_gen.addr, ref_mem[tr_gen.addr], tr_mon.dout);
            fail_count++;
          end
        end
      end

      ->next_stimuli;
    end
  endtask
endclass
