`include "MACRO.svh"

module fifo_assert(
    input logic clk, 
    input logic rstn,
    input logic wr_en, 
    input logic rd_en,
    input logic [`PTR_WIDTH-1:0] wptr,
    input logic [`PTR_WIDTH-1:0] rptr,
    input logic empty,
    input logic full,
    input logic almostempty,
    input logic almostfull
);

    localparam MARGIN = `MARGIN;
    reg prev_w_rtn, prev_r_rtn, prev_wr_en, prev_rd_en, prev_full, prev_empty;
    reg [`PTR_WIDTH-1:0] prev_wptr, prev_rptr;

    //ID1 asyn_rst
    always_ff @(posedge tb.fclk) begin
        if (!rstn) begin
            if (`MARGIN%`FIFO_DEPTH!=0) begin
                assert ((wptr==='0) && (rptr==='0) && !full && empty && !almostfull && !almostempty) 
                else    $display("[%0t] ASSERTION ERROR: ID1 async_rst", $time);
            end else begin
                assert ((wptr==='0) && (rptr==='0) && !full && empty && !almostfull && almostempty) 
                else    $display("[%0t] ASSERTION ERROR: ID1 async_rst", $time);
            end  
        end
    end 
    
    //ID2 wptr
    always_ff @(posedge clk) begin
        prev_w_rtn      <= rstn;
        prev_wr_en      <= wr_en;
        prev_full       <= full;
        prev_wptr       <= wptr;
        if (prev_w_rtn && prev_wr_en && !prev_full) begin
            assert ((prev_wptr+ 1'b1) === wptr) 
            else    $display("[%0t] ASSERTION ERROR: ID2 wptr", $time);
        end
    end
    //ID3 rptr
    always_ff @(posedge clk) begin
        prev_r_rtn      <= rstn;
        prev_rd_en      <= rd_en;
        prev_empty      <= empty;
        prev_rptr       <= rptr;
        if (prev_r_rtn && prev_rd_en && !prev_empty) begin
            assert ((prev_rptr+1'b1) === rptr) 
            else begin
                $display("[%0t] ASSERTION ERROR: ID3 rptr", $time);
                $display(prev_r_rtn, prev_rd_en, prev_empty, prev_rptr, rptr);
            end
        end
    end
    //ID4 full
    always_comb begin
        if (wptr[`PTR_WIDTH-1]!=rptr[`PTR_WIDTH-1] && wptr[`PTR_WIDTH-2:0]==rptr[`PTR_WIDTH-2:0]) begin
            assert (full)
            else $display("[%0t] ASSERTION ERROR: ID4 full", $time);
        end
    end
    //ID5 empty
    always_comb begin
        if (wptr==rptr) begin
            assert (empty)
            else $display("[%0t] ASSERTION ERROR: ID5 empty", $time);
        end
    end
    //ID6 almostfull
    always_comb begin
        if (MARGIN[`PTR_WIDTH-2:0]!==0 && ((wptr[`PTR_WIDTH-2:0]+MARGIN[`PTR_WIDTH-2:0])==rptr[`PTR_WIDTH-2:0])
            || (!MARGIN[`PTR_WIDTH-2:0] && full)) begin
            assert (almostfull)
            else $display("[%0t] ASSERTION ERROR: ID6 almostfull", $time);
        end
    end
    //ID7 almostempty
    always_comb begin
        if ((MARGIN[`PTR_WIDTH-2:0]!==0 && ((rptr[`PTR_WIDTH-2:0]+MARGIN[`PTR_WIDTH-2:0])==wptr[`PTR_WIDTH-2:0])
            || (!MARGIN[`PTR_WIDTH-2:0]) && empty)) begin
            assert (almostempty)
            else $display("[%0t] ASSERTION ERROR: ID7 almostempty", $time);
        end
    end


endmodule
