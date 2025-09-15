package monitor_pkg;
    import sequence_item_pkg::*;

    class Monitor;

        virtual DutEnvInterface vinf;
        mailbox #(SequenceItem) mbox_scoreboard;
        mailbox #(SequenceItem) mbox_coverage;

        function new(virtual DutEnvInterface vinf);
            this.vinf = vinf;
            this.mbox_scoreboard = new();
            this.mbox_coverage = new();
        endfunction

        //try to implement uvm_tlm_analysis_fifo.get() used by Scoreboard; Scoreboard access this mbox and use mbox.get()
        function mailbox #(SequenceItem) get_scoreboard_mbox();
            return mbox_scoreboard;
        endfunction

        function mailbox #(SequenceItem) get_coverage_mbox();
            return mbox_coverage;
        endfunction

        task automatic run(); 
            @(vinf.cb);
            forever begin
                SequenceItem seq_item;
                seq_item = new();

                seq_item.rstn = vinf.rstn;
                seq_item.wr_en = vinf.wr_en;
                seq_item.rd_en = vinf.rd_en;
                seq_item.in_data = vinf.in_data;

                @vinf.cb;
                seq_item.out_data = vinf.cb.out_data;
                seq_item.full = vinf.cb.full;
                seq_item.empty = vinf.cb.empty;
                seq_item.almostfull = vinf.cb.almostfull;
                seq_item.almostempty = vinf.cb.almostempty;
             

                mbox_scoreboard.put(seq_item);
                mbox_coverage.put(seq_item);
                // $display("[%0t][MONITOR] Info: put signals from DUT to Scoreboard: %s", $time, seq_item.convert2string_all());

            end
        endtask

    endclass

endpackage
