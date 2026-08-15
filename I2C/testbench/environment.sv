class environment;
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard sco;

  mailbox #(transaction) gen_drv;
  mailbox #(transaction) gen_sco;
  mailbox #(transaction) mon_sco;

  virtual i2c_if vif;

  function new(virtual i2c_if vif);
    this.vif = vif;

    gen_drv = new();
    gen_sco = new();
    mon_sco = new();

    gen = new(gen_drv, gen_sco);
    drv = new(gen_drv, vif);
    mon = new(mon_sco, vif);
    sco = new(gen_sco, mon_sco);

    gen.next_stimuli = sco.next_stimuli;
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
    wait(gen.count == (sco.pass_count + sco.fail_count));
    #100;
    $display("\n=================================");
    $display(" TEST COMPLETED | PASSED: %0d | FAILED: %0d", sco.pass_count, sco.fail_count);
    $display("=================================\n");
    $finish;
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass
