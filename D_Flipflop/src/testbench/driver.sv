class driver;
  transaction td; //only driver object
  virtual dif dif;
  mailbox #(transaction) mbx_gd;
  
  function new(mailbox #(transaction) mbx_gd);
    this.mbx_gd=mbx_gd;
  endfunction
  
  task run();
    forever begin
    mbx_gd.get(td);
    dif.din <= td.din;
    @(posedge dif.clk);
      td.display("DRV");
      dif.din <= '0;
      @(posedge dif.clk);
    end
  endtask
  
  task reset();
    dif.rst <= '1;
    repeat(2) @(posedge dif.clk);
    dif.rst <= 1'b0;
    $display("Reset Done");
  endtask
endclass