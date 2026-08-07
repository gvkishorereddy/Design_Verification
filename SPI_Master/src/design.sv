module spi (
  input  logic         clk,
  input  logic         newd,
  input  logic         rst,
  input  logic [11:0]  din,
  output logic         sclk,
  output logic         cs,
  output logic         mosi
);

  typedef enum logic [1:0] {IDLE = 2'b00, SEND = 2'b10} state_type;
  state_type state;

  logic [11:0] temp;
  int countc;
  int count;

  // Generate SCLK from CLK
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      countc <= 0;
      sclk   <= 1'b0;
    end
    else begin
      if (countc < 9) begin
        countc <= countc + 1;
      end
      else begin
        countc <= 0;
        sclk   <= ~sclk;
      end
    end
  end

  // SPI transmit FSM
  always_ff @(posedge sclk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      cs    <= 1'b1;
      mosi  <= 1'b0;
      temp  <= '0;
      count <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          cs <= 1'b1;
          if (newd) begin
            temp  <= din;
            count <= 0;
            cs    <= 1'b0;
            state <= SEND;
          end
        end

        SEND: begin
          if (count <= 11) begin
            if (temp[count] === 1'bx)
              mosi <= 1'b0;
            else
              mosi <= temp[count];   // LSB first
            count <= count + 1;
          end
          else begin
            count <= 0;
            state <= IDLE;
            cs    <= 1'b1;
            mosi  <= 1'b0;
          end
        end

        default: begin
          state <= IDLE;
          cs    <= 1'b1;
          mosi  <= 1'b0;
          count <= 0;
        end
      endcase
    end
  end

endmodule