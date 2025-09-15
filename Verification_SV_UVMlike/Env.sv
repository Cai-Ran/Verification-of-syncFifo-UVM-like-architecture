package env_pkg;
    import agent_pkg::*;
    import scoreboard_pkg::*;
    import coverage_collector_pkg::*;

    class Env;
        Agent agent;
        Scoreboard scoreboard;
        CoverageCollector cov;
        
        function new(virtual DutEnvInterface vinf);
            this.agent = new(vinf);
            this.scoreboard = new(agent.get_scoreboard_mbox());   
            this.cov = new(agent.get_coverage_mbox());       
        endfunction

        task automatic run();
            fork
                agent.run();
                scoreboard.run();
                cov.run();
            join_none
        endtask

    endclass

endpackage
