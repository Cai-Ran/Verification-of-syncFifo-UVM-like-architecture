`include "MACRO.svh"
package test_pkg;
    import env_pkg::*;
    import sequence_pkg::*;
    import sequencer_pkg::*;

    
    class Test;
        Env env;

        InitialResetSequence rst_seq;
        WriteOnlySequence wr_seq;
        ReadOnlySequence rd_seq;
        MixWriteReset mix_wr_rst_seq;
        MixWriteRead mix_wr_rd_seq;

        function new(virtual DutEnvInterface vinf, int reset_dist, int write_dist, int read_dist);
            env = new(vinf);
            rst_seq = new();
            wr_seq = new();
            rd_seq = new();
            mix_wr_rd_seq = new(reset_dist, write_dist, read_dist);
            mix_wr_rst_seq = new(reset_dist, write_dist);
        endfunction

        task run();

            $display("Info: [TEST] Starting Test...");

            fork
                env.run();                
            join_none

            rst_seq.run(env.agent.sequencer);
            wr_seq.run(env.agent.sequencer);
            rd_seq.run(env.agent.sequencer);
            mix_wr_rd_seq.run(env.agent.sequencer);

            repeat (`NUM_STRESS_LOOPS) begin
                run_read_to_empty(env.agent.sequencer);
                repeat (`NUM_OPERATIONS) begin
                    mix_wr_rd_seq.run(env.agent.sequencer);
                end
            end


            repeat (`NUM_STRESS_LOOPS) begin
                run_write_to_full(env.agent.sequencer);
                repeat (`NUM_OPERATIONS) begin
                    mix_wr_rd_seq.run(env.agent.sequencer);
                end
            end

            $display("Info: [TEST] Completed");
            $display("========================================================");
            $display("FIFO CONFIG: DWIDTH=%0d, FIFO_DEPTH=%0d, PTR_WIDTH=%0d, MARGIN=%0d", `DWIDTH, `FIFO_DEPTH, `PTR_WIDTH, `MARGIN);
            env.scoreboard.report();
            env.cov.report_functional();
            env.cov.report_toggle();
            $display("========================================================");
        endtask

        task automatic run_write_to_full(Sequencer sequencer);
            repeat (`FIFO_DEPTH) begin 
                wr_seq.run(sequencer);
            end
        endtask

        task automatic run_read_to_empty(Sequencer sequencer);
            repeat (`FIFO_DEPTH) begin 
                rd_seq.run(sequencer);
            end
        endtask

    endclass

endpackage