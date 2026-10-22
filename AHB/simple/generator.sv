class generator;
  transaction tr;
  mailbox #(transaction) mbxgd;
  event sconext;
  int count = 100;

  function new(mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;
  endfunction

  task run();
    repeat (count) begin
      tr = new();
      if (!tr.randomize()) $fatal(1, "Randomization failed");
      $display("[GEN] write=%0b addr=%0d data=%0d", tr.hwrite, tr.haddr, tr.hwdata);
      mbxgd.put(tr);
      @(sconext);
    end
  endtask
endclass
