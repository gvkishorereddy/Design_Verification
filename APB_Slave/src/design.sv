module apb_slave_fsm #(
    parameter int ADDR_WIDTH  = 8,
    parameter int DATA_WIDTH  = 32,
    parameter int WAIT_CYCLES = 0
)(
    input  logic                  PCLK,
    input  logic                  PRESETn,

    input  logic [ADDR_WIDTH-1:0] PADDR,
    input  logic                  PSEL,
    input  logic                  PENABLE,
    input  logic                  PWRITE,
    input  logic [DATA_WIDTH-1:0] PWDATA,

    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic                  PREADY,
    output logic                  PSLVERR
);

    localparam int DEPTH = (1 << ADDR_WIDTH);

    typedef enum logic [1:0] {
        ST_IDLE   = 2'b00,
        ST_SETUP  = 2'b01,
        ST_ACCESS = 2'b10
    } apb_state_e;

    apb_state_e current_state, next_state;

    logic [DATA_WIDTH-1:0] reg_file [0:DEPTH-1];

    integer i;

    
    // State register
     
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            current_state <= ST_IDLE;
        else
            current_state <= next_state;
    end

    
    // Next-state logic
    
    always_comb begin
        next_state = current_state;

        case (current_state)
            ST_IDLE: begin
                if (PSEL && !PENABLE)
                    next_state = ST_SETUP;
            end

            ST_SETUP: begin
                if (!PSEL)
                    next_state = ST_IDLE;
                else if (PENABLE)
                    next_state = ST_ACCESS;
            end

            ST_ACCESS: begin
                if (PREADY) begin
                    if (PSEL && !PENABLE)
                        next_state = ST_SETUP;
                    else
                        next_state = ST_IDLE;
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

    
    // PREADY / wait-state logic
    generate
        if (WAIT_CYCLES == 0) begin : gen_no_wait

            always_comb begin
                PREADY = (current_state == ST_ACCESS);
            end

        end
        else begin : gen_wait_states

            localparam int CNT_WIDTH = $clog2(WAIT_CYCLES + 1);

            logic [CNT_WIDTH-1:0] wait_counter;

            always_ff @(posedge PCLK or negedge PRESETn) begin
                if (!PRESETn) begin
                    wait_counter <= '0;
                end
                else if (current_state != ST_ACCESS) begin
                    wait_counter <= '0;
                end
                else if (!PREADY) begin
                    wait_counter <= wait_counter + 1'b1;
                end
            end

            always_comb begin
                PREADY = (current_state == ST_ACCESS) &&
                         (wait_counter == WAIT_CYCLES);
            end

        end
    endgenerate

    
    // Memory reset and APB write
    
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < DEPTH; i = i + 1)
                reg_file[i] <= '0;
        end
        else if (current_state == ST_ACCESS && PREADY && PWRITE) begin
            reg_file[PADDR] <= PWDATA;
        end
    end

    
    // APB read data
    // Combinational so PRDATA is stable before the edge where
    // PREADY completes the read transfer.
    
    always_comb begin
        if (PSEL && !PWRITE)
            PRDATA = reg_file[PADDR];
        else
            PRDATA = '0;
    end

    
    // This slave does not generate errors
    assign PSLVERR = 1'b0;

endmodule