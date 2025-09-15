module SYNC_FIFO #(parameter FIFO_DEPTH=4, PTR_WIDTH=3, DWIDTH=4, MARGIN=1)
(
    input clk, 
    input rstn,

    input wr_en, 
    input rd_en,

    input [DWIDTH-1:0] in_data,

    output full, 
    output empty,

    output almostfull, 
    output almostempty, 
    
    output reg [DWIDTH-1:0] out_data
);
     


    reg [PTR_WIDTH-1:0] wptr, rptr;
    reg [DWIDTH-1:0] ram [0:FIFO_DEPTH-1];

    always @(posedge clk) begin
        if (wr_en && !full)
            ram[wptr[PTR_WIDTH-2:0]] <= in_data;
    end

    always @(posedge clk) begin
        if (rd_en && !empty) 
            out_data <= ram[rptr[PTR_WIDTH-2:0]];
    end


    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            wptr <= 0;
        else if (wr_en && !full)
            wptr <= wptr + 1'd1;
    end

    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            rptr <= 0;
        else if (rd_en && !empty)
            rptr <= rptr + 1'd1;
    end


    assign empty = (wptr == rptr);
    assign full = ((wptr[PTR_WIDTH-1]!=rptr[PTR_WIDTH-1]) && (wptr[PTR_WIDTH-2:0]==rptr[PTR_WIDTH-2:0]));

    assign almostfull  = (!MARGIN[PTR_WIDTH-2:0]) ? full  : (wptr[PTR_WIDTH-2:0] + MARGIN[PTR_WIDTH-2:0]) == (rptr[PTR_WIDTH-2:0]);
    assign almostempty = (!MARGIN[PTR_WIDTH-2:0]) ? empty : (rptr[PTR_WIDTH-2:0] + MARGIN[PTR_WIDTH-2:0]) == (wptr[PTR_WIDTH-2:0]);


endmodule
