class transaction;
  logic cs;
  rand logic [11:0] din;
  logic mosi;
  logic [11:0] dout;
  logic done;
  function transaction copy();
    copy = new();
    copy.cs=this.cs;
    copy.din=this.din;
    copy.mosi=this.mosi;
    copy.dout=this.dout;
    copy.done=this.done;
  endfunction
endclass