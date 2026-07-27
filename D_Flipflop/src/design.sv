interface dif;
  logic clk;
  logic rst;
  logic din;
  logic dout;
endinterface

module dff(dif dif);

  always_ff @(posedge dif.clk or posedge dif.rst) begin
    if (dif.rst)
      dif.dout <= '0;
    else
      dif.dout <= dif.din;
  end

endmodule