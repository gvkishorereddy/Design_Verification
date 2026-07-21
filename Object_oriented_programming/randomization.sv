class generator;
  rand bit [4:0] a;
  rand bit [5:0] b;
  constraint range {
    a inside {[0:8]};
    b inside {[0:5]};
  };
endclass

module tb;
  generator g;
	int fail_count=0;
  initial begin
    g = new();

    for (int i = 0; i < 20; i++) begin
      if (g.randomize())
        $display("a=%0d b=%0d", g.a, g.b);
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
