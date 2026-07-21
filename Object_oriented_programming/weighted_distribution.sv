class generator;
  rand bit wr;
  rand bit rst;
  constraint control_sig {
    rst dist {0:=30,1:=70};
    wr dist {1:=50,0:=50};
  };
endclass

module tb;
  generator g;
	int fail_count=0;
  initial begin
    g = new();

    for (int i = 0; i < 20; i++) begin
      if (g.randomize())
        $display("rst=%0d wr=%0d", g.rst, g.wr);
      else begin
        fail_count++;
        $display("Randomization Failed");
      end
      #20;
      $display("Time %0t",$time);
    end
    $display("Failure Count %0d",fail_count);
    
  end
endmodule
