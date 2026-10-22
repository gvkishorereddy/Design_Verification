// Full-word-only AXI4-Lite subset: WSTRB is not implemented.
// Byte addresses 0..511, aligned to 4 bytes. Invalid accesses return DECERR.
`timescale 1ns/1ps
interface axi_lite_if;
  logic aclk, aresetn;
  logic [31:0] awaddr, wdata, araddr, rdata;
  logic awvalid, awready, wvalid, wready;
  logic bvalid, bready, arvalid, arready, rvalid, rready;
  logic [1:0] bresp, rresp;
endinterface

module axi_lite_slave (
  input logic aclk, aresetn,
  input logic [31:0] awaddr, input logic awvalid, output logic awready,
  input logic [31:0] wdata, input logic wvalid, output logic wready,
  output logic [1:0] bresp, output logic bvalid, input logic bready,
  input logic [31:0] araddr, input logic arvalid, output logic arready,
  output logic [31:0] rdata, output logic [1:0] rresp,
  output logic rvalid, input logic rready
);
  logic [31:0] mem [0:127];
  logic [31:0] awaddr_q, wdata_q;
  logic aw_pending, w_pending;
  integer i;
  assign awready = !aw_pending && !bvalid;
  assign wready = !w_pending && !bvalid;
  assign arready = !rvalid;
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      awaddr_q <= 0; wdata_q <= 0;
      aw_pending <= 0; w_pending <= 0;
      bresp <= 0; bvalid <= 0;
      rdata <= 0; rresp <= 0; rvalid <= 0;
      for (i = 0; i < 128; i++) mem[i] <= 0;
    end else begin
      if (awvalid && awready) begin
        awaddr_q <= awaddr; aw_pending <= 1;
      end
      if (wvalid && wready) begin
        wdata_q <= wdata; w_pending <= 1;
      end
      if (aw_pending && w_pending && !bvalid) begin
        if ((awaddr_q[1:0] == 0) && (awaddr_q < 512)) begin
          mem[awaddr_q[8:2]] <= wdata_q;
          bresp <= 2'b00;
        end else bresp <= 2'b11;
        bvalid <= 1;
        aw_pending <= 0; w_pending <= 0;
      end else if (bvalid && bready) bvalid <= 0;
      if (arvalid && arready) begin
        if ((araddr[1:0] == 0) && (araddr < 512)) begin
          rdata <= mem[araddr[8:2]]; rresp <= 2'b00;
        end else begin
          rdata <= 0; rresp <= 2'b11;
        end
        rvalid <= 1;
      end else if (rvalid && rready) rvalid <= 0;
    end
  end
endmodule
