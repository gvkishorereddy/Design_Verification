class scoreboard;
    mailbox #(transaction) mbx_ms;
    mailbox #(transaction) mbx_gs;
    transaction tgs;
    transaction tms;
    
    event sconext;
    
    function new(mailbox #(transaction) mbx_ms,mailbox #(transaction) mbx_gs);
      this.mbx_ms=mbx_ms;
      this.mbx_gs=mbx_gs;
    endfunction
    
    task run();
      forever begin
        mbx_ms.get(tms); //from monitor
        mbx_gs.get(tgs); //from generator
        if(tms.dout === tgs.din)
          $display("Matched");
        else
          $display("Wrong X");
        ->sconext;
      end
    endtask
  endclass
  