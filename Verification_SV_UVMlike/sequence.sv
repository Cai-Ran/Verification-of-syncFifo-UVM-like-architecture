package sequence_pkg;
    import sequence_item_pkg::*;
    import sequencer_pkg::*;

    class InitialResetSequence;
        SequenceItem seq_item;

        function new();
            this.seq_item = new();
        endfunction

        task run(Sequencer sequencer);
            sequencer.start_item(seq_item);

            assert(seq_item.imp_randomize());
            seq_item.rstn = 1'b0;

            $display("Info: [SEQUENCE] initial_reset: %s", seq_item.convert2string_input());

            sequencer.finish_item(seq_item);
        endtask
    endclass


    class WriteOnlySequence;
        SequenceItem seq_item;

        function new();
            this.seq_item = new();
        endfunction

        task run(Sequencer sequencer);
            sequencer.start_item(seq_item);

            assert(seq_item.imp_randomize());
            seq_item.constraint_write_only();

            $display("Info: [SEQUENCE] write_only: %s", seq_item.convert2string_input());

            sequencer.finish_item(seq_item);
        endtask
    endclass


    class ReadOnlySequence;
        SequenceItem seq_item;

        function new();
            this.seq_item = new();
        endfunction

        task run(Sequencer sequencer);
            sequencer.start_item(seq_item);

            assert(seq_item.imp_randomize());
            seq_item.constraint_read_only();
            
            $display("Info: [SEQUENCE] read_only: %s", seq_item.convert2string_input());

            sequencer.finish_item(seq_item);
        endtask
    endclass


    class MixWriteReset;
        SequenceItem seq_item;

        function new(int reset_dist, int write_dist);
            this.seq_item = new(reset_dist, write_dist);
        endfunction

        task run(Sequencer sequencer);
            sequencer.start_item(seq_item);

            assert(seq_item.imp_randomize());
            seq_item.constraint_dist_wr_en();
            seq_item.constraint_dist_rstn();
            seq_item.rd_en=1'b0;
            
            $display("Info: [SEQUENCE] mix_write_reset: %s", seq_item.convert2string_input());

            sequencer.finish_item(seq_item);
        endtask
    endclass

    class MixWriteRead;
        SequenceItem seq_item;

        function new(int reset_dist, int write_dist, int read_dist);
            this.seq_item = new(reset_dist, write_dist, read_dist);
        endfunction

        task run(Sequencer sequencer);
            sequencer.start_item(seq_item);

            assert(seq_item.imp_randomize());
            seq_item.constraint_dist_wr_en();
            seq_item.constraint_dist_rd_en();
            seq_item.constraint_no_reset();
            
            $display("Info: [SEQUENCE] mix_write_read: %s", seq_item.convert2string_input());

            sequencer.finish_item(seq_item);
        endtask
    endclass

endpackage
