module tb;
  
  spi_if vif();
  spi_slave dut(.sclk(vif.sclk),.rst(vif.rst),.cs(vif.cs),.mosi(vif.mosi),.dout(vif.dout),.done(vif.done));
  
  environment env;
  
  initial begin
    env = new(vif);
    env.run();
  end
  
  initial vif.sclk = 1'b0;
  
  always #5 vif.sclk = ~vif.sclk;
  
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule