lass transaction;
  bit          newd;
  rand bit [6:0] addr;
  rand bit       op; // 0: write, 1: read
  rand bit [7:0] din;
  bit [7:0]    dout;
  bit          busy;
  bit          ack_err;
  bit          done;

  // target 0x50 most of the time, test invalid addrs occasionally
  constraint valid_addr_c {
    addr dist { 7'h50 := 80, [7'h00:7'h4F] :/ 10, [7'h51:7'h7F] :/ 10 };
  }

  constraint oper {
    op dist {1 := 50, 0 := 50};
  }

  function transaction copy();
    copy          = new();
    copy.newd    = this.newd;
    copy.addr    = this.addr;
    copy.op      = this.op;
    copy.din     = this.din;
    copy.dout    = this.dout;
    copy.busy    = this.busy;
    copy.ack_err = this.ack_err;
    copy.done    = this.done;
  endfunction
endclass