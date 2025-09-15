`include "MACRO.svh"
package sequence_item_pkg;


    class SequenceItem;

        rand bit rstn;
        rand bit wr_en, rd_en;
        rand bit [`DWIDTH-1:0] in_data;

        logic [`DWIDTH-1:0] out_data;
        logic full, empty;
        logic almostfull, almostempty;

        int RSTN_DIST, WR_EN_DIST, RD_EN_DIST;     //manully decide wr_en/rd_en weight

        function void constraint_write_only();
                rstn = 1'b1;
                wr_en = 1'b1;
                rd_en = 1'b0;
        endfunction

        function void constraint_read_only();
                rstn = 1'b1;
                wr_en = 1'b0;
                rd_en = 1'b1;
        endfunction

        function void constraint_no_reset();
                rstn = 1'b1;
        endfunction

        function void constraint_dist_wr_en();
            int rv = $urandom_range(100, 0);
            if (rv < WR_EN_DIST)       wr_en = 1'b1;
            else                            wr_en = 1'b0;
        endfunction

        function void constraint_dist_rd_en();
            int rv = $urandom_range(100, 0);
            if (rv < RD_EN_DIST)       rd_en = 1'b1;
            else                            rd_en = 1'b0;
        endfunction

        function void constraint_dist_rstn();
            int rv = $urandom_range(100, 0);
            if (rv < RSTN_DIST)        rstn = 1'b1;
            else                            rstn = 1'b0;
        endfunction


        //constructor
        function new(int rstn_dist=10, int wr_en_dist=50, int rd_en_dist=50);
            if ((rstn_dist>100 || rstn_dist<0) || (wr_en_dist>100 || wr_en_dist<0) || (rd_en_dist>100 || rd_en_dist<0))
                $fatal("RSTN_DIST/WR_EN_DIST/RD_EN_DIST range (0,100);  WR_E_DIST=%0d, RD_EN_DIST=%0d", wr_en_dist, rd_en_dist);
            this.RSTN_DIST = rstn_dist;
            this.WR_EN_DIST = wr_en_dist;
            this.RD_EN_DIST = rd_en_dist;        
        endfunction

        function string convert2string_input();
            return $sformatf("rstn=%0b, wr_en=%0b, rd_en=%0b, in_data=%0h",
                    rstn, wr_en, rd_en, in_data);
        endfunction

        function string convert2string_all();
            return {
                convert2string_input(),
                $sformatf("\n\t out_data=%0h, full=%0b, empty=%0b, almostfull=%0b, almostempty=%0b",
                                out_data, full, empty, almostfull, almostempty)
            };
        endfunction

        // try to implement randomize() function (not support in modelsim starter)
        function bit imp_randomize();
            rstn = $urandom_range(1, 0);
            wr_en = $urandom_range(1, 0);
            rd_en = $urandom_range(1, 0);
            in_data = $urandom_range((1<<`DWIDTH)-1, 0);
            return 1'b1;
        endfunction

    endclass

endpackage
