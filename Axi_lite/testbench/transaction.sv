class transaction;
  randc bit        op;
  rand bit [31:0] awaddr;
  rand bit [31:0] wdata;
  rand bit [31:0] araddr;
       bit [31:0] rdata;
       bit [1:0]  wresp;
       bit [1:0]  rresp;
  
  constraint valid_addr_range {awaddr < 5; araddr < 5;}
  constraint valid_data_range {wdata < 12; rdata < 12;}
endclass