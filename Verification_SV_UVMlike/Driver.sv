package driver_pkg;

    import sequence_item_pkg::*;
    import sequencer_pkg::*;

    class Driver;

        virtual DutEnvInterface vinf;
        Sequencer sequencer;

        function new(virtual DutEnvInterface vinf, Sequencer sequencer);
            this.vinf = vinf;
            this.sequencer = sequencer;
        endfunction

        task automatic run();
            forever begin
                SequenceItem seq_item;
                sequencer.get_next_item(seq_item);
                if (!seq_item) $display("[%0t][DRIVER] Error: received null item from sequencer", $time);
                // $display("[$t]Info: [DRIVER] sequence_item %s", seq_item.convert2string_input());


                @vinf.cb;
                vinf.cb.rstn <= seq_item.rstn;
                vinf.cb.wr_en <= seq_item.wr_en;
                vinf.cb.rd_en <= seq_item.rd_en;
                vinf.cb.in_data <= seq_item.in_data;

                sequencer.item_done();

                // $display("[%0t][Driver] Info: item stimulus applied to DUT signals, %s", $time, seq_item.convert2string_input());
            end
        endtask

    endclass

endpackage
