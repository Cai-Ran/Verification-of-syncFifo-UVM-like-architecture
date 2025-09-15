`include "MACRO.svh"
package coverage_collector_pkg;

    import sequence_item_pkg::*;

    class CoverageCollector;

        mailbox #(SequenceItem) mbox_export;
        //functional coverage
        bit cross_wr_rd_empty[2][2][2];
        bit cross_wr_rd_full[2][2][2];
        bit cross_wr_rd_almostempty[2][2][2];
        bit cross_wr_rd_almostfull[2][2][2];
        //toggle coverage
        bit toggle_rstn[2];
        bit toggle_wr[2];
        bit toggle_rd[2];
        bit toggle_full[2];
        bit toggle_empty[2];
        bit toggle_almostfull[2];
        bit toggle_almostempty[2];
        bit toggle_indata[`DWIDTH][2];
        bit toggle_outdata[`DWIDTH][2];

        function new(mailbox #(SequenceItem) from_monitor);
            this.mbox_export = from_monitor;
        endfunction

        task automatic sample(SequenceItem test_seq_item);
            bit rstn = test_seq_item.rstn;
            bit wr = test_seq_item.wr_en;
            bit rd = test_seq_item.rd_en;
            bit full = test_seq_item.full;
            bit empty = test_seq_item.empty;
            bit almostempty = test_seq_item.almostempty;
            bit almostfull = test_seq_item.almostfull;
            bit [`DWIDTH-1:0] indata = test_seq_item.in_data;
            bit [`DWIDTH-1:0] outdata = test_seq_item.out_data;
            
            //functional coverage
            if (test_seq_item.rstn) begin
                cross_wr_rd_empty[wr][rd][empty] = 1;
                cross_wr_rd_full[wr][rd][full] = 1;
                cross_wr_rd_almostempty[wr][rd][almostempty] = 1;
                cross_wr_rd_almostfull[wr][rd][almostfull] = 1;
            end
            //toggle coverage
            toggle_rstn[rstn] = 1;
            toggle_wr[wr] = 1;
            toggle_rd[rd] = 1;
            toggle_full[full] = 1;
            toggle_empty[empty] = 1;
            toggle_almostfull [almostfull]  = 1;
            toggle_almostempty[almostempty] = 1;
            foreach(toggle_indata[i]) toggle_indata[i][indata[i]] = 1;
            foreach(toggle_outdata[i]) toggle_outdata[i][outdata[i]] = 1;  

        endtask


        task automatic report_functional();
            localparam MARGIN = `MARGIN;
            int unsigned cnt_wr_rd_empty = 0, cnt_wr_rd_full = 0, cnt_wr_rd_almostempty=0, cnt_wr_rd_almostfull=0;
            real cvg_wr_rd_empty = 0, cvg_wr_rd_full = 0, cvg_wr_rd_almostempty=0, cvg_wr_rd_almostfull=0;
            bit illegal_wr_rd_empty1 = cross_wr_rd_empty[1][0][1];                                                      //only write --> no empty
            bit illegal_wr_rd_empty2 = cross_wr_rd_empty[1][1][1];                                                      //when empty, NOT ALLOWED READ
            bit illegal_wr_rd_full1  = cross_wr_rd_full[0][1][1];                                                       //only read --> no full
            bit illegal_wr_rd_full2  = cross_wr_rd_full[1][1][1];
            bit illegal_wr_rd_almostempty1 = 0; 
            bit illegal_wr_rd_almostempty2 = 0; 
            bit illegal_wr_rd_almostfull1 = 0; 
            bit illegal_wr_rd_almostfull2 = 0; 
                                                                       //when full, NOT ALLOWED WRITE
            int unsigned cnt_illegal_wr_rd_empty = 0, cnt_illegal_wr_rd_full = 0, cnt_illegal_wr_rd_almostempty, cnt_illegal_wr_rd_almostfull;

            if (`MARGIN%`FIFO_DEPTH==0) begin
                illegal_wr_rd_almostempty1 = cross_wr_rd_almostempty[1][0][1]; 
                illegal_wr_rd_almostempty2 = cross_wr_rd_almostempty[1][1][1]; 
                illegal_wr_rd_almostfull1 = cross_wr_rd_almostfull[0][1][1]; 
                illegal_wr_rd_almostfull2 = cross_wr_rd_almostfull[1][1][1]; 
            end
            // foreach (cross_wr_rd_empty[i,j,k]) begin
            //     if (!(i && k))  cnt_wr_rd_empty += cross_wr_rd_empty[i][j][k];
            //     else    cnt_illegal_wr_rd_empty += cross_wr_rd_empty[i][j][k];
            // end
            // foreach (cross_wr_rd_full[i,j,k]) begin
            //     if (!(j && k))  cnt_wr_rd_full += cross_wr_rd_full[i][j][k];
            //     else    cnt_illegal_wr_rd_full += cross_wr_rd_full[i][j][k];
            // end
            foreach (cross_wr_rd_empty[i,j,k])          cnt_wr_rd_empty += cross_wr_rd_empty[i][j][k];
            foreach (cross_wr_rd_full[i,j,k])           cnt_wr_rd_full += cross_wr_rd_full[i][j][k];
            foreach (cross_wr_rd_almostempty[i,j,k])    cnt_wr_rd_almostempty += cross_wr_rd_almostempty[i][j][k];
            foreach (cross_wr_rd_almostfull[i,j,k])     cnt_wr_rd_almostfull += cross_wr_rd_almostfull[i][j][k];

            cnt_illegal_wr_rd_empty = illegal_wr_rd_empty1 + illegal_wr_rd_empty2;
            cnt_illegal_wr_rd_full = illegal_wr_rd_full1 + illegal_wr_rd_full2;
            cnt_illegal_wr_rd_almostempty = illegal_wr_rd_almostempty1 + illegal_wr_rd_almostempty2;
            cnt_illegal_wr_rd_almostfull = illegal_wr_rd_almostfull1 + illegal_wr_rd_almostfull2;

            cvg_wr_rd_empty = ((cnt_wr_rd_empty-cnt_illegal_wr_rd_empty) *100.0)/(2*2*2-2);
            cvg_wr_rd_full = ((cnt_wr_rd_full-cnt_illegal_wr_rd_full) *100.0)/(2*2*2-2);
            if (`MARGIN%`FIFO_DEPTH==0) begin
                cvg_wr_rd_almostempty = ((cnt_wr_rd_almostempty-cnt_illegal_wr_rd_almostempty)*100.0)/(2*2*2-2);
                cvg_wr_rd_almostfull = ((cnt_wr_rd_almostfull-cnt_illegal_wr_rd_almostfull)*100.0)/(2*2*2-2);
            end else begin
                cvg_wr_rd_almostempty = (cnt_wr_rd_almostempty*100.0)/(2*2*2);
                cvg_wr_rd_almostfull = (cnt_wr_rd_almostfull*100.0)/(2*2*2);
            end

            if (cvg_wr_rd_empty!=100) foreach(cross_wr_rd_empty[i,j,k]) $display("%0d, %0d, %0d, %0d", i,j,k, cross_wr_rd_empty[i][j][k]);
            $display("");
            if (cvg_wr_rd_full!=100) foreach(cross_wr_rd_full[i,j,k]) $display("%0d, %0d, %0d, %0d", i,j,k, cross_wr_rd_full[i][j][k]);
            $display("");
            if (cvg_wr_rd_almostempty!=100) foreach(cross_wr_rd_almostempty[i,j,k]) $display("%0d, %0d, %0d, %0d", i,j,k,cross_wr_rd_almostempty[i][j][k]);
            $display("");
            if (cvg_wr_rd_almostfull!=100) foreach(cross_wr_rd_almostfull[i,j,k]) $display("%0d, %0d, %0d, %0d", i,j,k, cross_wr_rd_almostfull[i][j][k]);


            $display("[FUNCTIONAL COVERAGE REPORT]: ");
            $display("wr_rd_empty: \t\t\t%0.2f %%, \t illegal %0d", cvg_wr_rd_empty, cnt_illegal_wr_rd_empty);
            $display("wr_rd_full: \t\t\t%0.2f %%, \t illegal %0d", cvg_wr_rd_full, cnt_illegal_wr_rd_full);

            $display("wr_rd_almostempty:\t%0.2f %% \t illegal %0d", cvg_wr_rd_almostempty, cnt_illegal_wr_rd_almostempty);
            $display("wr_rd_almostfull:\t\t%0.2f %% \t illegal %0d", cvg_wr_rd_almostfull, cnt_illegal_wr_rd_almostfull);

        endtask

        task automatic report_toggle();
            int unsigned cnt_rstn = 0, cnt_wr = 0, cnt_rd = 0, cnt_full = 0, cnt_empty = 0, cnt_almostfull = 0, cnt_almostempty = 0, cnt_indata = 0, cnt_outdata = 0;
            real cvg_rstn = 0, cvg_wr = 0, cvg_rd = 0, cvg_full = 0, cvg_empty = 0, cvg_almostfull = 0, cvg_almostempty = 0, cvg_indata = 0, cvg_outdata = 0;
            foreach(toggle_rstn[i])         cnt_rstn        += toggle_rstn[i];
            foreach(toggle_wr[i])           cnt_wr          += toggle_wr[i];
            foreach(toggle_rd[i])           cnt_rd          += toggle_rd[i];
            foreach(toggle_full[i])        cnt_full         += toggle_full[i];
            foreach(toggle_empty[i])       cnt_empty        += toggle_empty[i];
            foreach(toggle_almostfull[i])  cnt_almostfull   += toggle_almostfull[i];
            foreach(toggle_almostempty[i]) cnt_almostempty  += toggle_almostempty[i];
            foreach(toggle_indata[i, j]) cnt_indata += toggle_indata[i][j];
            foreach(toggle_indata[i, j]) cnt_outdata += toggle_outdata[i][j];

            cvg_rstn        = (cnt_rstn)        * 100.0 / 2;
            cvg_wr          = (cnt_wr)          * 100.0 / 2;
            cvg_rd          = (cnt_rd)          * 100.0 / 2;
            cvg_full        = (cnt_full)        * 100.0 / 2;
            cvg_empty       = (cnt_empty)       * 100.0 / 2;
            cvg_almostfull  = (cnt_almostfull)  * 100.0 / 2;
            cvg_almostempty = (cnt_almostempty) * 100.0 / 2;
            cvg_indata      = (cnt_indata)      * 100.0 / (`DWIDTH * 2);
            cvg_outdata     = (cnt_outdata)     * 100.0 / (`DWIDTH * 2);


            $display("[TOGGLE COVERAGE REPORT]: ");
            $display("rstn:         \t%0.2f %%", cvg_rstn);
            $display("wr_en:        \t%0.2f %%", cvg_wr);
            $display("rd_en:        \t%0.2f %%", cvg_rd);
            $display("indata:       \t%0.2f %%", cvg_indata);
            $display("full:         \t%0.2f %%", cvg_full);
            $display("empty:        \t%0.2f %%", cvg_empty);
            $display("almostfull:   \t%0.2f %%", cvg_almostfull);
            $display("almostempty:  \t%0.2f %%", cvg_almostempty);
            $display("outdata:      \t%0.2f %%", cvg_outdata);
        endtask



        task automatic run();
            forever begin
                SequenceItem test_seq_item;
                test_seq_item = new();
                mbox_export.get(test_seq_item);
                sample(test_seq_item);
            end
        endtask
        

    endclass

endpackage
