class monitor;

    transaction tm;

    virtual apb_if vif;
    mailbox #(transaction) mon_sco;

    function new(
        mailbox #(transaction) mon_sco,
        virtual apb_if vif
    );
        this.mon_sco = mon_sco;
        this.vif     = vif;
    endfunction

    task run();
        forever begin
            @(posedge vif.PCLK);

            if (vif.PRESETn &&
                vif.PSEL &&
                vif.PENABLE &&
                vif.PREADY) begin

                tm = new();

                tm.paddr   = vif.PADDR;
                tm.pwrite  = vif.PWRITE;
                tm.pwdata  = vif.PWDATA;
                tm.prdata  = vif.PRDATA;
                tm.pready  = vif.PREADY;
                tm.pslverr = vif.PSLVERR;

                tm.display("MON");
                mon_sco.put(tm);
            end
        end
    endtask

endclass
