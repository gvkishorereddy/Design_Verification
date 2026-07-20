class first;
  int data;
  
  function first copy();
    copy=new();
    copy.data=data;
  endfunction
endclass


class second;
  int data2;
  first f1;
  function new();
    f1=new();
   endfunction
  
  function second copy();
    copy=new();
    copy.data2=data2;
    copy.f1=f1;
  endfunction
endclass


module tb;
  second s1;
  second s2;
  initial begin
    s1=new();
    s2=new();
    s1.data2=1;
    s1.f1.data=2;
    $display("Initial values s1 %0d, %0d",s1.data2,s1.f1.data);
    $display("Initial values s2 %0d, %0d",s2.data2,s2.f1.data);
    s2=s1.copy();
    $display("Copied values s1 %0d, %0d",s1.data2,s1.f1.data);
    $display("Copied values s2 %0d, %0d",s2.data2,s2.f1.data);
    s2.data2=99;
    s2.f1.data=98;
    $display("After change values s1 %0d, %0d",s1.data2,s1.f1.data);
    $display("After change values s2 %0d, %0d",s2.data2,s2.f1.data);
  end
endmodule
