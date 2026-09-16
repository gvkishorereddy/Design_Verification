`timescale 1ns / 1ps

module mem_wb(
    input             clk,
    input             we,
    input             strb,
    input             rst,
    input      [7:0]  addr,
    input      [7:0]  wdata,
    output reg [7:0]  rdata,
    output reg        ack
);

    reg [7:0] mem [0:255];
    reg [7:0] temp;
    integer i;

    typedef enum bit [1:0] {idle = 0, check_mode = 1, write = 2, read = 3} state_type;
    state_type state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= idle;
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 8'h11;
        end else begin
            state <= next_state;
            if (state == write)
                mem[addr] <= wdata;
        end
    end

    always_comb begin
        ack        = 1'b0;
        rdata      = 8'h00;
        next_state = state;
        temp       = mem[addr];

        case (state)
            idle:       next_state = check_mode;
            check_mode: begin
                if (strb && we)
                    next_state = write;
                else if (strb && !we)
                    next_state = read;
            end
            write: begin
                ack        = 1'b1;
                next_state = idle;
            end
            read: begin
                rdata      = temp;
                ack        = 1'b1;
                next_state = idle;
            end
            default: next_state = idle;
        endcase
    end
endmodule
