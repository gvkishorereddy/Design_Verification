class transaction;
  randc bit [3:0] a,b;
  bit [7:0] mul;
  
  function transaction copy();
    copy=new();
    copy.a=a;
    copy.b=b;
    copy.mul=mul;
  endfunction
  function void post_randomize();
    mul = a * b;
  endfunction
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  virtual inter i;
  event drv_done;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    t = new();
  endfunction

  task run();
    for (int i = 0; i < 10; i++) begin
      @(negedge this.i.clk);
      assert(t.randomize());

      mbx.put(t.copy());
      $display("[GEN] Data sent a = %0d, b = %0d", t.a, t.b);

      @(drv_done);   // wait for driver to finish this transaction
    end
    $finish();
  endtask
endclass

class driver;
  transaction t;
  mailbox #(transaction) mbx;
  virtual inter i;
  event drv_done;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task get();
    forever begin
      mbx.get(t);

      @(negedge i.clk);
      i.a = t.a;
      i.b = t.b;

      @(posedge i.clk);
      #1;

      $display("[DRV] Data received a = %0d, b = %0d", t.a, t.b);
      $display("Golden Data mul = %0d", t.mul);
      $display("[DUT] Output mul = %0d", i.mul);

      -> drv_done;
    end
  endtask
endclass

interface inter;
  bit [3:0] a,b;
  bit [7:0] mul;
  bit clk;
endinterface

module tb;
  mailbox #(transaction) mbx;
  generator gen;
  driver drv;
  inter i();
  
  top dut(.clk(i.clk),.a(i.a),.b(i.b),.mul(i.mul));
  
  initial begin
    i.clk=0;
  end
  
  always #10 i.clk = ~ i.clk;
  
  initial begin
  mbx = new();
  gen = new(mbx);
  drv = new(mbx);

  gen.i = i;
  drv.i = i;

  gen.drv_done = drv.drv_done;

  fork
    gen.run();
    drv.get();
  join_none
end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
