`include "imports.sv"

  
  module tb;
    dif dif();
    
    dff dut(dif);
    
    initial begin
      dif.clk <= '0;
    end
    
    always #10 dif.clk <= ~dif.clk;
    
    environment env;
    
    initial begin
      env = new(dif);
      env.gen.count = 10;
      env.run();
    end
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  endmodule