class scoreboard;
  mailbox #(transaction) mon_sco;
  mailbox #(transaction) gen_sco;
  transaction generated;
  transaction dut_output;
  
  event next_input;
  int count=0;
  
  function new(mailbox #(transaction) mon_sco,mailbox #(transaction) gen_sco);
    this.mon_sco=mon_sco;
    this.gen_sco=gen_sco;
  endfunction
  
  task run();
    forever begin
      gen_sco.get(generated);
      mon_sco.get(dut_output);
      $display("Input = %0d Output = %0d ",generated.din,dut_output.dout);
      if(generated.din==dut_output.dout)
        $display("Test Passed");
      else
        $display("Test Failed");
      count++;
      ->next_input;
    end
  endtask
endclass