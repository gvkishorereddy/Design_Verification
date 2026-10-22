interface ahb_if;
  logic clk, hresetn;
  logic hsel, hwrite;
  logic [31:0] haddr, hwdata, hrdata;
  logic [1:0] htrans;
  logic [2:0] hsize, hburst;
  logic hready, hreadyout, hresp;
endinterface
