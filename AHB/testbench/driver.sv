class driver;
  
  virtual ahb_if vif;
  
  transaction tr;
  
  event drvnext;
  
  mailbox #(transaction) mbxgd;
 
  
  function new( mailbox #(transaction) mbxgd );
    this.mbxgd = mbxgd; 
  endfunction
  
  task reset();
    vif.hresetn <= 1'b0;
    vif.hwdata  <= 0;
    vif.haddr   <= 0; 
    vif.hsize   <= 0;
    vif.hwrite  <= 0;
    vif.hsel    <= 0;
    vif.htrans  <= 0;
    repeat(10) @(posedge vif.clk);
    vif.hresetn <= 1'b1;
    $display("[DRV] : RESET DONE");
  endtask
  
  /////////////////////////////single transfer write
  
  task single_tr_wr();
    
   @(posedge vif.clk);
    
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b000;
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   
   @(posedge vif.hready);
   @(posedge vif.clk);
   ->drvnext; 
   $display("[DRV] : SINGLE TRANSFER WRITE ADDR : %0d DATA : %0d", tr.haddr, vif.hwdata); 
  
  
  endtask
  
  ///////////////////////////////Single transfer read
 task single_tr_rd();
    
   @(posedge vif.clk);
    
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b000;
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   
   @(posedge vif.hready);
   @(posedge vif.clk);
   ->drvnext; 
   $display("[DRV] : SINGLE READ TRANSFER ADDR : %0d DATA : %0d", tr.haddr, vif.hwdata); 
   
  endtask
  
  
  ///////////////////////// unspec length
  
  task unspec_len_wr();
    @(posedge vif.clk);
   
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b001;
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00; ///non seq
    
   
  
   @(posedge vif.hready);
   @(posedge vif.clk); 
    $display("[DRV] : UNSPEC LEN TRANSFER DATA : %0d ADDR : %0d", vif.hwdata, vif.haddr);
    
    repeat(tr.ulen - 1) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01;    ///seq
    @(posedge vif.hready);
    @(posedge vif.clk); 
    $display("[DRV] : UNSPEC LEN TRANSFER  ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);  
    end
 
   ->drvnext;
  endtask
  
  ////////////////////////////////////////////unspec len read
    task unspec_len_rd();
    @(posedge vif.clk);
   
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b001;
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00; ///non seq
    
   
  
   @(posedge vif.hready);
   @(posedge vif.clk); 
    $display("[DRV] : UNSPEC LEN TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
   
    repeat(tr.ulen - 1) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01;    ///seq
    
    @(posedge vif.hready);
    @(posedge vif.clk);
    $display("[DRV] : UNSPEC LEN TRANSFER  ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
    end
 
   ->drvnext;
  endtask
  
  
  
  ////////////////////////////////////////////////////////////
  ////////////////////////Increment 4 beats
  
  task incr4_wr ();
   $display("[DRV] : INCR4 WRITE");
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b011; 
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   //$display("[DRV] : INCR4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
   @(posedge vif.hready);
   @(posedge vif.clk);
   
    repeat(3) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01;
   // $display("[DRV] : INCR4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
    @(posedge vif.hready);
    @(posedge vif.clk); 
    end
    
   ->drvnext;
  endtask
  
  ///////////////////////////////////////////////////////////////
  ///////////////////////////INCR4 read
    task incr4_rd ();
   $display("[DRV] : INCR4 READ");
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b011; 
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
  // $display("[DRV] : INCR4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
   @(posedge vif.hready);
   @(posedge vif.clk);
   
    repeat(3) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01;
   // $display("[DRV] : INCR4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
    @(posedge vif.hready);
    @(posedge vif.clk); 
    end
   ->drvnext;
  endtask
  
  
  /////////////////////////Increment 8 beats
  
    task incr8_wr();
    @(posedge vif.clk);  
      
   vif.hresetn <= 1'b1;
      
   vif.hburst <= 3'b101;
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
        
   @(posedge vif.hready);
   @(posedge vif.clk);
    $display("[DRV] : INCR8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
 
   
    repeat(7) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01; 
    $display("[DRV] : INCR8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
    @(posedge vif.hready);
    @(posedge vif.clk); 
    end
  ->drvnext;
  endtask
  
  ///////////////////////////////////////////////////////////////////
  /////////////////////////////////INCR8 read
   task incr8_rd ();
    @(posedge vif.clk);  
      
   vif.hresetn <= 1'b1;
      
   vif.hburst <= 3'b101;
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   $display("[DRV] : INCR8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
      
   @(posedge vif.hready);
   @(posedge vif.clk);
   
    repeat(7) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01; 
     @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : INCR8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
  
    end
  ->drvnext;
  endtask
  
 
  //////////////////////////////////////////////////
  ////////////////////////////////Increment 16 beats
  
   task incr16_wr();
    
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b111;
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
      $display("[DRV] : INCR16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
    repeat(15) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01; 
      @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : INCR16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
 
    end
  ->drvnext;
  endtask
  
  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////INCR 16 RD
  task incr16_rd();
    
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b111;
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
      $display("[DRV] : INCR16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
   
     repeat(15) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01; 
    @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : INCR16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
   
    end
  ->drvnext;
  endtask
  
  
  /////////////////////////////////////////////////
  //////////////////////////////////Wrap 4 beats
  
  task wrap4_wr();
   @(posedge vif.clk); 
    
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b010;
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   
    @(posedge vif.hready);
   @(posedge vif.clk);
    $display("[DRV] : WRAP4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr); 
  
    repeat(3) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01;
      @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : WRAP4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
 
    end
   ->drvnext;  
  endtask
  
  ///////////////////////////////////////////////////////////////////
  ///////////////////////////////////wrap4_rd
  
    task wrap4_rd();
   @(posedge vif.clk); 
    
   vif.hresetn <= 1'b1;
    
   vif.hburst <= 3'b010;
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
    @(posedge vif.hready);
   @(posedge vif.clk);
     $display("[DRV] : WRAP4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr); 
 
   
    repeat(3) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01;
     @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : WRAP4 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
    end
   ->drvnext;  
  endtask
 
  
  ///////////////////////////////////Wrap 8 beats write
  
   task wrap8_wr();
     @(posedge vif.clk);  
     
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b100;  
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
    @(posedge vif.hready);
   @(posedge vif.clk);
     $display("[DRV] : WRAP8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
    repeat(7) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01;
     @(posedge vif.hready);
    @(posedge vif.clk); 
       $display("[DRV] : WRAP8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);  
  
    end
  ->drvnext;
  endtask
  
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////wrap 8 read
     task wrap8_rd();
     @(posedge vif.clk);  
     
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b100;  
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
      $display("[DRV] : WRAP8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
    repeat(7) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01;
      @(posedge vif.hready);
    @(posedge vif.clk); 
      $display("[DRV] : WRAP8 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);  
  
    end
  ->drvnext;
  endtask
  
  ///////////////////////////////////////wrap 16 beats write
  
   task wrap16_wr();
     @(posedge vif.clk);
     
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b110;     
   
   vif.hwrite <= 1'b1;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= $urandom_range(1,50);
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
    @(posedge vif.hready);
   @(posedge vif.clk);
     $display("[DRV] : WRAP16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
  
     repeat(15) begin
    vif.hwdata <= $urandom_range(1,50);  
    vif.htrans  <= 2'b01;  
    @(posedge vif.hready);
    @(posedge vif.clk); 
      $display("[DRV] : WRAP16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
  
    end
  ->drvnext;
  endtask
  
  ///////////////////////////////////////////////////////
  //////////////////////////wrap 16 read
  
     task wrap16_rd();
     
     @(posedge vif.clk);
     
   vif.hresetn <= 1'b1;
     
   vif.hburst <= 3'b110;     
   
   vif.hwrite <= 1'b0;
   vif.hsel   <= 1'b1;
    
   vif.hwdata <= 0;
   vif.haddr  <= tr.haddr;
   vif.hsize  <= 3'b010; //////write 4 byte 
   
   vif.htrans <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
     $display("[DRV] : WRAP16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);
   
    repeat(15) begin
    vif.hwdata <= 0;  
    vif.htrans  <= 2'b01;  
    @(posedge vif.hready);
    @(posedge vif.clk); 
     $display("[DRV] : WRAP16 TRANSFER ADDR : %0d DATA : %0d", vif.hwdata, vif.haddr);   
   
    end
  ->drvnext;
  endtask
  
/////////////////////////////////////////////////////////////////////
 
 
  task run();
    forever begin
    mbxgd.get(tr);
    
    if(tr.hwrite == 1'b1) begin
    case(tr.hburst)
      3'b000: single_tr_wr();
      3'b001: unspec_len_wr();
      3'b010: wrap4_wr();
      3'b011: incr4_wr();
      3'b100: wrap8_wr();
      3'b101: incr8_wr();
      3'b110: wrap16_wr();
      3'b111: incr16_wr();
    endcase   
    end
   else begin
      case(tr.hburst)
      3'b000: single_tr_rd();
      3'b001: unspec_len_rd();
      3'b010: wrap4_rd();
      3'b011: incr4_rd();
      3'b100: wrap8_rd();
      3'b101: incr8_rd();
      3'b110: wrap16_rd();
      3'b111: incr16_rd();
    endcase 
   end 
      
  end  
  endtask
  
  
endclass
