Rem
Rem $Header: owainst.sql 14-nov-2005.21:20:26 akatti Exp $
Rem
Rem owainst.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      owainst.sql - OWA pkg installation script
Rem
Rem    DESCRIPTION
Rem      This file is a driver file that installs the OWA packages
Rem      bundled with the database.  If you are directly invoking
Rem      the script you must run this script as SYS.
Rem
Rem      Note: this script also gets used during upgrades.
Rem      If the OWA packages already loaded in the database (if any) 
Rem      are more recent (based on OWA_UTIL.get_version() value), 
Rem      then this script will not reload the shipped OWA packages.
Rem
Rem    NOTES
Rem      This script can automatically install OWA packages in databases 
Rem      version 8.0.x and higher and is normally invoked via owaload.sql
Rem      Here is what the script does
Rem      - For 9.0.x and above, installs owacomm.sql
Rem      - For 8.1.x and above, installs wpiutl.sql and owacomm8i.sql
Rem      - For 8.0.x and above, installs wpiutl.sql and owacomm8.sql
Rem      To install the OWA packages in a 7.x database (not certified,
Rem      but should work), manually install wpiutl7.sql and owacomm7.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akatti      11/14/05 - Bump up version 
Rem    mmuppago    10/03/05 - Bump up the version
Rem    ehlee       04/25/05 - Bump up version
Rem    ehlee       09/02/04 - Bump up version
Rem    dnonkin     09/01/04 - Bump up version
Rem    pkapasi     11/27/03 - Bump up version
Rem    pkapasi     05/29/03 - Fix bugs and bump up version
Rem    ehlee       11/01/02 - Bump up version
Rem    ehlee       10/31/02 - Bump up version
Rem    pkapasi     10/09/02 - Bump up version
Rem    pkapasi     08/07/02 - Bump up version
Rem    ehlee       06/10/02 - Bump up version
Rem    ehlee       12/03/01 - Bump up version
Rem    ehlee       10/15/01 - Bump up version
Rem    pkapasi     09/21/01 - Bump up version
Rem    skwong      08/20/01 - Add owacomm8i.sql for 8i.
Rem    pkapasi     08/02/01 - Remove recompile of owa_util. causes invalidations
Rem    ehlee       07/11/01 - Change version to 3.0.0.0.6
Rem    pkapasi     06/14/01 - Change script to work for all 8.x databases
Rem    pkapasi     06/12/01 - Cleanup logic to figure which file is installed
Rem    pkapasi     06/12/01 - Add logic to install based on database version
Rem    kmuthukk    04/27/01 - version check based OWA pkg install
Rem    kmuthukk    04/27/01 - Created
Rem

variable owa_file_name   varchar2(200);
variable wpi_file_name   varchar2(200);
variable owa_dbg_msg     varchar2(1000);
variable db_version      number;


Rem
Rem always initialize owa_file_name and wpi_file_name to some dummy value.
Rem
begin :owa_file_name := 'dummy_value'; end;
/
begin :wpi_file_name := 'dummy_value'; end;
/

DECLARE
  /*
   * This next line must be updated whenever 
   * OWA_UTIL.owa_version is updated.
   */
  shipped_owa_version    VARCHAR2(80) := '10.1.2.0.4';
  installed_owa_version  VARCHAR2(80);
  new_line               VARCHAR2(4)  := '
