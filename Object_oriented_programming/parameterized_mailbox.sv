class transaction;
 
bit [7:0] addr = 7'h12;
bit [3:0] data = 4'h4;
bit we = 1'b1;
bit rst = 1'b0;
 
endclass

class generator;
  
  transaction t_gen;
  mailbox #(transaction) mbx;
  
  task send_data();
    t_gen=new();
    mbx.put(t_gen);
    $display("[GEN] Data sent is addr = %0h , data = %0h, we = %0b, rst = %0b",t_gen.addr,t_gen.data,t_gen.we,t_gen.rst);
  endtask
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
endclass


class driver;
  
  transaction t_drv;
  mailbox #(transaction) mbx;
  
  task rcv_data();
    mbx.get(t_drv);
    $display("[DRV] Data Received is addr = %0h , data = %0h, we = %0b, rst = %0b",t_drv.addr,t_drv.data,t_drv.we,t_drv.rst);
  endtask
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
endclass

module tb;
  transaction save_data;
  mailbox #(transaction) mbx;
  generator gen;
  driver drv;
  
  initial begin
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);
    fork
      gen.send_data();
      drv.rcv_data();
    join
      
    
  end
  
endmodule
