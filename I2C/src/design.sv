`timescale 1ns / 1ps

module i2c_top #(
    parameter SYS_FREQ   = 40_000_000,
    parameter I2C_FREQ   = 100_000,
    parameter SLAVE_ADDR = 7'h50
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       newd,
    input  wire [6:0] addr,
    input  wire       op,
    input  wire [7:0] din,
    output wire [7:0] dout,
    output wire       busy,
    output wire       ack_err,
    output wire       done
);

    wire sda;
    wire scl;

    wire [7:0] slave_dout;
    wire [7:0] slave_din = din;
    wire       slave_busy;
    wire       slave_done;

    // Bus pull-ups for open-drain operation
    pullup (sda);
    pullup (scl);

    i2c_master #(
        .SYS_FREQ(SYS_FREQ),
        .I2C_FREQ(I2C_FREQ)
    ) master_inst (
        .clk(clk),
        .rst(rst),
        .newd(newd),
        .addr(addr),
        .op(op),
        .din(din),
        .dout(dout),
        .busy(busy),
        .ack_err(ack_err),
        .done(done),
        .sda(sda),
        .scl(scl)
    );

    i2c_slave #(
        .SLAVE_ADDR(SLAVE_ADDR)
    ) slave_inst (
        .clk(clk),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .dout(slave_dout),
        .din(slave_din),
        .busy(slave_busy),
        .done(slave_done)
    );

endmodule


module i2c_master #(
    parameter SYS_FREQ = 40_000_000,
    parameter I2C_FREQ = 100_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       newd,     // Start transaction pulse
    input  wire [6:0] addr,
    input  wire       op,       // 0: write, 1: read
    input  wire [7:0] din,
    output reg  [7:0] dout,
    output reg        busy,
    output reg        ack_err,
    output reg        done,
    inout  wire       sda,
    inout  wire       scl
);

    localparam CLK_DIV = SYS_FREQ / (I2C_FREQ * 4); // 4x clock tick

    typedef enum logic [3:0] {
        IDLE, START, ADDR, ACK1, WRITE, READ, MASTER_ACK, ACK2, STOP
    } state_t;

    state_t state;

    reg [15:0] count;
    reg [1:0]  quarter_clk;
    reg [2:0]  bit_cnt;
    reg [7:0]  shift_reg;
    reg        sda_out;
    reg        scl_out;
    reg        sda_en;
    reg        scl_en;

    // Open-drain driver logic
    assign sda = (sda_en && !sda_out) ? 1'b0 : 1'bz;
    assign scl = (scl_en && !scl_out) ? 1'b0 : 1'bz;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            quarter_clk <= 0;
        end else if (busy) begin
            if (count == CLK_DIV - 1) begin
                count <= 0;
                quarter_clk <= quarter_clk + 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end else begin
            count <= 0;
            quarter_clk <= 0;
        end
    end

    // Master FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            busy      <= 1'b0;
            done      <= 1'b0;
            ack_err   <= 1'b0;
            sda_en    <= 1'b1;
            scl_en    <= 1'b1;
            sda_out   <= 1'b1;
            scl_out   <= 1'b1;
            bit_cnt   <= 3'd7;
            shift_reg <= 8'h00;
            dout      <= 8'h00;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    scl_out <= 1'b1;
                    sda_out <= 1'b1;
                    sda_en  <= 1'b1;
                    scl_en  <= 1'b1;
                    ack_err <= 1'b0;
                    if (newd) begin
                        busy      <= 1'b1;
                        shift_reg <= {addr, op};
                        state     <= START;
                    end else begin
                        busy      <= 1'b0;
                    end
                end

                START: begin
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b1; sda_out <= 1'b1; end
                        2'b01: begin scl_out <= 1'b1; sda_out <= 1'b0; end // SDA falls while SCL high
                        2'b10: begin scl_out <= 1'b1; sda_out <= 1'b0; end 
                        2'b11: begin 
                            scl_out <= 1'b0; 
                            if (count == CLK_DIV - 1) begin
                                state   <= ADDR;
                                bit_cnt <= 3'd7;
                            end
                        end
                    endcase
                end

                ADDR: begin
                    sda_en <= 1'b1;
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; sda_out <= shift_reg[bit_cnt]; end
                        2'b01: begin scl_out <= 1'b1; end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                if (bit_cnt == 0) begin
                                    state  <= ACK1;
                                    sda_en <= 1'b0; // Release SDA for slave ACK
                                end else begin
                                    bit_cnt <= bit_cnt - 1'b1;
                                end
                            end
                        end
                    endcase
                end

                ACK1: begin
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; end
                        2'b01: begin 
                            scl_out <= 1'b1;
                            if (sda == 1'b1) ack_err <= 1'b1; // NACK received
                        end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                if (ack_err) begin
                                    state   <= STOP;
                                    sda_en  <= 1'b1;
                                    sda_out <= 1'b0;
                                end else if (shift_reg[0] == 1'b0) begin // Write
                                    state     <= WRITE;
                                    shift_reg <= din;
                                    bit_cnt   <= 3'd7;
                                    sda_en    <= 1'b1;
                                end else begin // Read
                                    state   <= READ;
                                    bit_cnt <= 3'd7;
                                    sda_en  <= 1'b0;
                                end
                            end
                        end
                    endcase
                end

                WRITE: begin
                    sda_en <= 1'b1;
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; sda_out <= shift_reg[bit_cnt]; end
                        2'b01: begin scl_out <= 1'b1; end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                if (bit_cnt == 0) begin
                                    state  <= ACK2;
                                    sda_en <= 1'b0;
                                end else begin
                                    bit_cnt <= bit_cnt - 1'b1;
                                end
                            end
                        end
                    endcase
                end

                READ: begin
                    sda_en <= 1'b0; // Release line to read data
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; end
                        2'b01: begin 
                            scl_out <= 1'b1; 
                            if (count == (CLK_DIV/2)) dout[bit_cnt] <= sda; // Sample SDA at mid-SCL high
                        end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                if (bit_cnt == 0) begin
                                    state   <= MASTER_ACK;
                                    sda_en  <= 1'b1;
                                    sda_out <= 1'b1; // Drive high for NACK
                                end else begin
                                    bit_cnt <= bit_cnt - 1'b1;
                                end
                            end
                        end
                    endcase
                end

                MASTER_ACK: begin
                    sda_en <= 1'b1;
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; sda_out <= 1'b1; end // Drive NACK (SDA high)
                        2'b01: begin scl_out <= 1'b1; end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                state   <= STOP;
                                sda_out <= 1'b0; // Prepare for STOP condition
                            end
                        end
                    endcase
                end

                ACK2: begin
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; end
                        2'b01: begin 
                            scl_out <= 1'b1;
                            if (sda == 1'b1) ack_err <= 1'b1;
                        end
                        2'b10: begin scl_out <= 1'b1; end
                        2'b11: begin 
                            scl_out <= 1'b0;
                            if (count == CLK_DIV - 1) begin
                                state   <= STOP;
                                sda_en  <= 1'b1;
                                sda_out <= 1'b0;
                            end
                        end
                    endcase
                end

                STOP: begin
                    sda_en <= 1'b1;
                    case (quarter_clk)
                        2'b00: begin scl_out <= 1'b0; sda_out <= 1'b0; end
                        2'b01: begin scl_out <= 1'b1; sda_out <= 1'b0; end
                        2'b10: begin scl_out <= 1'b1; sda_out <= 1'b1; end // SDA rises while SCL high
                        2'b11: begin 
                            scl_out <= 1'b1; sda_out <= 1'b1;
                            if (count == CLK_DIV - 1) begin
                                state <= IDLE;
                                busy  <= 1'b0;
                                done  <= 1'b1;
                            end
                        end
                    endcase
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule


module i2c_slave #(
    parameter [6:0] SLAVE_ADDR = 7'h50
)(
    input  wire       clk,
    input  wire       rst,
    inout  wire       sda,
    input  wire       scl,
    output reg  [7:0] dout,
    input  wire [7:0] din,
    output reg        busy,
    output reg        done
);

    typedef enum logic [3:0] {
        IDLE, READ_ADDR, SEND_ACK1, WRITE_DATA, READ_DATA, SEND_ACK2, MASTER_ACK
    } state_t;

    state_t state;

    reg [2:0] scl_sync;
    reg [2:0] sda_sync;
    reg [7:0] memory [0:127]; // Internal memory storage for slave

    // Synchronizer + edge detection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scl_sync <= 3'b111;
            sda_sync <= 3'b111;
        end else begin
            scl_sync <= {scl_sync[1:0], scl};
            sda_sync <= {sda_sync[1:0], sda};
        end
    end

    wire scl_rising  = (scl_sync[2:1] == 2'b01);
    wire scl_falling = (scl_sync[2:1] == 2'b00);
    wire scl_falling_edge = (scl_sync[2:1] == 2'b10);
    wire start_cond  = (sda_sync[2:1] == 2'b10) && scl_sync[1];
    wire stop_cond   = (sda_sync[2:1] == 2'b01) && scl_sync[1];

    reg [2:0] bit_cnt;
    reg [7:0] rx_shift;
    reg [7:0] tx_shift;
    reg       sda_out;
    reg       sda_en;
    reg       last_bit_sent;  // marks that the final READ_DATA bit has been clocked out,
                               // and the following falling edge should release the bus

    assign sda = (sda_en && !sda_out) ? 1'b0 : 1'bz;

    // Slave FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            sda_en        <= 1'b0;
            sda_out       <= 1'b1;
            bit_cnt       <= 3'd7;
            busy          <= 1'b0;
            done          <= 1'b0;
            dout          <= 8'h00;
            last_bit_sent <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start_cond) begin
                state   <= READ_ADDR;
                bit_cnt <= 3'd7;
                sda_en  <= 1'b0;
                busy    <= 1'b1;
            end else if (stop_cond) begin
                state   <= IDLE;
                sda_en  <= 1'b0;
                busy    <= 1'b0;
                done    <= 1'b1;
            end else begin

                case (state)
                    IDLE: begin
                        sda_en <= 1'b0;
                        busy   <= 1'b0;
                    end

                    READ_ADDR: begin
                        if (scl_rising) begin
                            rx_shift[bit_cnt] <= sda_sync[1];
                            if (bit_cnt == 0) begin
                                if (rx_shift[7:1] == SLAVE_ADDR) begin
                                    state <= SEND_ACK1;
                                end else begin
                                    state <= IDLE;
                                end
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end

                    // Two-phase ACK: first falling edge starts driving the ACK bit;
                    // the falling edge that follows (once the bit has actually been
                    // held for the whole SCL-high period) ends it and advances state.
                    SEND_ACK1: begin
                        if (scl_falling_edge) begin
                            if (sda_en) begin
                                sda_en <= 1'b0;
                                if (rx_shift[0] == 1'b0) begin
                                    state   <= WRITE_DATA;
                                    bit_cnt <= 3'd7;
                                end else begin
                                    state    <= READ_DATA;
                                    tx_shift <= memory[SLAVE_ADDR];
                                    bit_cnt  <= 3'd7;
                                end
                            end else begin
                                sda_en  <= 1'b1;
                                sda_out <= 1'b0; // ACK
                            end
                        end
                    end

                    WRITE_DATA: begin
                        if (scl_falling_edge) begin
                            sda_en <= 1'b0;
                        end else if (scl_rising) begin
                            rx_shift[bit_cnt] <= sda_sync[1];
                            if (bit_cnt == 0) begin
                                dout <= {rx_shift[7:1], sda_sync[1]};
                                memory[SLAVE_ADDR] <= {rx_shift[7:1], sda_sync[1]}; // Save data
                                state <= SEND_ACK2;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end

                    // Two-phase exit: keep driving tx_shift[bit_cnt] for the full
                    // final bit period; only release/advance on the *next* falling
                    // edge after the last bit's rising edge has been seen.
                    READ_DATA: begin
                        if (scl_falling_edge) begin
                            if (last_bit_sent) begin
                                state         <= MASTER_ACK;
                                sda_en        <= 1'b0;
                                last_bit_sent <= 1'b0;
                            end else begin
                                sda_en  <= 1'b1;
                                sda_out <= tx_shift[bit_cnt];
                            end
                        end else if (scl_rising) begin
                            if (bit_cnt == 0) begin
                                last_bit_sent <= 1'b1;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end

                    // Same two-phase treatment as SEND_ACK1.
                    SEND_ACK2: begin
                        if (scl_falling_edge) begin
                            if (sda_en) begin
                                state  <= IDLE;
                                sda_en <= 1'b0;
                            end else begin
                                sda_en  <= 1'b1;
                                sda_out <= 1'b0;
                            end
                        end
                    end

                    MASTER_ACK: begin
                        if (scl_rising) begin
                            if (sda_sync[1] == 1'b1) begin // NACK received -> End
                                state  <= IDLE;
                                sda_en <= 1'b0;
                            end else begin
                                state    <= READ_DATA;
                                tx_shift <= memory[SLAVE_ADDR];
                                bit_cnt  <= 3'd7;
                            end
                        end
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule