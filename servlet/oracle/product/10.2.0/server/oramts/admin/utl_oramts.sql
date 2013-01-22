CREATE  OR REPLACE PACKAGE 
	utl_oramts
AS
   -- subprogram specifications	
	-- entry point for recovery job
	PROCEDURE  recover_automatic;
	-- list all in-doubt Micosoft Transaction Server related transactions
	PROCEDURE  show_indoubt;
	-- forget all resource managers that have no indoubt transactions
	PROCEDURE  forget_RMs;
	-- given a branch qualifier extract the protocol id
	FUNCTION  get_protocol(brqual IN VARCHAR2) RETURN VARCHAR2;
	-- given a branch qualifier extract the endpoint 
	FUNCTION  get_endpoint(brqual IN VARCHAR2) RETURN VARCHAR2;
        /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */  
        -- the following are for debugging purposes only
        /* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */  
        -- set debug trace on
        PROCEDURE set_trace_on;
        -- set debug trace off
        PROCEDURE set_trace_off;
        -- set trace to console on 
        PROCEDURE set_trace_console_on;
        -- set trace to console off 
        PROCEDURE set_trace_console_off;
END utl_oramts;
/
