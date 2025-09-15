`include "MACRO.svh"
package scoreboard_pkg;
    import sequence_item_pkg::*;


    class Scoreboard;

        mailbox #(SequenceItem) mbox_export;
        //for reference model
        bit [`DWIDTH-1:0] ref_fifo [$];                 
        logic [`DWIDTH-1:0] ref_out_data = 'x;          
        logic ref_full, ref_empty;
        logic ref_almostfull, ref_almostempty;
        int unsigned fifo_count = 0;
        //for verify_behavior
        int unsigned correct_count = 0;
        int unsigned error_count = 0;

        function new(mailbox #(SequenceItem) from_monitor);
            this.mbox_export = from_monitor;
        endfunction

        function string convert2string();
            return $sformatf(" out_data=%0h, full=%0b, empty=%0b, almostfull=%0b, almostempty=%0b ",
                                ref_out_data, ref_full, ref_empty, ref_almostfull, ref_almostempty);
        endfunction

        //must create reference_model to generate answer
        task automatic reference_model(SequenceItem test_item);
            if (test_item.rstn) begin
                if (test_item.wr_en && !test_item.rd_en && fifo_count < `FIFO_DEPTH) begin                              //not full, write only
                    ref_fifo.push_back(test_item.in_data);
                    fifo_count ++;
                end else if (test_item.rd_en && !test_item.wr_en && fifo_count > 0) begin                               //not empty, read only
                    ref_out_data = ref_fifo.pop_front();
                    fifo_count --;
                end else if (test_item.wr_en && test_item.rd_en && fifo_count == `FIFO_DEPTH) begin                     //full, read & write -> only read
                    ref_out_data = ref_fifo.pop_front();
                    fifo_count --;
                end else if (test_item.wr_en && test_item.rd_en && fifo_count == 0) begin                               //empty, read & write -> only write
                    ref_fifo.push_back(test_item.in_data);
                    fifo_count ++;
                end else if (test_item.wr_en && test_item.rd_en && fifo_count < `FIFO_DEPTH && fifo_count > 0) begin    // not full/not empty; ping-pong 
                    ref_out_data = ref_fifo.pop_front();
                    ref_fifo.push_back(test_item.in_data);
                    fifo_count = fifo_count;
                end 

            end else if (!test_item.rstn) begin                                                                          //reset
                ref_fifo.delete();                                                                                       //clean
                fifo_count = 0;
            end

            ref_empty = (fifo_count == 0) ? 1'b1 : 1'b0;
            ref_full = (fifo_count == `FIFO_DEPTH) ? 1'b1 : 1'b0;
            ref_almostempty = (fifo_count == (`MARGIN%`FIFO_DEPTH)) ? 1'b1 : 1'b0;
            ref_almostfull = (fifo_count == `FIFO_DEPTH-(`MARGIN%`FIFO_DEPTH)) ? 1'b1 : 1'b0;
            
        endtask

        task verify_behavior(SequenceItem test_item);
            reference_model(test_item);
            if (test_item.out_data === ref_out_data && test_item.full == ref_full && test_item.empty == ref_empty 
                && test_item.almostempty==ref_almostempty && test_item.almostfull==ref_almostfull) begin
                correct_count ++;
                // $display("[%0t][SCOREBOARD] SUCCESS: DUT %s, \nREF %s", $time, test_item.convert2string_all(), convert2string());
            end else begin
                error_count ++;
                $display("[%0t][SCOREBOARD] ERROR: DUT %s, \nREF %s", $time, test_item.convert2string_all(), convert2string());
            end
        endtask

        task report();
            $display("[SCOREBOARD] SUMMARY: CORRECT_count: %0d, ERROR_count: %0d", correct_count, error_count);
        endtask

        task automatic run();
            forever begin
                SequenceItem test_item;
                mbox_export.get(test_item);    
                verify_behavior(test_item);
            end
        endtask        

    endclass

endpackage
