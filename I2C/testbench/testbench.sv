module tb;
  i2c_if vif();
  environment env;

  i2c_top #(
    .SYS_FREQ(40_000_000),
    .I2C_FREQ(100_000),
    .SLAVE_ADDR(7'h50)
  ) dut (
    .clk(vif.clk),
    .rst(vif.rst),
    .newd(vif.newd),
    .addr(vif.addr),
    .op(vif.op),
    .din(vif.din),
    .dout(vif.dout),
    .busy(vif.busy),
    .done(vif.done),
    .ack_err(vif.ack_err)
  );

  // 40 MHz clock (25 ns period)
  initial begin
    vif.clk = 0;
    forever #12.5 vif.clk = ~vif.clk;
  end

  initial begin
    env = new(vif);
    env.gen.count = 20; // total transactions to generate
    env.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
endmodule