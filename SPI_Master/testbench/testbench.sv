module tb;

  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard sco;

  vif vif();

  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;
  mailbox #(transaction) mon_sco;

  event mon_done;

  spi dut (
    .clk  (vif.clk),
    .newd (vif.newd),
    .rst  (vif.rst),
    .din  (vif.din),
    .sclk (vif.sclk),
    .cs   (vif.cs),
    .mosi (vif.mosi)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end

  initial begin
    vif.clk = 1'b0;
    forever #5 vif.clk = ~vif.clk;
  end

  initial begin
    gen_drv = new();
    gen_sco = new();
    mon_sco = new();

    gen = new(gen_drv, gen_sco, mon_done);
    drv = new(vif, gen_drv);
    mon = new(vif, mon_sco, mon_done);
    sco = new(mon_sco, gen_sco);

    drv.reset();

    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none

    wait (sco.count == gen.count);
    #20;
    $finish;
  end

endmodule