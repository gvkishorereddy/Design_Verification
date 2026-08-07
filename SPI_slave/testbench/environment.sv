
class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;
  mailbox #(transaction) mon_sco;
  virtual spi_if vif;
  
  function new(virtual spi_if vif);
    this.vif=vif;
    gen_drv=new();
    gen_sco=new();
    mon_sco=new();
    gen = new(gen_drv,gen_sco);
    drv=new(gen_drv,vif);
    mon=new(mon_sco,vif);
    sco=new(mon_sco,gen_sco);
    gen.next_input=sco.next_input;
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
    wait(sco.count == gen.count);
    $finish;
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass
