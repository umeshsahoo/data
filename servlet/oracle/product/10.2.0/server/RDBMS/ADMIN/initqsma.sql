Rem
Rem $Header: initqsma.sql 08-aug-2005.10:36:53 sramakri Exp $
Rem
Rem initqsma.sql
Rem
Rem Copyright (c) 2000, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initqsma.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Loads the Java stored procedures as required by the
Rem      Summary Advisor.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    08/08/05 - insert body of dbms_sumadvisor package 
Rem    gssmith     08/17/01 - Script bug
Rem    gssmith     09/05/00 - Optimization
Rem    gssmith     04/12/00 - Loads java components for Summary Advisor
Rem    gssmith     04/12/00 - Created
Rem

call sys.dbms_java.loadjava('-v -s -g public -f -r rdbms/jlib/qsma.jar');

-- body of dbms_sumadvisor package (moved from prvtsms.sql)
 CREATE OR REPLACE PACKAGE BODY dbms_sumadvisor
 IS
     --------------------------------------------------------------
     -- CONSTANTS for dbms_sumadvisor
     --------------------------------------------------------------

     -- QUOTE
     QUOTE CONSTANT CHAR := '''';

     -- PERIOD
     PERIOD CONSTANT CHAR := '.';

     -- COMMA
     COMMA CONSTANT CHAR := ',';

     -- string list format is 'user.table,....' w/o space in between
     FULL_STRLIST_FORMAT CONSTANT BINARY_INTEGER := 1;

     -- string list format is 'user, user...' or 'table, table..' w/o space
     PARTIAL_STRLIST_FORMAT CONSTANT BINARY_INTEGER := 2;
     
     -- comma list format is 'abitrary str, abibrary str, ...', spaces allowed
     COMMA_STRLIST_FORMAT CONSTANT BINARY_INTEGER := 3;
       
     -- sequence for generating generic keys
     GENERIC_SEQ CONSTANT NUMBER := 1;

     -- sequence for generating runid and collection id
     ID_SEQ CONSTANT NUMBER := 2;

     -- status values
     UNUSED_STATUS CONSTANT NUMBER := 0;
     CANCELLED_STATUS CONSTANT NUMBER := 1;
     IN_PROGRESS_STATUS CONSTANT NUMBER := 2;
     COMPLETED_STATUS CONSTANT NUMBER := 3;
     ERROR_STATUS CONSTANT NUMBER := 4;

     -- run types
     EVALUATE_RUNTYPE CONSTANT NUMBER := 1;
     EVALUATE_W_RUNTYPE CONSTANT NUMBER := 2;
     RECOMMEND_RUNTYPE CONSTANT NUMBER := 3;
     RECOMMEND_W_RUNTYPE CONSTANT NUMBER := 4;
     VALIDATE_RUNTYPE CONSTANT NUMBER := 5;
     COLLECTION_RUNTYPE CONSTANT NUMBER := 6;
     FILTER_RUNTYPE CONSTANT NUMBER :=7;
     
     -- total steps required by an action
     -- evaluate without workload, single step as in 8.1? TBD
     EVALUATE_STEPS CONSTANT NUMBER := 1;
     
     -- evaluate with workload
     EVALUATE_W_KERNEL CONSTANT NUMBER :=18;
     EVALUATE_W_EXTERNAL CONSTANT NUMBER :=2;
     EVALUATE_W_STEPS CONSTANT NUMBER := 
       EVALUATE_W_KERNEL + EVALUATE_W_EXTERNAL;
     
     -- recommend without workload, single step as in 8.1? TBD
     RECOMMEND_STEPS CONSTANT NUMBER := 1;
     
     -- recommend with worload
     RECOMMEND_W_ANALYZE CONSTANT NUMBER :=10;
     RECOMMEND_W_EXTERNAL CONSTANT NUMBER :=8;
     
     -- RECOMMEND_W_VALIDATE CONSTANT NUMBER :=2;
     RECOMMEND_W_STEPS CONSTANT NUMBER := 
       RECOMMEND_W_ANALYZE  + RECOMMEND_W_EXTERNAL;
     -- + RECOMMEND_W_VALIDATE; (disable validation)
     
     -- recommend without workload, single step as in 8.1? TBD
     VALIDATE_STEPS CONSTANT NUMBER := 1;

     -- types for filter items
     APPLICATION_FILTER CONSTANT BINARY_INTEGER := 1;
     CARDINALITY_FILTER CONSTANT BINARY_INTEGER := 2;
     LASTUSE_FILTER CONSTANT BINARY_INTEGER := 3;
     FREQUENCE_FILTER CONSTANT BINARY_INTEGER := 4;
     OWNER_FILTER CONSTANT BINARY_INTEGER := 5;
     PRIORITY_FILTER CONSTANT BINARY_INTEGER := 6;
     BASETABLE_FILTER CONSTANT BINARY_INTEGER := 7;
     RESPONSETIME_FILTER CONSTANT BINARY_INTEGER := 8;
     COLLECTIONID_FILTER CONSTANT BINARY_INTEGER := 9;
     TRACENAME_FILTER CONSTANT BINARY_INTEGER := 10;

     -- flags for analyze_sql
     -- only perform workload classification analysis
     ANALYZESQL_CLASSIFY CONSTANT BINARY_INTEGER := 1;
     -- only perform workload evaluation analysis
     ANALYZESQL_EVALUATE CONSTANT BINARY_INTEGER := 2;
     -- only perform output validation
     ANALYZESQL_VALIDATE CONSTANT BINARY_INTEGER := 4;
     -- only informatino units
     ANALYZESQL_INFO CONSTANT BINARY_INTEGER :=8;
     
     -- output table type
     RECOMMENDATION_TABLE CONSTANT BINARY_INTEGER :=1;
     EVALUATION_TABLE CONSTANT BINARY_INTEGER :=2;
          
     -- check_error types
     CHECKERROR_CONSIDER_WARNINGS CONSTANT BINARY_INTEGER :=1;
     CHECKERROR_IGNORE_WARNINGS CONSTANT BINARY_INTEGER :=2;
          
     -- statement headers 
     HEADER_STMT CONSTANT VARCHAR2(200) :=
       'SELECT queryid#, ' ||
       '   NVL(frequency, 1), ' ||
       '   NVL(priority, 1), rowid, sql_textlen, uname ';
     HEADER_COUNT CONSTANT VARCHAR2(100) :=
       'SELECT COUNT(*) ';
     
     --------------------------------------------------------------
     -- INTERNAL EXCEPTIONS for dbms_sumadvisor
     --------------------------------------------------------------
     INTERNAL_EXCEPTION EXCEPTION;

     -- invalid parameters
     INVALID_PARAMETER_EXCEPTION EXCEPTION;

     --------------------------------------------------------------
     -- Package-global variables
     --------------------------------------------------------------
     -- saved cursor_sharing session parameter value
     save_cursor_sharing VARCHAR2(256);

     -- saved query_rewrite_integrity level
     save_query_rewrite_integrity VARCHAR2(256);

     -- saved query_rewrite_enabled information
     save_query_rewrite_enabled VARCHAR2(256);
     
     -- the following three parameters keep track of BASETABLE/SCHEMA filter
     -- owner filter list
     base_owner dbms_utility.name_array;

     -- table filter list
     base_table dbms_utility.name_array;

     -- number of valid entries in the above two arrays
     base_count binary_integer;

     --------------------------------------------------------------
     -- 3GL Callouts
     --------------------------------------------------------------

     --------------------------------------------------------------
     -- REMARKS:
     --   Use sqltext to retrieve workload queries. Analyze them
     --   one by one and populate the advisor repository with
     --   intermediate analysis results
     -- INPUT:
     --   runid         current run id
     --   flag          recommend/evaluate/validate
     --   sqltext       query text for retrieving workload
     --   uname         current user
     --   curstep       current step
     --   totalstep     total number of steps
     --   nextstep      next step to start from
     -- OUTPUT:
     --   none
     --
     -- EXCEPTIONS:
     --   TBD
     --------------------------------------------------------------
     PROCEDURE analyze_sql
       (
        runid                   IN BINARY_INTEGER,
        counter                 IN BINARY_INTEGER,
        flag                    IN BINARY_INTEGER,
        sqltext                 IN VARCHAR2,
        uname                   IN VARCHAR2,
        ownfilter               IN dbms_utility.name_array,
        tabfilter               IN dbms_utility.name_array,
        basecount               IN BINARY_INTEGER,
        lostep                  IN BINARY_INTEGER,
        histep                  IN BINARY_INTEGER
       )
     IS
        EXTERNAL
          NAME "qsmssql"
          LIBRARY dbms_sumapi_lib
          WITH CONTEXT
          PARAMETERS
          (CONTEXT,
          runid     UB4,
          counter   UB4,
          flag      UB4,
          sqltext   OCISTRING,   sqltext   INDICATOR SB2,
          uname     OCISTRING,   uname     INDICATOR SB2,
          ownfilter OCICOLL,     tabfilter OCICOLL, 
          basecount UB4,
          lostep    UB4,
          histep    UB4
          )
          LANGUAGE C;

     --------------------------------------------------------------
     -- PRIVATE METHODS
     --------------------------------------------------------------
     PROCEDURE validate_id
        (
         id                     IN NUMBER,
         cnt                    OUT NUMBER  
        )
     IS
     BEGIN
        SELECT COUNT(*) INTO cnt
        FROM system.mview$_adv_log
        WHERE runid# = id AND uname = user AND 
              status = UNUSED_STATUS;
     END validate_id;

     PROCEDURE set_started
        (
         id                     IN NUMBER,
         filter                 IN NUMBER,
         runtype                IN NUMBER,
         steps                  IN NUMBER
        )
     IS
     BEGIN
        UPDATE system.mview$_adv_log
        SET filterid#= filter, run_begin = sysdate,
            run_end = sysdate, run_type = runtype, 
            status = IN_PROGRESS_STATUS, message ='',
            total = steps, completed = 0
        WHERE runid# = id;
     END set_started;

     PROCEDURE set_completed
        (
         id                     IN NUMBER
        )
     IS
     BEGIN
        UPDATE system.mview$_adv_log
        SET run_end = sysdate, status = COMPLETED_STATUS, 
            completed = total 
        WHERE runid# = id;
     END set_completed;
     
     --------------------------------------------------------------
     -- REMARKS:
     --   Allocate a new value from the specified sequence
     -- INPUT:
     --   source        source of sequences
     -- OUTPUT:
     --   A new unique ID value
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     FUNCTION generate_id
       (
        source                  IN NUMBER
       )
        RETURN NUMBER
     IS
        runid   NUMBER;
     BEGIN
        IF source = GENERIC_SEQ THEN
           SELECT system.mview$_advseq_generic.nextval INTO runid
             FROM dual;
        ELSIF source = ID_SEQ THEN
           SELECT system.mview$_advseq_id.nextval INTO runid
             FROM dual;
        ELSE
           runid := -1;
        END IF;
        RETURN runid;
     END generate_id;

     --------------------------------------------------------------
     -- REMARKS:
     --   parse and execute a user supplied SQL statement
     -- INPUT:
     --   source        source of sequence id
     -- OUTPUT:
     --   cmdbuf        sql statement to be executed
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     PROCEDURE execute_sql
       (
        cmdbuf                  IN VARCHAR2
       )
     IS
        cursor_name INTEGER;
        rows_processed INTEGER;
     BEGIN
        cursor_name := dbms_sql.open_cursor;
        dbms_sql.parse(cursor_name, cmdbuf, dbms_sql.native);
        rows_processed := dbms_sql.execute(cursor_name);
        dbms_sql.close_cursor(cursor_name);
     EXCEPTION
        WHEN OTHERS THEN
          dbms_sql.close_cursor(cursor_name);
     END execute_sql;


     --------------------------------------------------------------
     -- REMARKS:
     --   Retrieve a parameter value from the v$ table by name
     -- INPUT:
     --   pname         parameter name
     -- OUTPUT:
     --   parameter value
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     FUNCTION get_parameter
       (
        pname                    IN VARCHAR2
       )
        RETURN VARCHAR2
     IS
        val VARCHAR2(256);
     BEGIN
        SELECT VALUE INTO val
          FROM v$parameter
          WHERE name= pname;
        RETURN val;
     EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
     END get_parameter;

     --------------------------------------------------------------
     -- REMARKS:
     --   Set session variable
     -- INPUT:
     --   pname         session variable name
     --   val           new session variable value
     -- OUTPUT:
     --   old value for the parameter
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     FUNCTION set_session_val
       (
        pname                   IN VARCHAR2,
          val                   IN VARCHAR2
       )
       RETURN VARCHAR2
     IS
        cmdbuf VARCHAR2(256);
        oldval VARCHAR2(256);
     BEGIN
        oldval := get_parameter(pname);
        IF oldval IS NULL THEN
           RAISE INTERNAL_EXCEPTION;
        ELSE
           cmdbuf := 'ALTER SESSION SET '|| pname || ' = ' || val;
           execute_sql(cmdbuf);
        END IF;
        RETURN oldval;
     END set_session_val;

     --------------------------------------------------------------
     -- REMARKS:
     --   Return first value of first row
     -- INPUT:
     --   stmt          sql statement
     -- OUTPUT:
     --   return value  first column value of first fetched row
     --------------------------------------------------------------     
     PROCEDURE log_error
       (
        runid                   IN NUMBER,
        code                    IN NUMBER
       )
     IS
     BEGIN
       UPDATE system.mview$_adv_log 
         SET error_code = 'ORA-' || code, completed = ERROR_STATUS
         WHERE runid# = runid;
       COMMIT;
     END log_error;

     --------------------------------------------------------------
     -- REMARKS:
     --   generate a pattern not currently in a provided string
     -- INPUT:
     --   stmt          sql statement
     -- OUTPUT:
     --   return value  first column value of first fetched row
     --------------------------------------------------------------
     FUNCTION generate_pattern
       (
       seed                     IN VARCHAR2,
       str                      IN VARCHAR2
       )
        RETURN VARCHAR2
     IS
        i       NUMBER;
        rst     VARCHAR2(1024);
     BEGIN
        -- first try digital pattern
        FOR i IN 0..99 LOOP
           IF instr(str, i, 1, 1) = 0 THEN
              RETURN 'T'||i;
           END IF;
        END LOOP;
        
        -- finally try user prefix pattern
        FOR i IN 1..100 LOOP
           rst := seed || '_' || i ||'_';
           IF instr(str, rst, 1, 1) = 0 THEN
              RETURN rst;
           END IF;
        END LOOP; 
        RAISE internal_exception;
     END generate_pattern;    

     --------------------------------------------------------------
     -- REMARKS:
     --   Convert a comma-sperated string, into a list of quote-delmited 
     --   items.
     --      e.g. 'a,b,c,d' -> 'a', 'b', 'c', 'd'
     -- INPUT:
     --   strlist     arbitrary string
     --
     -- OUTPUT:
     --   return value  quote-delimited list of items
     -- EXCEPTIONS:
     --   INVALID_PARAMETER_EXCEPTION    if syntax error
     --------------------------------------------------------------
     FUNCTION string_to_list
       (
       strlist                IN VARCHAR2,
       capitalcase            IN BOOLEAN
       )
       RETURN VARCHAR2
     IS
        prev NUMBER := 1;   
        cur NUMBER;
        buffer VARCHAR2(32767) := NULL;
     BEGIN
        LOOP
           cur := INSTR(strlist || COMMA, COMMA , prev, 1);
           EXIT WHEN cur = 0; 
           IF cur = prev THEN
              RAISE INVALID_PARAMETER_EXCEPTION;
           END IF;

           IF cur > prev THEN
              IF buffer IS NOT NULL THEN
                 buffer := buffer || COMMA;
              END IF;
              buffer := buffer || QUOTE;
              IF capitalcase THEN
                 buffer := buffer || UPPER(SUBSTR(strlist, prev, cur -prev));
              ELSE
                 buffer := buffer || SUBSTR(strlist, prev, cur -prev);
              END IF;
              buffer := buffer || quote;
              prev := cur + 1;
           END IF;
        END LOOP;
        RETURN buffer;
     END string_to_list;

     --------------------------------------------------------------
     -- REMARKS:
     --   Break string list into tokens and see if the list syntax conforms
     --   to the following format:
     --         'X1.Y1, X2.Y2'
     --   validate_strlist has two overloaded versions.
     --   One version with full signature
     --   The other version only performs validation with no output
     -- INPUT:
     --   strlist     arbitrary string
     --
     -- OUTPUT:
     --   return value  identical to input, if it passes validation
     --   ownertab      table of owner names
     --   tblnametab    table of table names
     --   needquote     add quote to each element
     -- EXCEPTIONS:
     --   Many execeptions are possible during the parsing process
     --   INVALID_PARAMETER_EXCEPTION    if syntax error
     --------------------------------------------------------------
     FUNCTION validate_strlist
       (
        format                  IN BINARY_INTEGER,
        strlist                 IN VARCHAR2,
        fixstr                  IN BOOLEAN,
        needquote               IN BOOLEAN,
        tablen                  OUT BINARY_INTEGER,
        ownertab                OUT dbms_utility.uncl_array,
        tblnametab              OUT dbms_utility.uncl_array
       )
        RETURN VARCHAR2
     IS
        tab dbms_utility.uncl_array;
        owner VARCHAR2(256);
        tblname VARCHAR2(256);
        dummy1 VARCHAR2(256);
        dummy2 VARCHAR2(256);
        pos BINARY_INTEGER;
        i BINARY_INTEGER := 0;
        buffer VARCHAR2(32767) := '';
     BEGIN
        -- break arbitrary-format string into list
        IF format = COMMA_STRLIST_FORMAT THEN
           RETURN string_to_list(strlist, TRUE);
        END IF;
        
        -- break comma list into strings
        dbms_utility.comma_to_table(strlist, tablen, tab);

        -- raise exception if the list is empty
        IF tablen = 0 THEN
           RAISE INVALID_PARAMETER_EXCEPTION;
        END IF;

        -- tokenize each part to validate syntax
        FOR i IN 1..tablen LOOP
           -- tokenize a string list, exception might be thrown
           dbms_utility.name_tokenize(
             tab(i), owner, tblname, dummy1, dummy2, pos);
           ownertab(i) := owner;
           tblnametab(i) := tblname;

           -- raise exception if the format is illegal
           IF owner IS NULL OR
             dummy1 IS NOT NULL OR
             dummy2 IS NOT NULL THEN
              RAISE INVALID_PARAMETER_EXCEPTION;
           END IF;

           -- for full format, try fix it if requested
           IF format = FULL_STRLIST_FORMAT AND tblname IS NULL THEN
              IF fixstr THEN
                 tblname := owner;
                 owner := user;
                 ownertab(i) := owner;
                 tblnametab(i) := tblname;
              ELSE
                 RAISE INVALID_PARAMETER_EXCEPTION;
              END IF;
           END IF;

           -- assemble output
           IF needquote THEN
              buffer := buffer || QUOTE;
           END IF;
           buffer := buffer || owner;
           IF format = FULL_STRLIST_FORMAT THEN
              buffer :=buffer || PERIOD || tblname;
           END IF;
           IF needquote THEN
              buffer := buffer || QUOTE;
           END IF;

           -- append a COMMA if not the last string
           IF i < tablen THEN
              buffer := buffer || COMMA;
           END IF;
        END LOOP;
        RETURN buffer;
     END validate_strlist;

     FUNCTION validate_strlist
       (
        format                  IN BINARY_INTEGER,
        strlist                 IN VARCHAR2,
        fixstr                  IN BOOLEAN := FALSE,
        needquote               IN BOOLEAN := FALSE
       )
        RETURN VARCHAR2
     IS
        tablen BINARY_INTEGER;
        ownertab dbms_utility.uncl_array;
        tblnametab dbms_utility.uncl_array;
     BEGIN
        -- discard all output, just to see whether it causes exception
        RETURN
          validate_strlist(format, strlist, fixstr, needquote,
          tablen, ownertab, tblnametab);
     END validate_strlist;
     
     PROCEDURE process_filter
       (
       run_id                  IN NUMBER,
       filter_id               IN NUMBER,
       fact_table_filter       IN VARCHAR2,
       merge_filter            IN BOOLEAN
       )
     IS
        fid NUMBER;
        cnt NUMBER;
        strfilter system.mview$_adv_filter.str_value%TYPE;
        subnum system.mview$_adv_filter.subfilternum#%TYPE;
        pattern VARCHAR2(1024);
        fact_buffer VARCHAR2(32767);
        buffer VARCHAR2(32767);
        tablen NUMBER;
        tab dbms_utility.uncl_array;
        owner VARCHAR2(256);
        tblname VARCHAR2(256);
        dummy1 VARCHAR2(256);
        dummy2 VARCHAR2(256);
        pos BINARY_INTEGER;
        i NUMBER;
     BEGIN
        -- normally, assume there is no BASETABLE or SCHEMA filter item
        base_count := 0;
        
        IF filter_id = DBMS_OLAP.FILTER_NONE THEN
          fid := NULL;
        ELSE
          fid := filter_id;
        END IF;       
        
        -- validate fact_table_filter
        IF fact_table_filter IS NOT NULL THEN
           fact_buffer :=  validate_strlist
             (FULL_STRLIST_FORMAT, fact_table_filter, TRUE, FALSE);          
        ELSE
           fact_buffer := NULL;
        END IF;

        -- if not requesting merge
        IF NOT merge_filter THEN
           fact_buffer := NULL;
        END IF;
          
        IF fid IS NOT NULL OR fact_buffer IS NOT NULL  THEN
           -- check validity of the given fid
           cnt := 0;
           IF fid IS NOT NULL THEN
              SELECT COUNT(*) INTO cnt
              FROM system.mview$_adv_filter
              WHERE filterid# = fid;
              IF cnt = 0 THEN
                 log_error(run_id, 30442);
                 dbms_sys_error.raise_system_error(-30442, fid);
              END IF;
                        
              -- check BASETABLE or SCHEMA
              SELECT COUNT(*) INTO cnt
              FROM system.mview$_adv_filter
              WHERE filterid# = fid AND subfiltertype in (7, 11);
              IF cnt >= 2 THEN
                 log_error(run_id, 30467);
                 dbms_sys_error.raise_system_error(-30467, fid);
              END IF; 
           END IF; 
           
           IF cnt =1 OR fact_buffer IS NOT NULL THEN
           BEGIN        
              buffer := NULL;
              IF cnt = 1 THEN
                 SELECT str_value,subfilternum# INTO strfilter, subnum
                 FROM system.mview$_adv_filter
                 WHERE filterid# = fid AND subfiltertype in (7, 11);
    
                 -- convert all * to safe pattern for name parsing
                 pattern := generate_pattern('MV', strfilter);
                 buffer := replace(strfilter, '*', pattern);               
                
                 -- check buffer syntax
                 dbms_utility.comma_to_table(buffer, tablen, tab);
              END IF;

              IF buffer IS NULL THEN
                 buffer := fact_buffer;
              ELSE
                 IF fact_buffer IS NOT NULL THEN
                    buffer := buffer || ',' || fact_buffer;
                 END IF;
              END IF;
              
              IF buffer IS NOT NULL THEN
                 dbms_utility.comma_to_table(buffer, tablen, tab);
                            
                 FOR i IN 1..tablen LOOP
                    -- tokenize and convert name back to normal
                    dbms_utility.name_tokenize(
                      tab(i), owner, tblname, dummy1, dummy2, pos);
                    owner := replace(owner, pattern, '*');
                    tblname := replace(tblname, pattern, '*');
       
                    -- check a.* syntax
                    IF tblname = '*' THEN
                       tblname := '';
                    END IF;
                    base_owner(i) := owner;
                    base_table(i) := tblname;
                 END LOOP;
                 base_count := tablen;
              ELSE
                 base_count := 0;
              END IF;
           EXCEPTION
              WHEN OTHERS THEN
              log_error(run_id, 30443);
              dbms_sys_error.raise_system_error(-30443, fid, subnum);
           END;
           ELSE
              base_count := 0;
           END IF;
        END IF;
     END process_filter;
       
     --------------------------------------------------------------
     -- REMARKS:
     --   setup sessions before workload analysis
     -- INPUT:
     --   none
     -- OUTPUT:
     --   A new unique runid
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     PROCEDURE session_setup
       (
        run_id                 IN NUMBER,
        run_type               IN NUMBER,
        steps                  IN NUMBER,
        filter_id              IN NUMBER,
        collection_id          IN NUMBER,
        fact_table_filter      IN VARCHAR2,
        merge_filter           IN BOOLEAN
       )
     IS
        now DATE;
        maxsub NUMBER;
        cnt NUMBER;
        fid NUMBER;
        cid NUMBER;
     BEGIN
        -- Validate current run
        validate_id (run_id, cnt);
        IF cnt = 0 THEN
           log_error(run_id, 30465);
           dbms_sys_error.raise_system_error(-30465, run_id);
        END IF; 
        
        -- Validate current filter
        IF filter_id = DBMS_OLAP.FILTER_NONE THEN
          fid := NULL;
        ELSE
          fid := filter_id;
        END IF;

        IF collection_id = DBMS_OLAP.WORKLOAD_ALL THEN
          cid := NULL;
        ELSE
          cid := collection_id;
        END IF;
        
        process_filter(run_id, fid, fact_table_filter, merge_filter);

        IF (EVALUATE_W_RUNTYPE = run_type OR
            RECOMMEND_W_RUNTYPE= run_type) THEN
                 
           -- copy filter into filter instance table for non-null filter
           IF fid IS NOT NULL THEN
              INSERT INTO system.mview$_adv_filterinstance (
                 runid#, filterid#, subfilternum#, subfiltertype,
                 str_value, num_value1, num_value2, date_value1, date_value2)
              SELECT run_id,
                 filterid#, subfilternum#, subfiltertype,
                 str_value, num_value1, num_value2, date_value1, date_value2
              FROM system.mview$_adv_filter
              WHERE filterid# = fid;
           END IF;
       
           -- handle collection id
           IF cid IS NOT NULL THEN
              SELECT NVL(max(subfilternum#), 0) INTO maxsub
                 FROM system.mview$_adv_filterinstance
                 WHERE runid# = run_id AND filterid# = fid;
              maxsub := maxsub + 1;
              INSERT INTO system.mview$_adv_filterinstance (
                 runid#, filterid#, subfilternum#, subfiltertype,
                 str_value, num_value1, num_value2, date_value1, date_value2)
              VALUES(
                 run_id, fid, maxsub, COLLECTIONID_FILTER, 
                 NULL, cid, cid, NULL, NULL);
           END IF;

           -- handle NULL/NULL case
           IF fid IS NULL AND cid IS NULL THEN
              INSERT INTO system.mview$_adv_filterinstance (
                 runid#, filterid#, subfilternum#, subfiltertype,
                 str_value, num_value1, num_value2, date_value1, date_value2)
              VALUES(
                 run_id, NULL, NULL, NULL, 
                 NULL, NULL, NULL, NULL, NULL);
           END IF;
        END IF;

        -- prevent literal replacement
        save_cursor_sharing :=
          set_session_val('cursor_sharing', 'EXACT');

        -- ensure maximum rewrite
        save_query_rewrite_integrity :=
          set_session_val('query_rewrite_integrity', 'STALE_TOLERATED');

        -- enable query rewrite
        save_query_rewrite_enabled :=
          set_session_val('query_rewrite_enabled', 'TRUE');

        -- Sets the current session as started.
        set_started (run_id, fid, run_type, steps); 
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
             dbms_sys_error.raise_system_error(-30447, run_id);
           WHEN OTHERS THEN
             RAISE;
     END session_setup;

     --------------------------------------------------------------
     -- REMARKS:
     --   cleanup the session environment after workload analysis
     -- INPUT:
     --   none
     -- OUTPUT:
     --   none
     -- EXCEPTIONS:
     --   none
     --------------------------------------------------------------
     PROCEDURE session_cleanup
       (
        runid           IN NUMBER
       )
     IS
        now DATE;
     BEGIN
        save_cursor_sharing :=
          set_session_val('cursor_sharing', save_cursor_sharing);
        save_query_rewrite_integrity :=
          set_session_val('query_rewrite_integrity',
          save_query_rewrite_integrity);
        save_query_rewrite_enabled :=
          set_session_val('query_rewrite_enabled',
          save_query_rewrite_enabled);

        check_error(runid, CHECKERROR_CONSIDER_WARNINGS);
        
        -- if error occurred, should never come here
        set_completed(runid); 
     END session_cleanup;
          
     --------------------------------------------------------------
     -- REMARKS:
     --   Construct sql clause for filtering based on the string list
     -- INPUT:
     --   strlist     comma seperated list of string tokens
     -- OUTPUT:
     --   return value  constructed filter text
     --
     -- EXCEPTIONS:
     --   INVALID_PARAMETER_EXCEPTION   inherited from prepare_str_list
     --------------------------------------------------------------
     FUNCTION construct_str_filter
       (
        itemname                IN VARCHAR2,
        format                  IN BINARY_INTEGER,
        strlist                 IN VARCHAR2,
        capitalcase             IN BOOLEAN := FALSE
       )
        RETURN VARCHAR2
     IS
        buffer VARCHAR2(32767);
        up VARCHAR(16);
     BEGIN
        -- either the item is NULL, or the item fall into the in-list
        IF capitalcase THEN
           up := ' UPPER ';
        ELSE
           up := '';
        END IF;
        
        buffer := '(' ||
          ' ( '  || itemname || ' IS NULL )' ||
          ' OR ' ||
          ' ( '|| up || '('  || itemname || ') IN ( '||
                validate_strlist(format, strlist, FALSE, TRUE) ||
          ' )) ' || ')';
        RETURN buffer;
     END construct_str_filter;

     --------------------------------------------------------------
     -- REMARKS:
     --   Construct sql clause for filtering based on numerical ranges
     -- INPUT:
     --   itemname      filter item name, must be legal , no check
     --   num1          lower numerical bound
     --   num2          upper numerical bound
     -- OUTPUT:
     --   return value  sql clause
     --
     -- EXCEPTIONS:
     --   INVALID_PARAMETER_EXCEPTION   if num2 is smaller than num1
     --------------------------------------------------------------
     FUNCTION construct_num_filter
       (
        itemname                IN VARCHAR2,
        n1                      IN NUMBER,
        n2                      IN NUMBER
       )
        RETURN VARCHAR2
     IS
        buffer VARCHAR2(32767) := NULL;
        header VARCHAR2(256);
        num1 NUMBER; 
        num2 NUMBER;
     BEGIN
        header := ' ( '  || itemname || ' IS NULL )';
        IF n1 = -999 THEN
           num1 := NULL;
        ELSE
           num1 := n1;
        END IF;
        IF n2 = -999 THEN
           num2 := NULL;
        ELSE
           num2 := n2;
        END IF;

        IF num1 IS NOT NULL THEN
           buffer := ' ( ' || itemname || ' >= ' || num1 || ' ) ';
        END IF;
        IF num2 IS NOT NULL THEN
           IF num1 IS NOT NULL AND num2 < num1 THEN
              RAISE INVALID_PARAMETER_EXCEPTION;
           END IF; 
           IF buffer IS NOT NULL THEN
              buffer := buffer || ' AND ';
           END IF;
           buffer := buffer || 
              ' ( ' || itemname || ' <= ' || num2 || ' ) ';
        END IF;

        -- build the where clause
        IF buffer IS NOT NULL THEN
           RETURN ' ( ' || header || ' OR (' || buffer || ' )) ';
        ELSE
           RETURN header;
        END IF;
     END construct_num_filter;

     --------------------------------------------------------------
     -- REMARKS:
     --   Construct the sql clause for filtering based on date ranges
     -- INPUT:
     --   itemname      filter item name, must be legal , no check
     --   date1          lower date bound
     --   date2          upper date bound
     -- OUTPUT:
     --   return value  partial where-clause
     --
     -- EXCEPTIONS:
     --   INVALID_PARAMETER_EXCEPTION   if date2 is smaller than date1
     --------------------------------------------------------------
     FUNCTION construct_date_filter
       (
        itemname                IN VARCHAR2,
        date1                   IN DATE,
        date2                   IN DATE
       )
        RETURN VARCHAR2
     IS
        buffer VARCHAR2(32767) := NULL;
        header VARCHAR2(256);
     BEGIN
        header := ' ( '  || itemname || ' IS NULL )';
        IF date1 IS NOT NULL THEN
           buffer := ' ( ' || itemname || ' >= ' || 
              QUOTE || date1 || QUOTE || ' ) ';
        END IF;
        IF date2 IS NOT NULL THEN
           IF date1 IS NOT NULL AND date2 < date1 THEN
              RAISE INVALID_PARAMETER_EXCEPTION;
           END IF; 
           IF buffer IS NOT NULL THEN
              buffer := buffer || ' AND ';
           END IF;
           buffer := buffer || ' ( ' || itemname || ' <= ' || 
              QUOTE || date2 || QUOTE || ' ) ';
        END IF;

        -- build the where clause
        IF buffer IS NOT NULL THEN
           RETURN ' ( ' || header || ' OR (' || buffer || ' )) ';
        ELSE
           RETURN header;
        END IF;
     END construct_date_filter;

     --------------------------------------------------------------
     -- REMARKS:
     --   Construct a filter based on basetables such that a query
     --   is chosen if any of the base tables it references is contained
     --   in the provided fact table list.
     -- INPUT:
     --   strlist       a string
     -- OUTPUT:
     --   return value  constructured partial where-clause
     -- EXCEPTIONS:
     --    many exceptions are possible during parsing of names
     --------------------------------------------------------------
     FUNCTION construct_facttable_filter
       (
        strlist                 IN VARCHAR2
       )
        RETURN VARCHAR2
     IS
        tablen BINARY_INTEGER;
        ownertab dbms_utility.uncl_array;
        tblnametab dbms_utility.uncl_array;
        buffer VARCHAR2(32767);
        dummy VARCHAR2(32767);
     BEGIN
        -- retrieve owners and corresponding table names
        dummy := validate_strlist(
          FULL_STRLIST_FORMAT, strlist, FALSE, FALSE,
          tablen, ownertab, tblnametab);

        buffer := ' ( EXISTS ' ||
          ' (SELECT * FROM system.mview$_adv_basetable T ' ||
          '  WHERE T.queryid# = system.mview$_adv_workload.queryid# ' ||
          '  AND T.collectionid# = system.mview$_adv_workload.collectionid#' ||
          '  AND ( ';

        -- check if owner.table_name is in the user-specified list
        FOR i IN 1..tablen LOOP
           buffer := buffer || ' ( ' ||
           ' T.owner = ' || QUOTE || ownertab(i) || QUOTE || ' AND ' ||
           ' T.table_name = ' || QUOTE || tblnametab(i) || QUOTE || ' ) ';
        IF i < tablen THEN
              buffer := buffer || ' OR ';
           END IF;
        END LOOP;

        buffer := buffer || ' ))) ';
        RETURN buffer;
     END construct_facttable_filter;

     --------------------------------------------------------------
     -- REMARKS:
     --   Return first value of first row
     -- INPUT:
     --   stmt          sql statement
     -- OUTPUT:
     --   return value  first column value of first fetched row
     --------------------------------------------------------------     
     FUNCTION get_firstvalue
       (
        stmt                    IN VARCHAR2
       )
        RETURN NUMBER
     IS
        result NUMBER;
        rows NUMBER;
        cur NUMBER;
     BEGIN
        cur := dbms_sql.open_cursor;
        dbms_sql.parse(cur, stmt, dbms_sql.native);
        dbms_sql.define_column(cur, 1, result);
        rows := dbms_sql.execute(cur);
        IF dbms_sql.fetch_rows(cur) > 0 THEN
           dbms_sql.column_value(cur, 1, result);
        ELSE
           result := 0;
        END IF;
        dbms_sql.close_cursor(cur);       
        RETURN result;
     EXCEPTION
        WHEN OTHERS THEN
          RETURN 0;
     END get_firstvalue;
     
     --------------------------------------------------------------
     -- REMARKS:
     --   Generate sql statements based on workload filter id
     -- INPUT:
     --   filter_id     id that uniquely identifies a filter
     -- OUTPUT:
     --   return value  constructured sql string
     --
     -- EXCEPTIONS:
     --   ORA-30442     filter not found
     --   ORA-30443     filter definition invalid
     --------------------------------------------------------------
     FUNCTION generate_filter_sql
       (
        run_id                  IN NUMBER,
        facttable_filter        IN VARCHAR2
       )
        RETURN VARCHAR2
     IS
        CURSOR  filter_cur(runid NUMBER)
          RETURN system.mview$_adv_filterinstance%ROWTYPE IS
          SELECT *
            FROM system.mview$_adv_filterinstance t1
            WHERE t1.runid# = runid AND subfiltertype NOT IN (7,11);

        -- filter item
        filteritem system.mview$_adv_filterinstance%ROWTYPE;

        -- filte item type
        filtertype system.mview$_adv_filterinstance.subfiltertype%TYPE;

        -- filter item counter
        counter BINARY_INTEGER :=0;

        -- buffer for validated facttable_filter
        facttable_buffer VARCHAR2(32767);

        -- flag indicating validating facttable_filter
        validating_filter BOOLEAN := FALSE;

        -- buffer for construncting SQL statement
        buffer VARCHAR2(32767) :=
          'FROM system.mview$_adv_workload';

     BEGIN
        OPEN filter_cur(run_id);
        LOOP
           FETCH filter_cur INTO filteritem;
           EXIT WHEN filter_cur%NOTFOUND;

           -- assemble one condition
           counter  := counter +1;
           filtertype := filteritem.subfiltertype;
           IF filtertype IS NULL THEN
              IF counter = 1 THEN
                 return buffer; 
              ELSE
                 dbms_sys_error.raise_system_error(-30447, run_id);
              END IF;
           END IF;

           IF counter > 1 THEN
              buffer := buffer || ' AND ';
           ELSE
              buffer := buffer || ' WHERE ';
           END IF;
           IF filtertype = APPLICATION_FILTER THEN
              buffer := buffer
                || construct_str_filter('APPLICATION',
                COMMA_STRLIST_FORMAT, filteritem.str_value, TRUE);
           ELSIF filtertype = CARDINALITY_FILTER THEN
              buffer := buffer
                || construct_num_filter('CARDINALITY',
                filteritem.num_value1, filteritem.num_value2);
           ELSIF filtertype = LASTUSE_FILTER THEN
              buffer := buffer
                || construct_date_filter('QDATE',
                filteritem.date_value1, filteritem.date_value2);
           ELSIF filtertype = FREQUENCE_FILTER THEN
              buffer := buffer
                || construct_num_filter('FREQUENCY',
                filteritem.num_value1, filteritem.num_value2);
           ELSIF filtertype = OWNER_FILTER THEN
              buffer := buffer
                || construct_str_filter('UNAME',
                PARTIAL_STRLIST_FORMAT, filteritem.str_value, FALSE);
           ELSIF filtertype = PRIORITY_FILTER THEN
              buffer := buffer
                || construct_num_filter('PRIORITY',
                filteritem.num_value1, filteritem.num_value2);
           ELSIF filtertype = RESPONSETIME_FILTER THEN
              buffer := buffer
                || construct_num_filter('EXEC_TIME',
                filteritem.num_value1, filteritem.num_value2);
           ELSIF filtertype = COLLECTIONID_FILTER THEN
              buffer := buffer
                || construct_num_filter('COLLECTIONID#',
                filteritem.num_value1, filteritem.num_value2);
           END IF;
        END LOOP;

        -- return correct answer
        RETURN buffer;

     EXCEPTION
        WHEN OTHERS THEN
          IF validating_filter THEN
             log_error(run_id, 30449);
             dbms_sys_error.raise_system_error(-30449, 1);
          ELSE
             log_error(run_id, 30443);
             dbms_sys_error.raise_system_error(-30443,
               filteritem.filterid#, filteritem.subfilternum#);
          END IF;
     END generate_filter_sql;

     
     PROCEDURE create_output_table
       (
        tbl     IN NUMBER
       )
     IS
        -- variables declaration
        cmdbuf VARCHAR2(32767);
        outtbl VARCHAR2(1024); 
        tblnum INTEGER;
     BEGIN     
        -- figure out table name
        IF  tbl = RECOMMENDATION_TABLE THEN
           outtbl := 'MVIEW$_RECOMMENDATIONS';
        ELSE
           outtbl := 'MVIEW$_EVALUATIONS';
        END IF;
        
        -- Create the table only if the table is not already there.       
        SELECT count(*) INTO tblnum
          FROM sys.obj$ o, sys.user$ u
          WHERE o.name = outtbl
          AND o.owner# = u.user# 
          AND u.name = user;
        
        -- drop the table first if the table is already there
        IF tblnum > 0 THEN
           cmdbuf := 'DROP TABLE '|| user || '.' || outtbl;
           execute_sql(cmdbuf);
        END IF;
           
        -- now create the table   
        cmdbuf := 'CREATE TABLE ' || user || '.' || outtbl;    
        IF tbl = RECOMMENDATION_TABLE THEN
           cmdbuf := cmdbuf || '( '               
             || 'recommendation_number integer primary key,' 
             || 'recommended_action varchar2(6),' 
             || 'summary_owner varchar(30),' 
             || 'summary_name varchar(30),' 
             || 'group_by_columns   varchar2(2000),'
             || 'where_clause varchar2(2000),' 
             || 'from_clause varchar2(2000),' 
             || 'measures_list varchar2(2000),'
             || 'storage_in_bytes number,'
             || 'pct_performance_gain number,' 
             || 'benefit_to_cost_ratio number'                 
             || ')';                    
        ELSE
           cmdbuf := cmdbuf || '('
             || 'summary_owner varchar(30),' 
             || 'summary_name varchar(30),' 
             || 'rank integer,' 
             || 'storage_in_bytes number,' 
             || 'frequency number,' 
             || 'cumulative_benefit number,' 
             || 'benefit_to_cost_ratio number '
             || ')';              
        END IF;               
        execute_sql(cmdbuf);
     END create_output_table;
     
     
     --------------------------------------------------------------
     -- PUBLIC METHODS
     -- please see prvtsum.sql for interface specification
     --------------------------------------------------------------     
     PROCEDURE check_error
       (
        id             IN NUMBER,
        warnings_flag  IN NUMBER
       )
       AS language java
       name 'oracle.qsma.QsmaDataManager.checkError(int,int)';

     
     PROCEDURE record_jnl_entry
       (
       runid IN NUMBER,
       flags IN NUMBER,
       num IN NUMBER,
       msgid IN VARCHAR2, 
       s1 IN VARCHAR2,
       s2 IN VARCHAR2,
       s3 IN VARCHAR2, 
       s4 IN VARCHAR2, 
       s5 IN VARCHAR2, 
       s6 IN VARCHAR2, 
       n1 IN NUMBER,
       n2 IN NUMBER, 
       n3 IN NUMBER
       )
       AS language java
       name 'oracle.qsma.QsmaDataManager.recordJournal
       (int,int, int, 
       java.lang.String,  java.lang.String,  java.lang.String,  java.lang.String, 
       java.lang.String, java.lang.String,  java.lang.String,
       oracle.sql.NUMBER, oracle.sql.NUMBER, oracle.sql.NUMBER)';

     
     PROCEDURE validate_repository
       AS language java
       name 'oracle.qsma.QsmaDataManager.validateRepository()';

     PROCEDURE set_status
       (
        id             IN NUMBER,
        status         IN NUMBER
       )
       AS language java
       name 'oracle.qsma.QsmaDataManager.setStatus(int,int)';


     PROCEDURE set_cancelled
       (
        runid          IN NUMBER
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.setCancelled(int)';

     PROCEDURE add_filter_item
       (
        filterid       IN NUMBER,
        filter_name    IN VARCHAR2,
        string_list    IN VARCHAR2,
        num_min        IN NUMBER,
        num_max        IN NUMBER,
        date_min       IN VARCHAR2,
        date_max       IN VARCHAR2
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.addFilterItem
       (int, java.lang.String, java.lang.String, 
       oracle.sql.NUMBER, oracle.sql.NUMBER,
       java.lang.String,java.lang.String)';

     PROCEDURE delete_filter_item
       (
        filterid       IN NUMBER,
        filter_name    IN VARCHAR2
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.deleteFilterItem(int, 
                                                          java.lang.String)';

     PROCEDURE purge_filter
       (
        filterid       IN NUMBER
       )
       as language java
        name 'oracle.qsma.QsmaDataManager.purgeFilter(oracle.sql.NUMBER)';

     PROCEDURE create_id
       (
        id         OUT NUMBER
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.createHandle(int[])';
     
     PROCEDURE load_workload_trace
       (
        workloadid        IN NUMBER,
        flags             IN NUMBER,
        filterid          IN NUMBER,
        application       IN VARCHAR2,
        priority          IN NUMBER,
        owner             IN VARCHAR2
       )
       as language java       
       name 'oracle.qsma.QsmaDataManager.loadWorkloadTrace
       (int, int, int, java.lang.String,
        int, java.lang.String)';

     PROCEDURE load_workload_user
       (
        workloadid        IN NUMBER,
        flags             IN NUMBER,
        filterid          IN NUMBER,
        owner             IN VARCHAR2,
        workloadtable     IN VARCHAR2
       )
       as language java       
       name 'oracle.qsma.QsmaDataManager.loadWorkloadUser
       (int, int, int, java.lang.String, java.lang.String)';

     PROCEDURE load_workload_cache
       (
        workloadid        IN NUMBER,
        flags             IN NUMBER,
        filterid          IN NUMBER,
        application       IN VARCHAR2,
        priority          IN NUMBER
       )
       as language java       
       name 'oracle.qsma.QsmaDataManager.loadWorkloadCache
       (int, int, int, java.lang.String,int)';

     PROCEDURE validate_workload_trace 
       (
        owner_name               IN VARCHAR2,
        valid                    OUT NUMBER,
        error                    OUT VARCHAR2
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.validateWorkloadTrace
       (java.lang.String, int[], java.lang.String[])'; 


     PROCEDURE validate_workload_user 
       (
        owner_name               IN VARCHAR2,
        table_name               IN VARCHAR2,
        valid                    OUT NUMBER,
        error                    OUT VARCHAR2
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.validateWorkloadUser
       (java.lang.String, java.lang.String, int[], java.lang.String[])'; 


     PROCEDURE validate_workload_cache
       (
        valid                    OUT NUMBER,
        error                    OUT VARCHAR2
       )
       as language java
       name 'oracle.qsma.QsmaDataManager.validateWorkloadCache
       (int[], java.lang.String[])'; 


     PROCEDURE generate_mview_report (filename   in varchar2,
                                      id         in number,
                                      flags      in number)
        as language java
        name 'oracle.qsma.QsmaDataManager.detailReport(java.lang.String,
                                                       int,int)';

     PROCEDURE generate_mview_script (filename   in varchar2,
                                      id         in number,
                                      tspace     in VARCHAR2)
        as language java
        name 'oracle.qsma.QsmaDataManager.generateScript(java.lang.String,
                                                         int,
                                                         java.lang.String)';

     FUNCTION get_property (name VARCHAR2) 
     RETURN VARCHAR2
        as language java
        NAME 'oracle.qsma.QsmaDataManager.getProperty(java.lang.String)
             return java.lang.String';

     PROCEDURE set_property (name varchar2, value varchar2)
        as language java
        NAME 'oracle.qsma.QsmaDataManager.setProperty(java.lang.String,java.lang.String)';

     PROCEDURE show_properties
        as language java
        NAME 'oracle.qsma.QsmaDataManager.showProperties()';


     PROCEDURE purge_workload
        (
         workloadid            IN NUMBER
        )
        as language java
        name 'oracle.qsma.QsmaDataManager.purgeWorkload(oracle.sql.NUMBER)';
     
     PROCEDURE purge_results
        (
         runid      IN NUMBER
        )
        as language java
        name 'oracle.qsma.QsmaDataManager.purgeResults(oracle.sql.NUMBER)';
                             
     PROCEDURE pretty_print
        (
         id           IN NUMBER,
         text         IN VARCHAR2,
         lm           IN NUMBER,
         rm           IN NUMBER,
         flags        IN NUMBER
        )
        as language java
        name 'oracle.qsma.QsmaDataManager.prettyPrint(int,
       java.lang.String,
       int,int,int)';
        
     PROCEDURE analyze_sql_test
       (
        runid                   IN BINARY_INTEGER,
        filterid                IN BINARY_INTEGER,
        flag                    IN BINARY_INTEGER,
        lostep                  IN BINARY_INTEGER,
        histep                  IN BINARY_INTEGER
       )
     IS 
        counter BINARY_INTEGER;
        buffer VARCHAR2(32767);
     BEGIN
        INSERT INTO system.mview$_adv_log(runid#, uname, status)
          VALUES(runid, user, UNUSED_STATUS);
        commit;
        session_setup(runid, flag, histep - lostep + 1, filterid, NULL, NULL,
           TRUE);
        buffer := dbms_sumadvisor.generate_filter_sql(runid, NULL);
        counter := get_firstvalue(HEADER_COUNT || buffer);
        analyze_sql(runid, counter, ANALYZESQL_CLASSIFY + ANALYZESQL_EVALUATE,
          HEADER_STMT || buffer, user, base_owner, base_table,
          0, lostep, histep);
        session_cleanup(runid);
        commit;
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
              dbms_sys_error.raise_system_error(-30447, runid);
     END analyze_sql_test;
     
     PROCEDURE verify_dimension
       (
        dimension_name          IN VARCHAR2,
        dimension_owner         IN VARCHAR2,
        incremental             IN BOOLEAN ,
        check_nulls             IN BOOLEAN ,
        runid                   IN NUMBER,
        use_repository          IN BOOLEAN := true,
        stmt_id                 IN VARCHAR2 := NULL 
       )
     IS
     BEGIN
        -- get current runid
        IF runid > 0 THEN
           session_setup(runid, VALIDATE_RUNTYPE, VALIDATE_STEPS, NULL, 
             NULL, NULL, TRUE);
        END IF; 

        -- verify dimension
        dbms_sumvdm.verify_dimension
          (
          dimension_name,
          dimension_owner,
          incremental,
          check_nulls,
          runid,
          use_repository,
          stmt_id
          );

        IF runid > 0 THEN
          session_cleanup(runid);
        END IF;
     END verify_dimension;

     PROCEDURE recommend_summaries_w
       (
        user_name               IN VARCHAR2,
        fact_table_filter       IN VARCHAR2,
        storage_in_bytes        IN NUMBER,
        retention_list          IN VARCHAR2,
        retention_pct           IN NUMBER := 80,
        filterid                IN NUMBER := NULL,
        workloadid              IN NUMBER := NULL,
        runid                   IN NUMBER,
        use_repository          IN BOOLEAN := TRUE
       )
     IS
        buffer VARCHAR2(32267);
        nextstep BINARY_INTEGER;
        counter BINARY_INTEGER;
        compat_81_flag BINARY_INTEGER;
        sbytes NUMBER;
        cid NUMBER;
        cnt NUMBER;
     BEGIN
        IF workloadid = DBMS_OLAP.WORKLOAD_ALL THEN
          cid := NULL;
        ELSE
          cid := workloadid;
        END IF;

        -- Validate collection id
        IF cid IS NOT NULL THEN
          SELECT COUNT(*) INTO cnt
          FROM system.mview$_adv_workload
          WHERE collectionid# = cid;
          IF cnt = 0 THEN
             log_error(runid, 30466);
             dbms_sys_error.raise_system_error(-30466, cid);
          END IF; 
        END IF;        
        
        IF use_repository THEN
           compat_81_flag := 0;
        ELSE
           compat_81_flag := 1;
        END IF;
        
        -- generate a filter by id
        buffer := dbms_sumadvisor.generate_filter_sql(runid,
          fact_table_filter);
        
        -- get the count information
        counter := get_firstvalue(HEADER_COUNT || buffer);
        
        -- analze the filtered workload
        nextstep :=1;
        analyze_sql(
          runid, counter, ANALYZESQL_CLASSIFY + ANALYZESQL_EVALUATE,
          HEADER_STMT || buffer, user_name, 
          base_owner, base_table, base_count,
          nextstep, nextstep + RECOMMEND_W_ANALYZE -1);
        nextstep := nextstep + RECOMMEND_W_ANALYZE;
        COMMIT;
  
        IF storage_in_bytes IS NULL or storage_in_bytes < 0 THEN
           sbytes := 1.0E+20;
        ELSE
           sbytes := storage_in_bytes;
        END IF; 

        -- call advisor engine code here
        dbms_sumadv.recommend_summaries_w(
          user_name,  sbytes,
          retention_list, retention_pct, 
          nextstep, nextstep + RECOMMEND_W_EXTERNAL -1, compat_81_flag, runid);
        
        nextstep := nextstep + RECOMMEND_W_EXTERNAL;
        COMMIT;
      
        -- disable: validate the recommendations
        -- counter := get_firstvalue(HEADER_COUNT || 
        --  'FROM system.mview$_adv_output where runid = ' || runid);
        -- analyze_sql(
        --   runid, counter, ANALYZESQL_VALIDATE, NULL, user_name,
        --   nextstep, nextstep + RECOMMEND_W_VALIDATE -1);
                
        -- move things around 
        IF NOT use_repository THEN
           -- create table first
           create_output_table(RECOMMENDATION_TABLE);
           
           -- make the copy
           buffer := 
             'INSERT INTO ' || user_name || '.' || 'mview$_recommendations (' 
             || 'recommendation_number, recommended_action,'
             || 'summary_owner, summary_name, group_by_columns, where_clause,'
             || 'from_clause, measures_list, storage_in_bytes,'
             || 'pct_performance_gain, benefit_to_cost_ratio'
             || ') SELECT '             
             || 'rank#, action_type, '
             || 'summary_owner, summary_name, group_by_columns, where_clause, '
             || 'from_clause, measures_list, storage_in_bytes,'
             || 'pct_performance_gain, benefit_to_cost_ratio '
             || 'FROM system.mview$_adv_output '
             || 'WHERE runid# = ' ||  runid;
           execute_sql(buffer);
           
           -- purge current result
           -- purge_results(runid);
        END IF;
        COMMIT;
     END recommend_summaries_w;
     
     PROCEDURE recommend_summaries
       (
        user_name               IN VARCHAR2,
        fact_table_filter       IN VARCHAR2,
        storage_in_bytes        IN NUMBER,
        retention_list          IN VARCHAR2,
        retention_pct           IN NUMBER ,
        run_id                  IN NUMBER,
        filter_id               IN NUMBER,  
        use_repository          IN BOOLEAN := TRUE
       )
     IS
        flag BINARY_INTEGER;
        wkld NUMBER := NULL;
        cnt NUMBER;
     BEGIN        
        -- Validate current run
        validate_id (run_id, cnt);
        IF cnt = 0 THEN
           log_error(run_id, 30465);
           dbms_sys_error.raise_system_error(-30465, run_id);
        END IF;

        -- get the hypothetical workload id
        create_id(wkld);
        
        -- generate current runid session
        session_setup(run_id, RECOMMEND_W_RUNTYPE, RECOMMEND_W_STEPS, 
          filter_id, wkld, fact_table_filter, FALSE);
        
        -- generate the mview$_adv_info units before hyp workload
        analyze_sql(run_id, 0, ANALYZESQL_INFO, NULL,user_name, 
          base_owner, base_table, base_count,
          1, 2);        
        
        -- generate hypothetical workload
        dbms_sumadv.gen_hyp_wkd(
          user_name, fact_table_filter, storage_in_bytes, wkld, run_id, 0, 0);

        -- set run type for runid, not wkld, which is an internal id
        --UPDATE system.mview$_adv_log
        --SET run_type = 6
        --WHERE runid# = run_id;
        check_error(run_id, CHECKERROR_IGNORE_WARNINGS);
        
        -- remove the information units first
        DELETE FROM system.mview$_adv_info
          WHERE runid# = run_id;        
        
        -- USE the merged filter
        process_filter(run_id, filter_id, fact_table_filter, TRUE);
         
        -- recommend with hypothetical workload
        recommend_summaries_w(
             user_name, fact_table_filter, storage_in_bytes,
             retention_list, retention_pct, NULL, wkld, 
             run_id, use_repository);
 
        -- clean up hypothetical workload
        purge_workload(wkld);
        
     EXCEPTION
        WHEN OTHERS THEN
           IF wkld IS NOT null THEN
             purge_workload(wkld);         
           END IF;
           RAISE;
     END recommend_summaries;
          
     PROCEDURE evaluate_utilization_w
       (
        user_name               IN VARCHAR2,
        filterid                IN NUMBER := NULL,
        workloadid              IN NUMBER := NULL,
        runid                   IN NUMBER,
        use_repository          IN BOOLEAN := TRUE
       )
     IS
        buffer VARCHAR2(32267);
        nextstep BINARY_INTEGER;
        counter BINARY_INTEGER;
        compat_81_flag BINARY_INTEGER;
        cid NUMBER;
        cnt NUMBER;
     BEGIN        
        IF workloadid = DBMS_OLAP.WORKLOAD_ALL THEN
          cid := NULL;
        ELSE
          cid := workloadid;
        END IF;

        -- Validate collection id
        IF cid IS NOT NULL THEN
          SELECT COUNT(*) INTO cnt
          FROM system.mview$_adv_workload
          WHERE collectionid# = cid;
          IF cnt = 0 THEN
             log_error(runid, 30466);
             dbms_sys_error.raise_system_error(-30466, cid);
          END IF; 
        END IF;   
        
        IF use_repository THEN
           compat_81_flag := 0;
        ELSE
           compat_81_flag := 1;
        END IF;
        
        -- generate a filter by id
        buffer := dbms_sumadvisor.generate_filter_sql(runid, NULL);
        counter := get_firstvalue(HEADER_COUNT || buffer);

        -- evaluate only
        nextstep := 1;
        analyze_sql(runid, counter, 
          ANALYZESQL_EVALUATE, HEADER_STMT || buffer, user_name,
          base_owner, base_table, base_count,
          nextstep, nextstep + EVALUATE_W_KERNEL -1);
        nextstep := nextstep + EVALUATE_W_KERNEL;
        
        -- call advisor engine to generate output
        dbms_sumadv.evaluate_utilization_w(
          user_name, nextstep, nextstep + EVALUATE_W_EXTERNAL -1,
          compat_81_flag, runid);
        
        -- move things around 
        IF NOT use_repository THEN
           -- create table first
           create_output_table(EVALUATION_TABLE);
           
           -- make the copy
           buffer := 
             'INSERT INTO ' || user_name || '.' || 'mview$_evaluations (' 
             || 'summary_owner, summary_name, rank, storage_in_bytes, '
             || 'frequency, cumulative_benefit, benefit_to_cost_ratio '
             || ') SELECT '             
             || 'summary_owner, summary_name, rank#, storage_in_bytes, '
             || 'frequency, cumulative_benefit, benefit_to_cost_ratio '
             || 'FROM system.mview$_adv_output '
             || 'WHERE runid# = ' ||  runid;
           execute_sql(buffer);
           
           -- purge current result
           -- purge_results(runid);
        END IF;
        COMMIT;
     END evaluate_utilization_w;
     
     PROCEDURE evaluate_utilization
       (
        user_name               IN VARCHAR2,
        run_id                  IN NUMBER,
        filter_id               IN NUMBER,  
        use_repository          IN BOOLEAN := TRUE
       )
     IS
        flag BINARY_INTEGER;
        wkld NUMBER := NULL;
        cnt NUMBER;
     BEGIN        
        -- Validate current run
        validate_id (run_id, cnt);
        IF cnt = 0 THEN
           log_error(run_id, 30465);
           dbms_sys_error.raise_system_error(-30465, run_id);
        END IF;

        -- get the hypothetical workload id
        create_id(wkld);
        
        -- generate current runid session
        session_setup(run_id, EVALUATE_W_RUNTYPE, EVALUATE_W_STEPS, 
          filter_id, wkld, NULL, TRUE);        
         
        -- generate the hypotetical workload
        dbms_sumadv.gen_hyp_wkd(
          user_name, NULL, NULL, wkld, run_id, 0, 0);
        
        -- generate the mview$_adv_info units before hyp workload
        analyze_sql(run_id, 0, ANALYZESQL_INFO, NULL, user_name,
          base_owner, base_table, base_count,
          1, 2);
        
        -- set the correct run TYPE FOR runid, NOT wkld, which IS an internal id
        --UPDATE system.mview$_adv_log
        --SET run_type = 6
        --WHERE runid# = run_id;
        check_error(run_id, CHECKERROR_IGNORE_WARNINGS);
        
        -- remove the information units first
        DELETE FROM system.mview$_adv_info
          WHERE runid# = run_id;
        
        -- recommend with hypothetical workload
        evaluate_utilization_w(
           user_name, NULL, wkld, run_id, use_repository);
 
        -- clean up hypothetical workload
        purge_workload(wkld);
        
     -- still clean up in case exceptions
     EXCEPTION
        WHEN OTHERS THEN
           IF wkld IS NOT null THEN
             purge_workload(wkld); 
           END IF;
           RAISE;
     END evaluate_utilization;
     
     PROCEDURE recommend_mview_strategy
      (
       run_id                  IN NUMBER,
       workload_id             IN NUMBER,
       filter_id               IN NUMBER,
       storage_in_bytes        IN NUMBER,
       retention_pct           IN NUMBER,
       retention_list          IN VARCHAR2,
       fact_table_filter       IN VARCHAR2,
       use_repository          IN BOOLEAN
      )
     IS
     BEGIN
        IF workload_id IS NULL OR workload_id = dbms_olap.workload_none THEN
           -- delayed session setup
           recommend_summaries(user,
             fact_table_filter,
             storage_in_bytes,
             retention_list,
             retention_pct,
             run_id,
             filter_id,
             use_repository);
        ELSE
           -- generate current runid
           session_setup(run_id, RECOMMEND_W_RUNTYPE, RECOMMEND_W_STEPS, 
             filter_id, workload_id, fact_table_filter, TRUE);
           
           recommend_summaries_w(user,
             fact_table_filter,
             storage_in_bytes,
             retention_list,
             retention_pct,
             filter_id,
             workload_id,
             run_id,
             use_repository);                             
        END IF;
        
        -- cleanup
        session_cleanup(run_id);
     END recommend_mview_strategy;     
     
     PROCEDURE evaluate_mview_strategy
     (
      run_id                  IN NUMBER,
      workload_id             IN NUMBER,
      filter_id               IN NUMBER,
      use_repository          IN BOOLEAN 
     )
     IS
     BEGIN
        IF workload_id IS NULL OR workload_id = DBMS_OLAP.WORKLOAD_NONE THEN
           -- delayed setup
           evaluate_utilization(user, run_id, filter_id, use_repository);
        ELSE 
           IF workload_id < 0 AND workload_id <> DBMS_OLAP.WORKLOAD_ALL THEN
              dbms_sys_error.raise_system_error(-30466,workload_id);
           ELSE
              -- generate current runid
              session_setup(run_id, EVALUATE_W_RUNTYPE, EVALUATE_W_STEPS, 
                filter_id, workload_id, NULL, TRUE);             
              evaluate_utilization_w(user, filter_id, 
                workload_id, run_id, use_repository);
           END IF;
        END IF;                      
        
        -- clean up
        session_cleanup(run_id);
     END evaluate_mview_strategy;        
     
     PROCEDURE estimate_summary_size
       (
        stmt_id         IN VARCHAR2,
        select_clause   IN VARCHAR2,
        num_rows        OUT NUMBER,
        num_bytes       OUT NUMBER
       )
     IS
        cmdbuf varchar2 (32767);
        cid integer;
        ret number;
        userid number;
        num_bytes_in_row number;
        col_cnt integer;
        rec_tab dbms_sql.desc_tab;
        col_num number;
        num_rows_lv number; -- num_rows (local-variable)
        err_msg_code integer := 0;

        -- The function below is taken from the Application Developer Guide
        -- illustrating the use of the dbms_sql.describe_columns() procedure.
        -- This function is not invoked in the code, it is just kept for
        -- reference.
        PROCEDURE print_rec
          (
           rec IN dbms_sql.desc_rec
          )
        IS
        BEGIN
           -- The dbms_output calls don't work for some reason
           dbms_output.new_line;
           dbms_output.put_line('col_type            =    '
             || rec.col_type);
           dbms_output.put_line('col_maxlen          =    '
             || rec.col_max_len);
           dbms_output.put_line('col_name            =    '
             || rec.col_name);
           dbms_output.put_line('col_name_len        =    '
             || rec.col_name_len);
           dbms_output.put_line('col_schema_name     =    '
             || rec.col_schema_name);
           dbms_output.put_line('col_schema_name_len =    '
             || rec.col_schema_name_len);
           dbms_output.put_line('col_precision       =    '
             || rec.col_precision);
           dbms_output.put_line('col_scale           =    '
             || rec.col_scale);
           dbms_output.put('col_null_ok         =    ');
           IF (rec.col_null_ok) THEN
              dbms_output.put_line('true');
           ELSE
              dbms_output.put_line('false');

              -- Trace the column_name and max-length of the column
              dbms_sumref_util.trace('col_name = '|| rec.col_name ||
                ' col_max_len = '|| rec.col_max_len);
           END IF;
        END print_rec;

        --  Start of estimate_summary_size function
        BEGIN
           --  Tell trace we are starting up
           dbms_sumref_util.trace_init(0);

           -- Get the userid of the user who is invoking this procedure
           -- It is needed for the dbms_sys_sql.parse_as_user function
           -- (we need to execute SQL as the user).
           userid := uid();

           -- Open the cursor and parse the input 'select_clause' as user
           err_msg_code := 30477;
           cid := dbms_sql.open_cursor;
           dbms_sys_sql.parse_as_user(cid, select_clause, 0, userid);

           -- IMPORTANT: We do not execute the query submitted by the user as
           -- ret := dbms_sql.execute(cid); like we normally would, that would
           -- defeat the purpose of this function!
           --
           -- Describe the columns of the cursor just parsed.
           dbms_sql.describe_columns(cid, col_cnt, rec_tab);

           -- following loop could simply be for j in 1..col_cnt loop.
           -- here we are simply illustrating some of the pl/sql table
           -- features.
           col_num := rec_tab.first;
           num_bytes_in_row := 0;
           IF (col_num IS NOT NULL) THEN
              LOOP
                 -- print_rec(rec_tab(col_num));
                 num_bytes_in_row := num_bytes_in_row
                   + rec_tab(col_num).col_max_len;
                 col_num := rec_tab.next(col_num);
                 EXIT WHEN (col_num IS NULL);
              END LOOP;
           END IF;

           -- Close the cursor
           dbms_sql.close_cursor(cid);

           -- Trace num_bytes_in_row
           dbms_sumref_util.trace('num_bytes_in_row = ' || num_bytes_in_row);

           -- Delete from the user's PLAN_TABLE all rows with
           -- statement_id = stmt_id.
           err_msg_code := 30476;
           cmdbuf := 'delete from plan_table where statement_id =' || QUOTE ||
             stmt_id || QUOTE;

           -- open a cursor, parse and execute contents of cmdbuf as user
           -- and close the cursor.
           cid := dbms_sql.open_cursor;
           dbms_sumref_util.trace(cmdbuf);
           dbms_sumref_util.trace('parsing the cursor as user '|| userid);
           dbms_sys_sql.parse_as_user(cid, cmdbuf, 0, userid);
           dbms_sumref_util.trace('executing the cursor');
           ret := dbms_sql.execute(cid);
           dbms_sumref_util.trace('closing the cursor');
           dbms_sql.close_cursor(cid);

           --  Clear the err_msg_code. If we fail from this point on,
           --  we don't issue any special error message
           err_msg_code := 0;

           -- Run EXPLAIN on the user's select_clause as the user.
           -- The statement-id is the one provided by the user.
           cmdbuf := 'explain plan set statement_id ='
             || QUOTE || stmt_id || QUOTE
             || ' for ' || select_clause;

           -- open a cursor, parse and execute contents of cmdbuf as user
           -- and close the cursor.
           cid := dbms_sql.open_cursor;
           dbms_sumref_util.trace(cmdbuf);
           dbms_sumref_util.trace('parsing the cursor as user '|| userid);
           dbms_sys_sql.parse_as_user(cid, cmdbuf, 0, userid);
           dbms_sumref_util.trace('executing the cursor');
           ret := dbms_sql.execute(cid);
           dbms_sumref_util.trace('closing the cursor');
           dbms_sql.close_cursor(cid);

           -- Compute num_rows in select_clause by executing the query:
           -- select cardinality into num_rows from plan_table where
           -- statement_id = stmt_id and id = 0;
           dbms_sumref_util.trace('selecting cardinality from plan_table');

           cmdbuf := ' select cardinality from plan_table where ' ||
             'statement_id = ' || QUOTE || stmt_id || QUOTE || ' and id = 0';

           --  Open a cursor, parse and execute contents of cmdbuf as user.
           --  Fetch the rows satisfying the condition, there should be only
           --  row, but we don't check for this condition. Close the cursor.
           --  Note usage of dbms_sql.define_column and  dbms_sql.column_value
           --  to get the cardinality into num_rows_lv.
           cid := dbms_sql.open_cursor;
           dbms_sumref_util.trace(cmdbuf);
           dbms_sumref_util.trace('parsing the cursor as user '|| userid);
           dbms_sys_sql.parse_as_user(cid, cmdbuf, 0, userid);
           dbms_sumref_util.trace('executing the cursor');
           dbms_sql.define_column(cid, 1, num_rows_lv);
           ret := dbms_sql.execute(cid);

           WHILE dbms_sql.fetch_rows(cid) != 0
           LOOP
              dbms_sql.column_value(cid, 1, num_rows_lv);
              dbms_sumref_util.trace('num_rows_lv is '|| num_rows_lv);
           END LOOP;
           dbms_sumref_util.trace('closing the cursor');
           dbms_sql.close_cursor(cid);

           num_rows := num_rows_lv;
           dbms_sumref_util.trace('num_rows = ' || num_rows);

           -- Compute num_bytes as the product of num_bytes_in_row and num_rows
           num_bytes := num_bytes_in_row * num_rows;
           dbms_sumref_util.trace('num_bytes = ' || num_bytes);

           -- Tell trace we are done
           dbms_sumref_util.trace_finish;
        EXCEPTION
           WHEN OTHERS THEN
             dbms_sumref_util.trace(
             'Caught exception and err_msg_code is ' || err_msg_code);
             dbms_sumref_util.trace_finish;
             dbms_output.new_line;
             IF err_msg_code > 0
             THEN
                dbms_sys_error.raise_system_error(-err_msg_code, TRUE);
             END IF;
        END estimate_summary_size;

     PROCEDURE estimate_mview_size
       (
        stmt_id         IN VARCHAR2,
        select_clause   IN VARCHAR2,
        num_rows        OUT NUMBER,
        num_bytes       OUT NUMBER
       )
     IS
        cmdbuf varchar2 (32767);
        cid integer;
        ret number;
        userid number;
        sysuserid NUMBER;
        username VARCHAR2 (128);
        num_bytes_in_row number;
        col_cnt integer;
        rec_tab dbms_sql.desc_tab;
        col_num number;
        num_rows_lv number; -- num_rows (local-variable)
        err_msg_code integer := 0;

        -- Local function to execute a statement on behalf of a user

        PROCEDURE execute_sql_as_user
          (
           cmdbuf                  IN VARCHAR2,
           userid                  IN NUMBER
          )
        IS
           cursor_name INTEGER;
           rows_processed INTEGER;
        BEGIN
           cursor_name := dbms_sql.open_cursor;
           dbms_sys_sql.parse_as_user(cursor_name, cmdbuf, dbms_sql.native, userid);
           rows_processed := dbms_sql.execute(cursor_name);
           dbms_sql.close_cursor(cursor_name);
        EXCEPTION
           WHEN OTHERS THEN
             dbms_sql.close_cursor(cursor_name);
        END execute_sql_as_user;

        --  Start of estimate_mview_size function
        BEGIN
           COMMIT;

           num_rows := -1;
           num_bytes := -1;

           -- Get the userid of the user who is invoking this procedure
           -- It is needed for the dbms_sys_sql.parse_as_user function
           -- (we need to execute SQL as the user).

           userid := UID();
           username := USER();

           -- Fetch the SYSTEM user id ... we need this for grant/revoke

           SELECT USER_id INTO sysuserid
            FROM sys.dba_users
            WHERE username = 'SYSTEM';

           -- Open the cursor and parse the input 'select_clause' as user

           err_msg_code := 30477;
           cid := dbms_sql.open_cursor;
           dbms_sys_sql.parse_as_user(cid, select_clause, 1, userid);

           -- IMPORTANT: We do not execute the query submitted by the user as
           -- ret := dbms_sql.execute(cid); like we normally would, that would
           -- defeat the purpose of this function!
           --
           dbms_sql.describe_columns(cid, col_cnt, rec_tab);

           -- following loop could simply be for j in 1..col_cnt loop.
           -- here we are simply illustrating some of the pl/sql table
           -- features.
           
           col_num := rec_tab.first;
           num_bytes_in_row := 0;
           IF (col_num IS NOT NULL) THEN
              LOOP
                 num_bytes_in_row := num_bytes_in_row
                   + rec_tab(col_num).col_max_len;
                 col_num := rec_tab.next(col_num);
                 EXIT WHEN (col_num IS NULL);
              END LOOP;
           END IF;

           dbms_sql.close_cursor(cid);

           err_msg_code := 30476;

           -- Grant necessary privileges on the plan table

           if username <> 'SYS' then
             cmdbuf := 'grant insert on system.mview$_adv_plan to ' || username;
             execute_sql_as_user(cmdbuf,sysuserid);

             cmdbuf := 'grant select on system.mview$_adv_plan to ' || username;
             execute_sql_as_user(cmdbuf,sysuserid);
           end if;

           -- Delete from the Advisor repository plan table all rows with
           -- statement_id = stmt_id.
           
           DELETE FROM system.mview$_adv_plan WHERE statement_id = stmt_id;

           --  Clear the err_msg_code. If we fail from this point on,
           --  we don't issue any special error message

           err_msg_code := 0;

           -- Run EXPLAIN on the user's select_clause as the user.
           -- The statement-id is the one provided by the user.

           cmdbuf := 'explain plan set statement_id =' ||
                     QUOTE || stmt_id || QUOTE ||
                     ' into system.mview$_adv_plan for ' ||
                     select_clause;

           -- open a cursor, parse and execute contents of cmdbuf as user
           -- and close the cursor.

           cid := dbms_sql.open_cursor;
           dbms_sys_sql.parse_as_user(cid, cmdbuf, 1, userid);
           ret := dbms_sql.execute(cid);
           dbms_sql.close_cursor(cid);

           -- Compute num_rows in select_clause by executing the query:
           -- select cardinality into num_rows from the plan table where
           -- statement_id = stmt_id and id = 0;

           cmdbuf := ' select cardinality from system.mview$_adv_plan where ' ||
                     'statement_id = ' || 
                     QUOTE || stmt_id || QUOTE || 
                     ' and id = 0';

           --  Open a cursor, parse and execute contents of cmdbuf as user.
           --  Fetch the rows satisfying the condition, there should be only
           --  row, but we don't check for this condition. Close the cursor.
           --  Note usage of dbms_sql.define_column and  dbms_sql.column_value
           --  to get the cardinality into num_rows_lv.

           cid := dbms_sql.open_cursor;
           dbms_sys_sql.parse_as_user(cid, cmdbuf, 1, userid);
           dbms_sql.define_column(cid, 1, num_rows_lv);
           ret := dbms_sql.execute(cid);

           WHILE dbms_sql.fetch_rows(cid) != 0
           LOOP
              dbms_sql.column_value(cid, 1, num_rows_lv);
           END LOOP;

           dbms_sql.close_cursor(cid);

           num_rows := num_rows_lv;

           -- Compute num_bytes as the product of num_bytes_in_row and num_rows
           num_bytes := num_bytes_in_row * num_rows;

           ROLLBACK;

           -- Remove all temporary privileges

           cmdbuf := 'revoke all on system.mview$_adv_plan from ' || username;
           execute_sql_as_user(cmdbuf,sysuserid);

        EXCEPTION
           WHEN OTHERS THEN
             ROLLBACK;

             if username <> 'SYS' then
               cmdbuf := 'revoke all on system.mview$_adv_plan from ' || username;
               execute_sql_as_user(cmdbuf,sysuserid);
             end if;

             IF err_msg_code > 0
             THEN
                dbms_sys_error.raise_system_error(-err_msg_code, TRUE);
             END IF;
        END estimate_mview_size;
     
     -- Summary Advisor functions
     PROCEDURE fail_if_amvfeature_is_disabled
     IS
        val  VARCHAR2(30);
        cnt  NUMBER;
     BEGIN
        SELECT VALUE INTO val FROM v$option WHERE parameter = amv_name;
        IF val = 'FALSE'
        THEN
           dbms_sys_error.raise_system_error(-30475, amv_name);
        END IF;
        
        SELECT count(*) INTO cnt
          FROM sys.dba_objects 
          WHERE object_name = 'DBMS_JAVA'
          AND object_type = 'PACKAGE'
          AND owner = 'SYS';
        
        IF (cnt < 1) THEN        
           dbms_sys_error.raise_system_error(-30475, 'Java');
        END IF;
        
        SELECT count(*) INTO cnt
          FROM sys.dba_objects 
          WHERE object_name LIKE '%QsmaDataManager'
          AND object_type = 'JAVA CLASS'
          AND owner = 'SYS';
        
        IF (cnt < 1) THEN
           dbms_sys_error.raise_system_error(-30475, 'Summary Advisor');
        END IF;

        dbms_sumadvisor.validate_repository;
        
     END fail_if_amvfeature_is_disabled;

     
 END dbms_sumadvisor;
/




