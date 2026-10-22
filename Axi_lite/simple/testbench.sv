`timescale 1ns/1ps
`include "axi_transaction.sv"
`include "axi_generator.sv"
`include "axi_driver.sv"
`include "axi_monitor.sv"
`include "axi_scoreboard.sv"

module tb;
  axi_lite_if vif();
  mailbox #(transaction) gen_drv = new();
  mailbox #(transaction) mon_sco = new();
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;

  axi_lite_slave dut (
    .aclk(vif.aclk), .aresetn(vif.aresetn),
    .awaddr(vif.awaddr), .awvalid(vif.awvalid), .awready(vif.awready),
    .wdata(vif.wdata), .wvalid(vif.wvalid), .wready(vif.wready),
    .bresp(vif.bresp), .bvalid(vif.bvalid), .bready(vif.bready),
    .araddr(vif.araddr), .arvalid(vif.arvalid), .arready(vif.arready),
    .rdata(vif.rdata), .rresp(vif.rresp), .rvalid(vif.rvalid), .rready(vif.rready)
  );

  initial vif.aclk = 0;
  always #5 vif.aclk = ~vif.aclk; // 10 ns period, 100 MHz

  initial begin
    gen = new(gen_drv);
    drv = new(gen_drv, vif);
    mon = new(mon_sco, vif);
    sco = new(mon_sco);
    gen.next_input = sco.next_input;
    drv.reset();
    fork
      drv.run();
      mon.run();
      sco.run();
    join_none
    gen.run();
    // Allow the final response handshake's falling-edge cleanup to finish.
    repeat (2) @(negedge vif.aclk);
    if (sco.count != gen.count || sco.errors != 0)
      $fatal(1, "FAIL: checked=%0d errors=%0d", sco.count, sco.errors);
    if (sco.reads == 0 || sco.writes == 0)
      $fatal(1, "Both reads and writes must be exercised");
    $display("[AXI_SIMPLE_PASS] checked=%0d writes=%0d reads=%0d errors=%0d",
             sco.count, sco.writes, sco.reads, sco.errors);
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  initial begin
    #1000000;
    $fatal(1, "Watchdog timeout: handshake or synchronization stalled");
  end
endmodule
