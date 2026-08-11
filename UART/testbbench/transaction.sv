typedef enum bit {
    WRITE = 1'b0,   // Test UART transmitter
    READ  = 1'b1    // Test UART receiver
} oper_type;


// ============================================================
// TRANSACTION
// ============================================================

class transaction;

    rand oper_type oper;
    rand bit [7:0] dintx;

         bit [7:0] doutrx;


    function transaction copy();

        copy = new();

        copy.oper   = this.oper;
        copy.dintx  = this.dintx;
        copy.doutrx = this.doutrx;

        return copy;

    endfunction

endclass
