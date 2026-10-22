class transaction;
  rand bit hwrite;
  rand bit [31:0] haddr, hwdata;
  rand bit [2:0] hsize, hburst;
  logic [31:0] hrdata;
  logic hresp;

  constraint addr_c { haddr inside {0, 4, 8, 12, 16}; }
  constraint data_c { hwdata inside {[1:50]}; }
  constraint size_c { hsize == 3'b010; }  // Four bytes per transfer.
  constraint burst_c { hburst == 3'b000; } // SINGLE, to keep this example simple.
endclass
