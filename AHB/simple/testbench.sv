`timescale 1ns/1ps
`include "ahb_defines.svh"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

module tb;
  ahb_if vif();
  mailbox #(transaction) mbxgd = new();
  mailbox #(transaction) mbxms = new();
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;

  // One slave: its HREADYOUT directly supplies the bus HREADY.
  assign vif.hready = vif.hreadyout;
  ahb_slave dut (
    .clk(vif.clk), .hresetn(vif.hresetn),
    .hsel(vif.hsel), .hwrite(vif.hwrite), .hready(vif.hready),
    .haddr(vif.haddr), .hwdata(vif.hwdata),
    .htrans(vif.htrans), .hsize(vif.hsize), .hburst(vif.hburst),
    .hrdata(vif.hrdata), .hreadyout(vif.hreadyout), .hresp(vif.hresp)
  );

  initial vif.clk = 0;
  always #5 vif.clk = ~vif.clk; // 10 ns period = 100 MHz

  initial begin
    gen = new(mbxgd);
    drv = new(mbxgd);
    mon = new(mbxms);
    sco = new(mbxms);
    drv.vif = vif;
    mon.vif = vif;
    gen.sconext = sco.sconext;
    drv.reset();
    fork
      drv.run();
      mon.run();
      sco.run();
    join_none
    gen.run();
    repeat (2) @(negedge vif.clk);
    if (sco.count != gen.count || sco.errors != 0)
      $fatal(1, "FAIL: checked=%0d errors=%0d", sco.count, sco.errors);
    if (sco.reads == 0 || sco.writes == 0)
      $fatal(1, "Both reads and writes must be exercised");
    $display("[AHB_SIMPLE_PASS] checked=%0d writes=%0d reads=%0d errors=%0d",
             sco.count, sco.writes, sco.reads, sco.errors);
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  initial begin
    #1000000;
    $fatal(1, "Watchdog: transfer did not complete");
  end
endmodule
