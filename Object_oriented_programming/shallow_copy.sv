class first;
  int data;
endclass

class second;
  int data2;
  first f1;

  function new();
    f1 = new();
  endfunction
endclass

module tb;

  second s1, s2;

  initial begin
    s1 = new();

    s1.data2 = 10;
    s1.f1.data = 20;

    // Shallow copy
    s2 = s1;

    $display("Before change");
    $display("s1: %0d %0d", s1.data2, s1.f1.data);
    $display("s2: %0d %0d", s2.data2, s2.f1.data);

    s2.data2 = 99;
    s2.f1.data = 88;

    $display("After change");
    $display("s1: %0d %0d", s1.data2, s1.f1.data);
    $display("s2: %0d %0d", s2.data2, s2.f1.data);

  end

endmodule
