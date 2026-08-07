class transaction;

  logic         newd;
  rand logic [11:0] din;

  logic cs;
  logic mosi;
  logic [11:0] data_out;

  function transaction copy();
    copy = new();
    copy.newd     = this.newd;
    copy.din      = this.din;
    copy.cs       = this.cs;
    copy.mosi     = this.mosi;
    copy.data_out = this.data_out;
  endfunction

  function void display(string s);
    $display("[%s] newd=%0b din=%0h cs=%0b mosi=%0b data_out=%0h",
             s, newd, din, cs, mosi, data_out);
  endfunction

endclass