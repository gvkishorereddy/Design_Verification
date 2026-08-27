interface apb_if #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
);

    logic                    PCLK;
    logic                    PRESETn;
    logic [ADDR_WIDTH-1:0]   PADDR;
    logic                    PSEL;
    logic                    PENABLE;
    logic                    PWRITE;
    logic [DATA_WIDTH-1:0]   PWDATA;
    logic [DATA_WIDTH-1:0]   PRDATA;
    logic                    PREADY;
    logic                    PSLVERR;

endinterface