package agent_pkg;
    import sequencer_pkg::*;
    import driver_pkg::*;
    import monitor_pkg::*;
    import sequence_item_pkg::*;

    class Agent;

        Monitor monitor;
        Driver driver;
        Sequencer sequencer;

        function new(virtual DutEnvInterface vinf);
            this.sequencer = new();
            this.driver = new(vinf, sequencer);
            this.monitor = new(vinf);        
        endfunction

        task automatic run();
            fork        
                driver.run();
                monitor.run();
            join_none 
        endtask

        function mailbox #(SequenceItem) get_scoreboard_mbox();
            return monitor.get_scoreboard_mbox();
        endfunction

        function mailbox #(SequenceItem) get_coverage_mbox();
            return monitor.get_coverage_mbox();
        endfunction

    endclass

endpackage
