class generator;
  rand bit wr;
  rand bit [3:0] addr;
  
  constraint operators{
    if(wr==1){
      addr inside {[0:7]};
    }
      else{
        addr inside {[8:15]};
      }
  }
endclass

module tb;
  generator g;
	int fail_count=0;
  initial begin
    g = new();

    for (int i = 0; i < 20; i++) begin
      if (g.randomize())
        $display("wr=%0d address=%0d", g.wr, g.addr);
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
