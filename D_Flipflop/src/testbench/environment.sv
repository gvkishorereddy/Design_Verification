class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    
    event sconext;
    
    mailbox #(transaction) mbx_ms;
    mailbox #(transaction) mbx_gs;
    mailbox #(transaction) mbx_gd;

    virtual dif dif;
    
    function new(virtual dif dif);
      this.dif=dif;
      mbx_gd=new();
      mbx_gs=new();
      mbx_ms=new();
      
      gen = new(mbx_gd,mbx_gs);
      drv = new(mbx_gd);
      mon = new(mbx_ms);
      sco = new(mbx_ms,mbx_gs);
      
      drv.dif = this.dif;
      mon.dif=this.dif;
      
      gen.sconext = this.sconext;
      sco.sconext = this.sconext;
    endfunction
    
    task pre_test();
      drv.reset();
    endtask
    
    task test();
      fork
        gen.run();
        drv.run();
        mon.run();
        sco.run();
      join_none
    endtask
    
    task post_test();
      wait(gen.done.triggered);
      $finish();
    endtask
    
    task run();
      pre_test();
      test();
      post_test();
    endtask
    
    
    
  endclass
  