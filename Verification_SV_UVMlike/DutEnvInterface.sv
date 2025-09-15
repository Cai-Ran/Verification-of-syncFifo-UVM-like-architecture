`include "MACRO.svh"
interface DutEnvInterface (input clk);


    logic rstn;
    logic wr_en, rd_en;
    logic [`DWIDTH-1:0] in_data, out_data;
    logic full, empty;
    logic almostfull, almostempty;

    clocking cb @(posedge clk);
        default input #1step output #(`PERIOD*0.1);
        input out_data, empty, full, almostempty, almostfull;
        output wr_en, rd_en, in_data;
        output rstn;
    endclocking


    modport DUT (input clk, rstn, wr_en, rd_en, in_data,
                output out_data, full, empty, almostfull, almostempty);

    modport ENV (output clk, rstn, wr_en, rd_en, in_data,
                input out_data, full, empty, almostfull, almostempty);


endinterface
