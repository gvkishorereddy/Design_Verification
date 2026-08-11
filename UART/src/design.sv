`timescale 1ns / 1ps

module uart_top #(
    parameter int CLK_FREQ  = 1_000_000,
    parameter int BAUD_RATE = 9_600
)(
    input  logic       clk,
    input  logic       rst,

    // UART RX
    input  logic       rx,
    output logic [7:0] doutrx,
    output logic       donerx,

    // UART TX
    input  logic [7:0] dintx,
    input  logic       newd,
    output logic       tx,
    output logic       donetx
); 

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk   (clk),
        .rst   (rst),
        .newd  (newd),
        .data  (dintx),
        .tx    (tx),
        .done  (donetx)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk   (clk),
        .rst   (rst),
        .rx    (rx),
        .data  (doutrx),
        .done  (donerx)
    );

endmodule


// ============================================================
// UART TRANSMITTER
// Format: 1 start + 8 data + 1 stop
// Data is transmitted LSB first
// ============================================================
module uart_tx #(
    parameter int CLK_FREQ  = 1_000_000,
    parameter int BAUD_RATE = 9_600
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       newd,
    input  logic [7:0] data,
    output logic       tx,
    output logic       done
);

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_STOP
    } tx_state_t;

    tx_state_t state;

    logic [7:0] tx_data;
    logic [3:0] bit_count;
    int clk_count;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            state     <= TX_IDLE;
            tx_data   <= 8'h00;
            bit_count <= 0;
            clk_count <= 0;
            tx        <= 1'b1;
            done      <= 1'b0;
        end

        else begin

            done <= 1'b0;

            case(state)

                TX_IDLE: begin
                    tx        <= 1'b1;
                    clk_count <= 0;
                    bit_count <= 0;

                    if(newd) begin
                        tx_data   <= data;
                        tx        <= 1'b0;       // START bit
                        clk_count <= 0;
                        state     <= TX_START;
                    end
                end

                TX_START: begin
                    if(clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        bit_count <= 0;
                        tx        <= tx_data[0]; // Bit 0 (LSB)
                        state     <= TX_DATA;
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                TX_DATA: begin
                    if(clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                        if(bit_count == 7) begin
                            tx    <= 1'b1;       // STOP bit
                            state <= TX_STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                            tx        <= tx_data[bit_count + 1];
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                TX_STOP: begin
                    if(clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        tx        <= 1'b1;
                        done      <= 1'b1;
                        state     <= TX_IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default:
                    state <= TX_IDLE;

            endcase

        end

    end

endmodule


// ============================================================
// UART RECEIVER
// Format: 1 start + 8 data + 1 stop
// Data is received LSB first
// ============================================================

module uart_rx #(
    parameter int CLK_FREQ  = 1_000_000,
    parameter int BAUD_RATE = 9_600
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic [7:0] data,
    output logic       done
);

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_t;

    rx_state_t state;

    logic [7:0] rx_data;
    logic [3:0] bit_count;

    int clk_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= RX_IDLE;
            rx_data   <= 8'h00;
            data      <= 8'h00;
            bit_count <= 0;
            clk_count <= 0;
            done      <= 1'b0;
        end
        else begin
            done <= 1'b0;

            case (state)

                RX_IDLE: begin
                    clk_count <= 0;
                    bit_count <= 0;

                    if (rx == 1'b0) begin
                        state     <= RX_START;
                        clk_count <= 0;
                    end
                end

                RX_START: begin
                    if (clk_count == (CLKS_PER_BIT / 2) - 1) begin
                        clk_count <= 0;

                        if (rx == 1'b0) begin
                            state     <= RX_DATA;
                            bit_count <= 0;
                        end
                        else begin
                            state <= RX_IDLE;  // false start
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                RX_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                        rx_data <= {rx, rx_data[7:1]};

                        if (bit_count == 7) begin
                            state <= RX_STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                RX_STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                        if (rx == 1'b1) begin
                            data <= rx_data;
                            done <= 1'b1;
                        end

                        state <= RX_IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: begin
                    state <= RX_IDLE;
                end

            endcase
        end
    end

endmodule


