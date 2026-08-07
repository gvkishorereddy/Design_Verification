module spi_slave (
  input  logic        sclk,
  input  logic        rst,
  input  logic        cs,      // active low
  input  logic        mosi,
  output logic [11:0] dout,
  output logic        done
);

  logic [11:0] temp;
  int count;

  always_ff @(posedge sclk or posedge rst) begin
    if (rst) begin
      temp  <= '0;
      dout  <= '0;
      count <= 0;
      done  <= 1'b0;
    end
    else begin
      if (!cs) begin
        temp[count] <= mosi;

        if (count == 11) begin
          dout  <= {mosi, temp[10:0]};
          done  <= 1'b1;
          count <= 0;
        end
        else begin
          count <= count + 1;
          done  <= 1'b0;
        end
      end
      else begin
        count <= 0;
        done  <= 1'b0;
      end
    end
  end

endmodule