`timescale 1ps/1ps
`include "MACRO.svh"
`include "../RTL/SYNC_FIFO.v"
`include "DutEnvInterface.sv"
`include "fifo_assert.sv"
// `define DUMP_WAVE

import test_pkg::*;


module tb;


    logic clk;
    initial begin
        clk = 0;
        forever #(`PERIOD/2.0) clk = ~clk;
    end
    DutEnvInterface inf(.clk(clk));
    

    //verilog DUT instance
    SYNC_FIFO #(.FIFO_DEPTH(`FIFO_DEPTH), .PTR_WIDTH(`PTR_WIDTH), .DWIDTH(`DWIDTH), .MARGIN(`MARGIN)) DUT (.clk(inf.clk), .rstn(inf.rstn), .wr_en(inf.wr_en), .rd_en(inf.rd_en), 
    .in_data(inf.in_data), .out_data(inf.out_data), .full(inf.full), .empty(inf.empty), 
    .almostfull (inf.almostfull), .almostempty(inf.almostempty));


    bind SYNC_FIFO fifo_assert ins(.clk(clk), .rstn(rstn), .wr_en(wr_en), .rd_en(rd_en), .wptr(wptr), .rptr(rptr), 
    .empty(empty), .full(full), .almostempty(almostempty), .almostfull(almostfull));


    //for verification of async reset, sample on faster clk; set faster clk frequency = clk frequency*10
    logic fclk;
    initial begin
        fclk = 0;
        forever #(`PERIOD/2.0/10.0) fclk = ~fclk;
    end


    int reset_dist = 10;
    int write_dist = 50;
    int read_dist = 50;

    initial begin
        Test fifo_test;
        fifo_test = new(inf, reset_dist, write_dist, read_dist);
        fork
            fifo_test.run();
        join

        $finish;
    end

    `ifdef DUMP_WAVE
    initial begin
        $dumpfile("dump_sv.vcd");
        $dumpvars();
    end
    `endif

endmodule
