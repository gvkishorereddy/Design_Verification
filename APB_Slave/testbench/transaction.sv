class transaction;

    rand bit [7:0]  paddr;
    rand bit [31:0] pwdata;
    rand bit        pwrite;

    logic [31:0] prdata;
    logic        pready;
    logic        pslverr;

    constraint addr_c {
      paddr inside {[0:15]};
    }

    constraint data_c {
        pwdata inside {[0:255]};
    }

    function void display(input string tag);
    $display("[%0s] paddr=%0d pwdata=%0d pwrite=%0b prdata=%0d pready=%0b pslverr=%0b time=%0t",
             tag, paddr, pwdata, pwrite,
             prdata, pready, pslverr, $time);
endfunction

endclass