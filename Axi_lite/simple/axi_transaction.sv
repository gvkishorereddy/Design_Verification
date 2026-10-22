class transaction;
  rand bit op; // 1 = write, 0 = read
  rand bit [31:0] awaddr;
  rand bit [31:0] wdata;
  rand bit [31:0] araddr;
  logic [31:0] rdata;
  logic [1:0] wresp, rresp;

  // Five word locations. This DUT uses BYTE addresses: four bytes per word.
  constraint valid_addr_range {
    awaddr inside {0, 4, 8, 12, 16};
    araddr inside {0, 4, 8, 12, 16};
  }
  constraint valid_data_range { wdata < 12; }
endclass
