// Single-slave AHB-Lite RAM example: zero wait states, legal 32-bit accesses.
// Address/control belong to the address phase; HWDATA belongs to the next phase.
module ahb_slave (
  input logic clk, hresetn,
  input logic hsel, hwrite, hready,
  input logic [31:0] haddr, hwdata,
  input logic [1:0] htrans,
  input logic [2:0] hsize, hburst,
  output logic [31:0] hrdata,
  output logic hreadyout, hresp
);
  logic [31:0] mem [0:63]; // 256 bytes
  logic [31:0] addr_q;
  logic write_q, pending;

  assign hreadyout = 1'b1; // This example inserts no wait states.
  assign hresp = 1'b0;     // OKAY; only legal accesses are supported here.
  assign hrdata = pending && !write_q ? mem[addr_q[7:2]] : 32'd0;

  always_ff @(posedge clk) begin
    if (!hresetn) begin
      pending <= 0;
      addr_q <= 0;
      write_q <= 0;
      for (int i = 0; i < 64; i++) mem[i] <= 32'h0c0c0c0c;
    end else if (hready) begin
      // Complete the PREVIOUS address phase's write using current data.
      if (pending && write_q) mem[addr_q[7:2]] <= hwdata;

      // Accept the CURRENT address phase (NONSEQ=10 or SEQ=11).
      pending <= hsel && htrans[1];
      if (hsel && htrans[1]) begin
        addr_q <= haddr;
        write_q <= hwrite;
        // Simulation guard: this small example deliberately supports legal words only.
        assert (haddr < 256 && haddr[1:0] == 0 && hsize == 3'b010)
          else $fatal(1, "Unsupported access to simple AHB RAM");
      end
    end
  end
endmodule