';
  install_pkgs           BOOLEAN;
  is_supported_db_ver    boolean;

  -- procedure executes a DDL and ignores errors if any.
  PROCEDURE execute_ddl(ddl_statement VARCHAR2) IS
    ddl_cursor INTEGER;
  BEGIN
    -- try to execute DDL
    ddl_cursor := dbms_sql.open_cursor;

    -- issue the DDL statement
    dbms_sql.parse (ddl_cursor, ddl_statement, dbms_sql.native);
    dbms_sql.close_cursor (ddl_cursor);
  EXCEPTION
    -- ignore exceptions
    when others then
      if (dbms_sql.is_open(ddl_cursor)) then
        dbms_sql.close_cursor(ddl_cursor);
      end if;
  END;

 --
 -- takes a string of the form 'num1.num2.num3.....'
 -- returns "num1" AND updates string to 'num2.num3...'
 --
 FUNCTION get_next_int_and_advance(str IN OUT varchar2)
      RETURN PLS_INTEGER is
  loc pls_integer;
  ans pls_integer;
 BEGIN
  loc := instr(str, '.', 1);
  if (loc > 0) then
   ans := to_number(substr(str, 1, loc - 1));
   str := substr(str, loc + 1, length(str) - loc);
  else
   ans := to_number(str);
   str := '';
  end if;
  return ans;
 END;

 --
 -- Determines the database version and returns a number like 80500, 81700 etc
 --
 FUNCTION get_db_version 
      RETURN NUMBER is
    ans            NUMBER;
    l_version      VARCHAR2(32);
    l_comp_version VARCHAR2(32);
 BEGIN
   -- Get the version of the backend database
   dbms_utility.db_version(l_version, l_comp_version);

   -- Convert string to a number
   ans := 0;
   FOR i in 1..5 LOOP 
     ans := 10 * ans + get_next_int_and_advance(l_version);
   END LOOP;

   RETURN ans;

 END;

  --
  -- If shipped version of OWA packages is higher than the 
  -- pre-installed version of the OWA packages, then
  -- we need to reinstall the OWA packages.
  -- 
  FUNCTION needs_reinstall(shipped_owa_version   IN VARCHAR2,
                           installed_owa_version IN VARCHAR2) 
        RETURN BOOLEAN is

     shp_str VARCHAR2(80) := shipped_owa_version;
     shp_vsn PLS_INTEGER;
     ins_str VARCHAR2(80) := installed_owa_version;
     ins_vsn PLS_INTEGER;

  BEGIN
    --
    -- either OWA pkgs are not already installed (as can happen
    -- with a new DB) or an older version of the pkg is installed
    -- where version numbering was not implemented.
    --
    IF (installed_owa_version is NULL) THEN
      return TRUE;
    END IF;

    -- If version is the same, then we don't install it again to avoid 
    -- recompiling all dependent packages.
    --
    IF (installed_owa_version = shipped_owa_version) THEN
      return FALSE;
    END IF;

    --
    -- Check if shipped version is higher.
    --
    -- The OWA_UTIL version number format is V1.V2.V3.V4.V5.
    -- Lets compare versions by comparing Vi's from left to right.
    --
    FOR i in 1..5 LOOP 

     -- parse "shipped_version" one int at a time, from L to R
     shp_vsn := get_next_int_and_advance(shp_str);

     -- parse "installed_version" one int at a time, from L to R
     ins_vsn := get_next_int_and_advance(ins_str);
 
     IF (shp_vsn > ins_vsn) THEN
       return TRUE;
     END IF;

     IF (shp_vsn < ins_vsn) THEN
       return FALSE;
     END IF;

    END LOOP;

    -- 
    -- Should never come here. Return TRUE in this case as well.
    --
    RETURN TRUE;
  END;

  FUNCTION get_installed_owa_version RETURN VARCHAR2 IS
    owa_version VARCHAR2(80);
    l_cursor    INTEGER;
    l_stmt      VARCHAR2(256);
    l_status    INTEGER;
  BEGIN

    --
    -- Run this block via dynamic SQL and not static SQL
    -- because compilation of this block could fail as OWA_UTIL
    -- might be non-existant. Doing it from dynamic SQL allows
    -- us to catch the compile error as a run-time exception
    -- and proceed.
    --
    l_stmt := 'select OWA_UTIL.get_version from dual';
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
    dbms_sql.define_column( l_cursor, 1, owa_version, 80 );
    l_status := dbms_sql.execute(l_cursor);

    loop
       if dbms_sql.fetch_rows (l_cursor) > 0 then
          dbms_sql.column_value(l_cursor, 1, owa_version);
       else
          exit; 
       end if;
    end loop;
    dbms_sql.close_cursor(l_cursor);

    return owa_version;

  EXCEPTION
    --
    -- Either OWA pkgs have not been preinstalled
    -- Or, they are older set of OWA pkgs which
    -- a.) did not implement the OWA_UTIL.get_version method
    -- b.) resulted in ORA-6571 : ignore it
    -- 
    WHEN OTHERS THEN
     if dbms_sql.is_open(l_cursor) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     return NULL;
  END;

