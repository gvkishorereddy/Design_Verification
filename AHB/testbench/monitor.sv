class monitor;
    
  virtual ahb_if vif; 
  transaction tr;
 
  int len = 0;
  bit [4:0] temp;
  
  mailbox #(transaction) mbxms;
  mailbox #(bit[4:0]) mbxgm;
 
  function new( mailbox #(transaction) mbxms, mailbox #(bit[4:0]) mbxgm);
    this.mbxms = mbxms;
    this.mbxgm = mbxgm;
  endfunction
  
  ///////////////////////////////////Single transfer
  ////////////////////////////////Write Operation
  task single_tr_wr();
  @(posedge vif.hready);
  @(posedge vif.clk);
  tr.haddr  = vif.haddr;
  tr.hwdata = vif.hwdata;
  tr.hwrite = 1; 
  mbxms.put(tr);
  $display("[MON]: SINGLE TRANSFER WRITE addr : %0d data : %0d", tr.haddr, tr.hwdata);
  @(posedge vif.clk);
  endtask
  
  ///////////////////////////////Read Operation
  task single_tr_rd();
  @(posedge vif.hready);
  @(posedge vif.clk);
  tr.haddr  = vif.haddr;
  tr.hwrite = 0; 
  tr.hrdata = vif.hrdata;
  mbxms.put(tr);
 $display("[MON]: SINGLE TRANSFER READ addr : %0d data : %0d", tr.haddr, tr.hrdata);
 @(posedge vif.clk);
  endtask
  
 //////////////////////////////////////////////////////////////////////////// 
 ///////////////////////unspec len write
  task unspec_tr_wr();
    mbxgm.get(temp);
    repeat(temp) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: UNSPECWR addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 ///////////////////////////////////////////////////////////////////////////////
 //////////////////////////unspec len read
    task unspec_tr_rd();
    mbxgm.get(temp);
    repeat(temp) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: UNSPECRD addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 /////////////////////////////////////////////////////////////////////////////////////
 ////////////////////////////////INCR 4 WRITE
   task incr4_wr();
   $display("[MON] : INCR4 DATA WRITE");
    repeat(4) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 //////////////////////////////////////////////////////////////////////////////////////
 ///////////////////////////////INCR 4 READ
 
    task incr4_rd();
    $display("[MON] : INCR4 DATA READ");
    repeat(4) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////
 ////////////////////////////wrap 4 write
 task wrap4_wr();
   $display("[MON] : WRAP4 DATA WRITE");
    repeat(4) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////////////////////
 ////////////////////wrap 4 read
   task wrap4_rd();
    $display("[MON] : WRAP4 DATA READ");
    repeat(4) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 ///////////////////////////////////////////////////////////////
 
 ////////////////////////////////INCR 8 WRITE
   task incr8_wr();
   $display("[MON] : INCR8 DATA WRITE");
    repeat(8) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 //////////////////////////////////////////////////////////////////////////////////////
 ///////////////////////////////INCR 8 READ
 
    task incr8_rd();
    $display("[MON] : INCR8 DATA READ");
    repeat(8) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////
 ////////////////////////////wrap 8 write
 task wrap8_wr();
   $display("[MON] : WRAP8 DATA WRITE");
    repeat(8) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////////////////////
 ////////////////////wrap 8 read
   task wrap8_rd();
    $display("[MON] : WRAP8 DATA READ");
    repeat(8) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 ///////////////////////////////////////////////////////////////
 //////////////////////////////////////////////////////////////
 
 ////////////////////////////////INCR 16 WRITE
   task incr16_wr();
   $display("[MON] : INCR16 DATA WRITE");
    repeat(16) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 //////////////////////////////////////////////////////////////////////////////////////
 ///////////////////////////////INCR 4 READ
 
    task incr16_rd();
    $display("[MON] : INCR16 DATA READ");
    repeat(16) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////
 ////////////////////////////wrap 16 write
 task wrap16_wr();
   $display("[MON] : WRAP16 DATA WRITE");
    repeat(16) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwdata = vif.hwdata;
    tr.hwrite = 1; 
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hwdata);
    @(posedge vif.clk);
    end
 endtask
 
 /////////////////////////////////////////////////////////////////////
 ////////////////////wrap 16 read
   task wrap16_rd();
    $display("[MON] : WRAP4 DATA READ");
    repeat(16) begin
    @(posedge vif.hready);
    @(posedge vif.clk); 
    tr.haddr  = vif.next_addr;
    tr.hwrite = 0; 
    tr.hrdata = vif.hrdata;
    mbxms.put(tr);
    $display("[MON]: addr : %0d data : %0d", tr.haddr, tr.hrdata);
    @(posedge vif.clk);
    end
 endtask
 ///////////////////////////////////////////////////////////////
 
 
 
  ////////////////////////////////////////////////////////////////////////////
  task run();  
    tr = new();
    forever begin  
        @(posedge vif.clk);
        
        if(vif.hresetn && vif.hsel && vif.hwrite)
          begin  
          case(vif.hburst)
          3'b000: single_tr_wr();   
          3'b001: unspec_tr_wr();
          3'b010: wrap4_wr();
          3'b011: incr4_wr();
          3'b100: wrap8_wr();
          3'b101: incr8_wr();
          3'b110: wrap16_wr();
          3'b111: incr16_wr();
          endcase
          end
   
      
       if(vif.hresetn && vif.hsel && (vif.hwrite == 0))
          begin  
          case(vif.hburst)
          3'b000: single_tr_rd();   
          3'b001: unspec_tr_rd();
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
