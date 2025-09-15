package sequencer_pkg;
    import sequence_item_pkg::*;

    class Sequencer;

        mailbox #(SequenceItem) seq_mbox;
        SequenceItem curr_item = null;
        bit item_applied = 1'b1;
        bit driver_wait = 1'b0;

        function new();
            this.seq_mbox = new();
        endfunction

        //try to implement UVM function

        //start_item(); called by Sequence      //blocking wait sequencer grant
        task automatic start_item(SequenceItem item);
            wait (seq_mbox.num()==0);      //blocking wait sequencer grant
            curr_item = item;
            // $display("Info: [SEQUENCER] start setting SequenceItem");
            item_applied = 1'b0;
        endtask

        //finish_item(); called by Sequence       //blocking wait item_done()  
        task automatic finish_item(SequenceItem item);
            if (!curr_item) $display("Error: [SEQUENCER] finish_item called without start_item");
            if (curr_item != item) $display("Error: [SEQUENCER] finish_item got differnt item from start_item");

            seq_mbox.put(item);
            // $display("Info: [SEQUENCER] SequenceItem finished set up and handed to Sequencer.");
            driver_wait = 1'b1;

            wait(item_applied==1'b1);       //blocking wait item_done()
            // $display("Info: [SEQUENCER] finished_item success; stimulus item appllied to DUT signals");
        endtask

        //get_next_item(); called by Driver //blocking wait finish_item()
        //NOT RECOMMAND use function cause: function:non-blocking; task:blocking; mailbox:blocking
        task automatic get_next_item(output SequenceItem item); 
            wait (driver_wait==1'b1);       //blocking wait finish_item()
            
            item_applied = 0;
            seq_mbox.get(item); 

            if (item != curr_item) $display("Error: [SEQUENCER] get_next_item got wrong item");
        endtask
        
        //item_done(); called by Driver (means item already applied to DUT signal)    //non-blocking
        task automatic item_done();
            if (item_applied || !curr_item) $display("Error: [SEQUENCER] item_done called with no active item.");
            item_applied = 1'b1;
            curr_item = null;
            // $display("Info: [SEQUENCER] stimulus item applied to DUT signals.");
            driver_wait = 1'b0;
        endtask

    endclass

endpackage