BEGIN

 -- Get the version of OWA packages installed in the database
 installed_owa_version := get_installed_owa_version;

 -- Format a message for display
 IF (installed_owa_version is NULL) THEN
    :owa_dbg_msg := 'No older OWA packages detected or OWA packages too old';
 ELSE
    :owa_dbg_msg := 'Installed OWA version is: ' || installed_owa_version;
 END IF;
 :owa_dbg_msg := :owa_dbg_msg || ';' || new_line ||
                  'Shipped OWA version is  : ' || shipped_owa_version || ';';

 -- Get the version of the backend database
 :db_version := get_db_version;

 -- Check if we have the right DB version
 if (:db_version < 81720) or (:db_version between 90100 and  90109) then
     is_supported_db_ver := false;
 else
     is_supported_db_ver := true;
 end if;

 -- Proceed with the install
 if (is_supported_db_ver) then
     -- Check if we need to install the OWA packages?
     install_pkgs := needs_reinstall(shipped_owa_version, installed_owa_version);

     IF (install_pkgs) THEN

       -- Setup the debug message
       :owa_dbg_msg := :owa_dbg_msg || new_line ||
                   'OWA packages v' || shipped_owa_version ||
                   ' will be installed into your database v' || :db_version;

       IF (:db_version < 90000) THEN
         -- Databases >= 9.x will come preinstalled with wpiutl.sql
         -- Databases < 9.x have our version of wpiutl.sql. Drop them
         execute_ddl ('drop package sys.wpiutl');

         IF (:db_version < 80000) THEN
           -- Dealing with a 7.x or older database
           :wpi_file_name := 'wpiutl7.sql';
           :owa_file_name := 'owacomm7.sql';
         ELSE
           -- Dealing with an 8.x database
           IF (:db_version < 81000) THEN
              -- Dealing with 8.0.x database
              :wpi_file_name := 'wpiutl.sql';
              :owa_file_name := 'owacomm8.sql';
           ELSE
              -- Dealing with an 8.1.x database
              :wpi_file_name := 'wpiutl.sql';
              :owa_file_name := 'owacomm8i.sql';
           END IF;
         END IF;
       ELSE
         -- Dealing with 9.x and above
         :wpi_file_name := 'owadummy.sql';
         :owa_file_name := 'owacomm.sql';
       END IF;

       :owa_dbg_msg := :owa_dbg_msg || new_line || 'Will install ' ||
                   :wpi_file_name || ' and ' || :owa_file_name;

     ELSE
       :wpi_file_name := 'owadummy.sql';
       :owa_file_name := 'owadummy.sql';
       :owa_dbg_msg := :owa_dbg_msg || new_line || 
                   'You already have a newer version of the OWA packages' ||
                   new_line || 'No install is required';
     END IF;

 else
     -- DB version is not right, print message and exit
     :owa_dbg_msg := :owa_dbg_msg || new_line ||
         'To install OWA packages v' || shipped_owa_version ||
         ' database version should be at least 8.1.7.2 or 9.0.1.1, your database is v'
         || :db_version || ', OWA packages will not be installed.';
     :wpi_file_name := 'owadummy.sql';
     :owa_file_name := 'owadummy.sql';
 end if;
END;
/

print :owa_dbg_msg;

COLUMN :wpi_file_name NEW_VALUE wpi_file_var NOPRINT;
SELECT :wpi_file_name FROM DUAL;
COLUMN :owa_file_name NEW_VALUE owa_file_var NOPRINT;
SELECT :owa_file_name FROM DUAL;

alter session set events '10520 trace name context forever, level 10';

@@&wpi_file_var;
@@&owa_file_var;

alter session set events '10520 trace name context off';


