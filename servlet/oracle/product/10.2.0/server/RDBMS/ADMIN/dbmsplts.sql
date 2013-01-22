Rem
Rem $Header: dbmsplts.sql 04-jun-2004.02:18:32 bkhaladk Exp $
Rem
Rem dbmsplts.sql
Rem
Rem Copyright (c) 1998, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsplts.sql - Pluggable Tablespace Package Specification
Rem
Rem    DESCRIPTION
Rem      This package contains procedures and functions supporting
Rem      the Pluggable Tablespace feature.  They are mostly called
Rem      by import/export.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ahwang      05/18/04 - external db char set check 
Rem    jgalanes    05/11/04 - Add new fixup proc for 3573604 BITMAP index 
Rem                           version lost on TTS transport 
Rem    wfisher     05/05/04 - Remap tsnames and control closure checking 
Rem    ahwang      03/19/04 - bug 3551627 - allow more multibyte char sets
Rem    wyang       03/01/04 - transportable db 
Rem    bkhaladk    02/25/04 - support for SB Xmltype 
Rem    ahwang      07/09/03 - bug 277194 - temp segment transport
Rem    jgalanes    07/22/03 - Fix 3048060 Xplatform INTCOLS
Rem    apareek     06/14/03 - add containment check for nested tables
Rem    wesmith     06/11/03 - verify_MV(): add parameter full_check
Rem    apareek     05/29/03 - add support for MVs
Rem    rasivara    04/22/03 - bug 2918098: BIG ts_list field for some procedures
Rem    apareek     03/03/03 - grant dbms_plugts to execute_catalog_role
Rem    apareek     09/30/02 - cross platform changes
Rem    dfriedma    05/22/02 - kfp renamed to kcp
Rem    sjhala      04/04/02 - 2198861: preserve migrated ts info with plugin
Rem    yuli        02/25/02 - add function kfp_getcomp
Rem    bmccarth    01/14/02 - Bug 802824 -move patchtablemetadata into its
Rem                           own package and set to execute public
Rem    bzane       11/05/01 - BUG 1754947: add exception 29353
Rem    rburns      10/26/01 - catch 942 exception
Rem    smuralid    09/08/01 - add patchTableMetadata
Rem    amsrivas    06/21/01 - bug 1826474: get absolute file# from file header
Rem    apareek     02/08/01 - add full_check for 2 way violations
Rem    apareek     11/10/00 - bug 1494388
Rem    jdavison    11/28/00 - Drop extra semi-colons
Rem    apareek     10/30/00 - add verify_unused_cols
Rem    apareek     07/10/00 - fix for sqlplus
Rem    apareek     05/30/00 - add extended_tts_checks
Rem    yuli        12/06/99 - bug 972035: add function kfp_getfh
Rem    jwlee       06/09/99 - bug 864670: check nchar set ID
Rem    jwlee       09/28/98 - check system and temporary tablespace
Rem    jwlee       06/25/98 - misc fixes
Rem    jwlee       06/16/98 - create temp table on the fly
Rem    jwlee       05/19/98 - add dbms_tts package
Rem    jwlee       05/03/98 - add place holder for char set name
Rem    jwlee       04/04/98 - add more exceptions
Rem    jwlee       04/02/98 - Complete coding for first phase
Rem    jwlee       03/30/98 - more
Rem    jwlee       03/30/98 - more on transportable tablespace
Rem    jwlee       03/26/98 - more
Rem    jwlee       03/19/98 - more on Pluggable Tablespace
Rem    jwlee       03/06/98 - Remove highSCN parameter from beginImport
Rem    jwlee       02/25/98 - Pluggable Tablespace Package Specification
Rem    jwlee       02/25/98 - Created
Rem

CREATE OR REPLACE 
PACKAGE dbms_plugts IS

  TS_EXP_BEGIN   CONSTANT binary_integer := 1;
  TS_EXP_END     CONSTANT binary_integer := 2;

  /**********************************************
  **   Routines called directly by EXPORT      **
  **********************************************/
 
  PROCEDURE beginExport;

  -- This procedure is called at the beginning of exprt. It constructs the
  -- beginImport call in the anonymous PL/SQL block.

  PROCEDURE beginExpTablespace (tsname IN varchar2);

  -- This procedure makes sure tablespaces are read-only during export.
  -- It is called for each tablespace.
  --
  -- Parameters
  --   tsname - (IN) tablespace name.
  --
  -- Possible Exceptions:
  --   ts_not_found
  --   ts_not_read_only


  PROCEDURE checkPluggable (incl_constraints    IN number,
                            incl_triggers       IN number,
                            incl_grants         IN number,
                            full_check          IN number,
                            do_check            IN number DEFAULT 1);

  -- Make sure objects are self-contained, etc.  If not, ORA-29341
  -- (exception not_self_contained) will be signaled.
  --
  -- Parameters:
  --   incl_constraints - (IN) 1 if include constraints, 0 otherwise.
  --   incl_triggers    - (IN) 1 if include triggers, 0 otherwise.
  --   incl_grants      - (IN) 1 if include grants, 0 otherwise.
  --   full_closure     - (IN) TRUE if both IN and OUT pointers
  --                           are considered violations
  --                           should be TRUE for TSPITR
  -- Returns:
  --   TRUE if the set of objects is self-contained.

  FUNCTION getLine RETURN varchar2;

  -- This function returns the next line of a block that has been
  -- previously selected for retrieval via selectBlock.
  -- 
  -- Returns:
  --   A string to be appended to the export file.


  PROCEDURE selectBlock (blockID IN binary_integer);

  -- This procedures selects a particular PL/SQL anonymous block for retrieval.
  --
  -- Parameters:
  --   blockID - (IN) the ID to pick a PL/SQL anonymous block
  --                  dbms_plugts.TS_EXP_BEGIN at the beginning of export
  --                  dbms_plugts.TS_EXP_END at the end of export


  /**********************************************
  **   Routines called directly by IMPORT      **
  **********************************************/

  PROCEDURE newDatafile (filename IN varchar2);

  -- The function informs the dbms_Plugts package about the location 
  -- of the new datafiles. This procedure is called directly by import.
  -- If the file can not be fount, an error will be signaled, possible 
  -- at a later point.
  --
  -- Parameters:
  --   filename - (IN) file name (including path)


  PROCEDURE newTablespace (tsname IN varchar2);

  -- Communicate new tablespace name from command line option TABLESPACES 
  -- to the PL/SQL package. This procedure is called directly by import.
  -- 
  -- Parameters:
  --   tsname - (IN) Tablespace name.


  PROCEDURE pluggableUser (usrname IN varchar2);

  -- Communication the list of users entered by the DBA via the USERS 
  -- command line option to the PL/SQL package. This function is called 
  -- directly by import.
  --
  -- Parameters:
  --   usrname - (IN) user name.


  PROCEDURE mapUser (from_user IN varchar2, to_user IN varchar2);

  -- Pass the information from FROM_USER and TO_USER to the PL/SQL 
  -- package. Called directly by import.
  --
  -- Parameters:
  --   from_user - (IN) a user in FROM_USER list.
  --   to_user   - (IN) the corresponding user in TO_USER list.


  PROCEDURE mapTs (from_ts IN varchar2, to_ts IN varchar2);

  -- Pass Data Pump's REMAP_TABLESPACE info to lower layers. 
  -- Called directly by import.
  --
  -- Parameters:
  --   from_ts   - (IN) a tablespace name to be remapped.
  --   to_ts     - (IN) the new of the corresponding tablespace to be created.



  /*******************************************************************
  **  Routines called automatically via the PL/SQL anonymous block  **
  *******************************************************************/


  PROCEDURE beginImpTablespace (tsname          IN varchar2,
                                tsID            IN number,
                                owner           IN varchar2,
                                n_files         IN binary_integer,
                                contents        IN binary_integer,
                                blkSize         IN binary_integer,
                                inc_num         IN binary_integer,
                                clean_SCN       IN number,
                                dflminext       IN number,
                                dflmaxext       IN number,
                                dflinit         IN number,
                                dflincr         IN number,
                                dflminlen       IN number,
                                dflextpct       IN binary_integer,
                                dflogging       IN binary_integer,
                                affstrength     IN number,
                                bitmapped       IN number,
                                dbID            IN number,
                                directallowed   IN number,
                                flags           IN binary_integer,
                                creation_SCN    IN number,
                                groupname       IN varchar2,
                                spare1          IN number,
                                spare2          IN number,
                                spare3          IN varchar2,
                                spare4          IN date,
                                seg_fno         IN number
                                                DEFAULT 0,
                                seg_bno         IN number
                                                DEFAULT 0,
                                seg_blks        IN number
                                                DEFAULT 0);
-- Pass to dbms_plugts package the information needed to create the 
  -- tablespace in target database.  This procedure also checks to 
  -- make sure the tablespace name does not conflict with any existing 
  -- tablespaces already in the database. And the user name match with the
  -- USERS list in the import comamnd line. It also make sure the blcok size
  -- is the same as that in the target database. Begin importing meta data 
  -- for the tablespace. This procedure call appears in the export file.
  --
  -- The parameter list includes all columns for ts$, except those that 
  -- will for sure be discarded (online$, undofile#, undoblock#, 
  -- ownerinstance, backupowner).  The spares are included so that the 
  -- interface does not have to be changed even when we use these 
  -- spares in the future. 
  --
  -- There are three extra parameters added for transporting migrated
  -- tablespaces. seg_fno, seg_bno and seg_blks represent the dictionary
  -- information held in SEG$ for any tablespace which was migrated from
  -- dictionary managed to locally managed. The file#, block# gives the
  -- location of bitmap space header for the migrated tablespace and the
  -- blocks parameter represnts the size of the space header in blocks.
  --
  -- Parameters:
  --    tsname          IN tablespace name
  --    tsID            IN tablespace ID in original database
  --    owner           IN owner of tablespace
  --    n_files         IN number of datafiles in the tablespace
  --    contents        IN contents column of ts$ (TEMPORARY/PERMANENT)
  --    blkSize         IN size of block in bytes
  --    inc_num         IN incarnation number of extent
  --    clean_SCN       IN tablespace clean SCN,
  --    dflminext       IN default minimum number of extents
  --    dflmaxext       IN default maximum number of extents
  --    dflinit         IN default initial extent size
  --    dflincr         IN default initial extent size
  --    dflminlen       IN default minimum extent size
  --    dflextpct       IN default percent extent size increase
  --    dflogging       IN default logging attribute
  --    affstrength     IN Affinity strength
  --    bitmapped       IN If bitmapped
  --    dbID            IN database ID 
  --    directallowed   IN allowed
  --    flags           IN flags
  --    creation_SCN    IN tablespace creation SCN
  --    groupname       IN Group name
  --    spare1          IN spare1 in ts$
  --    spare2          IN spare2 in ts$
  --    spare3          IN spare3 in ts$
  --    spare4          IN spare4 in ts$
  --    seg_fno         IN file# for space_hdr in seg$
  --    seg_bno         IN block# for space_hdr in seg$
  --    seg_blks        IN blocks, size of space_hdr in seg$
  --


  PROCEDURE checkUser (username IN varchar2);

  -- Check the user name in the pluggable set matches that entered by 
  -- the DBA via the import USERS command line option. Make sure that, 
  -- after the user mappings, the required user is already in the database.
  -- This function call appears in the export file.
  --
  -- Parameters:
  --   username - (IN) user name.

  
  PROCEDURE beginImport (clone_oracle_version   IN varchar2,
                         charsetID              IN binary_integer,
                         ncharsetID             IN varchar2,
                         srcplatformID          IN binary_integer,
                         srcplatformName        IN varchar2,
                         highest_data_objnum    IN number,
                         highest_lob_sequence   IN number,
                         n_ts                   IN number,
                         has_clobs              IN number DEFAULT 1,
                         has_nchars             IN number DEFAULT 1,
                         char_semantics_on      IN number DEFAULT 1);

  -- Pass information about the pluggable set to the PL/SQL package. 
  -- Among them is the release version of the Oracle executable that 
  -- created the pluggable set, which is used for checking compatibility. 
  -- This procedure call appears in the export file.
  -- 
  -- Parameters:
  --   clone_oracle_version IN the release version of the Oracle 
  --                           executable that created the pluggable set
  --   charsetID            IN character set ID 
  --   ncharsetID           IN nchar set ID, in varchar2 format
  --                           (May be NULL if generated by 8.1.5)
  --   platformID           IN platform ID
  --   platformName         IN platform name
  --   highest_data_objnum  IN highest data object # in pluggable set
  --   highest_lob_sequence IN highest LOB sequence # in pluggable set
  --   n_ts                 IN number of tablespace to be plugged in.
  --   has_clobs            IN whether tablespaces have CLOB data
  --   has_nchars           IN whether tablespaces have nchar data
  --   char_smeantics_on    IN whether tablespaces have char semantic data

  PROCEDURE checkCompType (compID IN varchar2, compRL IN varchar2);

  -- Check and adjust version for each compatibility type. This procedure 
  -- appears in the export file.
  --
  -- Parameters:
  --   compID - (IN) compatibility type name
  --   compRL - (IN) release level


  PROCEDURE checkDatafile (name           IN varchar2,
                           databaseID     IN number,
                           absolute_fno   IN binary_integer,
                           curFileBlks    IN number,
                           tablespace_ID  IN number,
                           relative_fno   IN binary_integer,
                           maxextend      IN number,
                           inc            IN number,
                           creation_SCN   IN number,
                           checkpoint_SCN IN number,
                           reset_SCN      IN number,
                           spare1         IN number,
                           spare2         IN number,
                           spare3         IN varchar2,
                           spare4         IN date);

  -- Call statically linked C routines to associate datafile with 
  -- tablespace, validate file headers. This procedure appears in the 
  -- export file.  The parameter list includes all columns in file$, 
  -- except those that will for sure be discarded (status$, ownerinstance).
  -- 
  -- Parameters:
  --   name              IN file name (excluding path)
  --   databaseID        IN database ID
  --   absolute_fno      IN absolute file number
  --   curFileBlks       IN size of file in blocks
  --   tablespace_ID     IN tablespace ID in original database,
  --   relative_fno      IN relative file number,
  --   maxextend         IN maximum file size
  --   inc               IN increment amount
  --   creation_SCN      IN file creation SCN
  --   checkpoint_SCN    IN file checkpoint SCN
  --   reset_SCN         IN file reset SCN
  --   spare1            IN spare1 in file$
  --   spare2            IN spare2 in file$
  --   spare3            IN spare3 in file$
  --   spare4            IN spare4 in file$


  PROCEDURE endImpTablespace;

  -- Wrap up tablespace check. This procedure appears in the export file.


  PROCEDURE commitPluggable;

  -- Call statically linked C routine to atomically plug-in the pluggable
  -- set. This procedure appears in the export file.


  PROCEDURE reclaimTempSegment (file_no      IN binary_integer,
                                block_no     IN binary_integer,
                                type_no      IN binary_integer,
                                ts_no        IN binary_integer,
                                blocks       IN binary_integer,
                                extents      IN binary_integer,
                                iniexts      IN binary_integer,
                                minexts      IN binary_integer,
                                maxexts      IN binary_integer,
                                extsize      IN binary_integer,
                                extpct       IN binary_integer,
                                user_no      IN binary_integer,
                                lists        IN binary_integer,
                                groups       IN binary_integer,
                                bitmapranges IN binary_integer,
                                cachehint    IN binary_integer,
                                scanhint     IN binary_integer,
                                hwmincr      IN binary_integer,
                                spare1       IN binary_integer,
                                spare2       IN binary_integer);
  -- reclaim a temporary segment. Parameters are necessary
  -- info to validate and fix up seg$ by the callout routine
  -- kcp_plg_reclaim_temp_segment().
  --
  -- PARAMETERS:
  --   the parameters match seg$ columns exactly. See seg$ description.

  PROCEDURE endImport;

  -- get the db char set properties of the tablespaces in transts_tmp$

  PROCEDURE get_db_char_properties (
       has_clobs       OUT binary_integer,  -- has CLOB related columns
       has_nchars      OUT binary_integer,  -- has NCHAR related  columns
       char_semantics  OUT binary_integer  -- has CHARACTER SEMANTICS columns
       );

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/

  ts_not_found  EXCEPTION;
  PRAGMA exception_init(ts_not_found, -29304);
  ts_not_found_num NUMBER := -29304;

  ts_not_read_only  EXCEPTION;
  PRAGMA exception_init(ts_not_read_only, -29335);
  ts_not_read_only_num NUMBER := -29335;

  internal_error    EXCEPTION;
  PRAGMA exception_init(internal_error, -29336);
  internal_error_num NUMBER := -29336;

  datafile_not_ready  EXCEPTION;
  PRAGMA exception_init(datafile_not_ready, -29338);
  datafile_not_ready_num    NUMBER := -29338;

  blocksize_mismatch  EXCEPTION;
  PRAGMA exception_init(blocksize_mismatch, -29339);
  blocksize_mismatch_num    NUMBER := -29339;

  exportfile_corrupted  EXCEPTION;
  PRAGMA exception_init(exportfile_corrupted, -29340);
  exportfile_corrupted_num  NUMBER := -29340;

  not_self_contained    EXCEPTION;
  PRAGMA exception_init(not_self_contained, -29341);
  not_self_contained_num    NUMBER := -29341;

  user_not_found        EXCEPTION;
  PRAGMA exception_init(user_not_found, -29342);
  user_not_found_num    NUMBER := -29342;

  mapped_user_not_found EXCEPTION;
  PRAGMA exception_init(mapped_user_not_found, -29343);
  mapped_user_not_found_num    NUMBER := -29343;

  user_not_in_list        EXCEPTION;
  PRAGMA exception_init(user_not_in_list, -29344);
  user_not_in_list_num    NUMBER := -29344;

  different_char_set      EXCEPTION;
  PRAGMA exception_init(different_char_set, -29345);
  different_char_set_num    NUMBER := -29345;

  ts_not_in_list          EXCEPTION;
  PRAGMA exception_init(ts_not_in_list, -29347);
  ts_not_in_list_num      NUMBER := -29347;

  datafiles_missing          EXCEPTION;
  PRAGMA exception_init(datafiles_missing, -29348);
  datafiles_missing_num      NUMBER := -29348;

  ts_name_conflict           EXCEPTION;
  PRAGMA exception_init(ts_name_conflict, -29349);
  ts_name_conflict_num       NUMBER := -29349;

  sys_or_tmp_ts             EXCEPTION;
  PRAGMA exception_init(sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num          NUMBER := -29351;

  ts_list_overflow           EXCEPTION;
  PRAGMA exception_init(ts_list_overflow, -29353);
  ts_list_overflow_num       NUMBER := -29353;

  /******************************************************************
  **             Interface for testing, etc.                       **
  ******************************************************************/

  PROCEDURE init;


  /*******************************************************************
  **               Interface for trusted callouts                   **
  *******************************************************************/

  -- begin export
  PROCEDURE kcp_bexp(vsn       OUT varchar2,        -- Oracle server version
                     dobj_half OUT binary_integer,  -- half of data obj#
                     dobj_odd  OUT binary_integer); -- lowest bit of data obj#

  -- get char, nchar ID and name
  PROCEDURE kcp_getchar(cid     OUT binary_integer,                  -- char ID
                        ncid    OUT binary_integer);                -- nchar ID

  -- check if char, nchar set match (signal error is not)
  PROCEDURE kcp_chkchar(cid     IN binary_integer,                   -- char ID
                        ncid    IN binary_integer,                  -- nchar ID
                        chknc   IN binary_integer,      -- chech nchar (1 or 0)
                        has_clobs         IN binary_integer,
                        has_nchars        IN binary_integer,
                        char_semantics_on IN binary_integer);

  -- allocate datafile and tablespace structures
  PROCEDURE kcp_aldfts(n_dfiles IN binary_integer,       -- number of datafiles
                       n_ts     IN binary_integer);    -- number of tablespaces

  -- read file header
  PROCEDURE kcp_rdfh(fname IN varchar2);    

  -- convert sb4 to ub4
  FUNCTION sb4_to_ub4 (b IN binary_integer) RETURN number;
  
  -- new tablespace
  --
  PROCEDURE kcp_newts(tsname    IN varchar2,                 -- tablespace name
                      tsid      IN binary_integer,                     -- ts ID
                      n_files   IN binary_integer,      -- # of datafiles in ts
                      blksz     IN binary_integer,                -- block size
                      inc_num   IN binary_integer,                     -- inc #
                      cleanSCN  IN number,                          -- cleanSCN
                      dflminext IN binary_integer,          -- dflminext in ts$
                      dflmaxext IN binary_integer,          -- dflmaxext in ts$
                      dflinit   IN binary_integer,            -- dflinit in ts$
                      dflincr   IN binary_integer,            -- dflincr in ts$
                      dflminlen IN binary_integer,          -- dflminlen in ts$
                      dflextpct IN binary_integer,          -- dflextpct in ts$
                      dflogging IN binary_integer,          -- dflogging in ts$
                      bitmapped IN binary_integer,          -- bitmapped in ts$
                      dbID      IN binary_integer,                     -- db ID
                      crtSCN    IN number,                      -- creation SCN
                      contents  IN binary_integer,          -- contents$ in ts$
                      flags     IN binary_integer,              -- flags in ts$
                      seg_fno   IN binary_integer,             -- file# in seg$
                      seg_bno   IN binary_integer,            -- block# in seg$
                      seg_blks  IN binary_integer);           -- blocks in seg$


  -- Plug in datafile
  -- 
  PROCEDURE kcp_plgdf(dbID      IN binary_integer,               -- database ID
                      afn       IN binary_integer,           -- absolute file #
                      fileBlks  IN binary_integer,    -- size of file in blocks
                      tsID      IN binary_integer,             -- tablespace ID
                      rfn       IN binary_integer,           -- relative file #
                      maxextend IN binary_integer,
                      inc       IN binary_integer,
                      crtSCN    IN number,                      -- creation SCN
                      cptSCN    IN number,-- checkpoint SCN
                      rstSCN    IN number,-- reset SCN
                      spare1    IN binary_integer);          -- spare1 in file$


  -- Commit Pluggable
  --
  PROCEDURE kcp_cmt (data_objn  IN binary_integer);       -- data object number


  -- Initialize kernel data structures
  --
  PROCEDURE kcp_init;


  -- adjust compatibility level
  --
  PROCEDURE kcp_acomp (compID   IN varchar2,             -- compatibility type
                       compRL   IN varchar2);                  -- release level

  -- get current compatible setting
  --
  PROCEDURE kcp_getcomp (comprls OUT binary_integer,      -- compatible setting
                         szcomp  OUT varchar2,            -- compatible setting
                         irrerls OUT binary_integer);   -- irreversible setting

  -- get file header infomation according to file number
  --
  PROCEDURE kcp_getfh (afn       IN  binary_integer,    -- absolute file number
                       dbID      OUT binary_integer,             -- database ID
                       ckpt_SCN  OUT varchar2,                -- checkpoint SCN
                       reset_SCN OUT varchar2,                 -- reset log SCN
                       hdr_afn   OUT binary_integer);      -- file# from header

  -- This routine does some verification checks needed for cross platform
  -- transport
  PROCEDURE kcp_chkxPlatform(srcplatformID       IN binary_integer,
                             srcplatformName     IN varchar2,
                             tgtplatformID     IN binary_integer,
                             tgtplatformName     IN varchar2,
                             src_rls_version     IN varchar2);

  -- This routine fix up seg$ to reclaim a temp segment
  PROCEDURE kcp_plg_reclaim_temp_segment(file_no      IN binary_integer,
                                         block_no     IN binary_integer,
                                         type_no      IN binary_integer,
                                         ts_no        IN binary_integer,
                                         blocks       IN binary_integer,
                                         extents      IN binary_integer,
                                         iniexts      IN binary_integer,
                                         minexts      IN binary_integer,
                                         maxexts      IN binary_integer,
                                         extpct       IN binary_integer,
                                         user_no      IN binary_integer,
                                         lists        IN binary_integer,
                                         groups       IN binary_integer,
                                         bitmapranges IN binary_integer,
                                         cachehint    IN binary_integer,
                                         scanhint     IN binary_integer,
                                         hwmincr      IN binary_integer,
                                         spare1       IN binary_integer,
                                         spare2       IN binary_integer);

  -- Declaration of the trusted callout to compute whether a plug into
  -- a specified db char and nchar set is compatible with current db.
  PROCEDURE kcp_check_tts_char_set_compat(
                has_clobs            IN binary_integer,
                has_nchars           IN binary_integer,
                char_semantics_on    IN binary_integer,
                target_charset_name  IN varchar2,
                target_ncharset_name IN varchar2);

END dbms_plugts;
/

GRANT EXECUTE ON dbms_plugts TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_plugtsp IS

  -- Finish thing up after objects have been created.

  PROCEDURE patchTableMetadata(schemaName IN VARCHAR2,           -- schema name
                               tableName  IN VARCHAR2,            -- table name
                               mdClob     IN CLOB,      -- data pump's metadata
                            expSrvrEndian IN BINARY_INTEGER,   -- export endian
                            impSrvrEndian IN BINARY_INTEGER);  -- import endian
  -- patchup table metadata after table has been created
  -- at the import site
  -- This procedure is called by import 

  PROCEDURE patchDictionary(str1 IN VARCHAR2,
                            str2 IN VARCHAR2,
                            str3 IN VARCHAR2,
                            str4 IN VARCHAR2,
                            str5 IN VARCHAR2,
                            str6 IN VARCHAR2,
                            str7 IN VARCHAR2,
                            bin1 IN BINARY_INTEGER);
  -- fixup various things that get lost across transport due to no relevant
  -- syntax (i.e. options/versions based on compatibility rather than explicit
  -- syntax).  This is called during TTS import.

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/

  -- These were copied from the dbms_plugts package which is not public-execute

  ts_not_found  EXCEPTION;
  PRAGMA exception_init(ts_not_found, -29304);
  ts_not_found_num NUMBER := -29304;

  ts_not_read_only  EXCEPTION;
  PRAGMA exception_init(ts_not_read_only, -29335);
  ts_not_read_only_num NUMBER := -29335;

  internal_error    EXCEPTION;
  PRAGMA exception_init(internal_error, -29336);
  internal_error_num NUMBER := -29336;

  datafile_not_ready   EXCEPTION;
  PRAGMA exception_init(datafile_not_ready, -29338);
  datafile_not_ready_num    NUMBER := -29338;

  blocksize_mismatch   EXCEPTION;
  PRAGMA exception_init(blocksize_mismatch, -29339);
  blocksize_mismatch_num    NUMBER := -29339;

  exportfile_corrupted  EXCEPTION;
  PRAGMA exception_init(exportfile_corrupted, -29340);
  exportfile_corrupted_num  NUMBER := -29340;

  not_self_contained    EXCEPTION;
  PRAGMA exception_init(not_self_contained, -29341);
  not_self_contained_num    NUMBER := -29341;

  user_not_found        EXCEPTION;
  PRAGMA exception_init(user_not_found, -29342);
  user_not_found_num    NUMBER := -29342;

  mapped_user_not_found EXCEPTION;
  PRAGMA exception_init(mapped_user_not_found, -29343);
  mapped_user_not_found_num    NUMBER := -29343;

  user_not_in_list        EXCEPTION;
  PRAGMA exception_init(user_not_in_list, -29344);
  user_not_in_list_num    NUMBER := -29344;

  different_char_set      EXCEPTION;
  PRAGMA exception_init(different_char_set, -29345);
  different_char_set_num    NUMBER := -29345;

  ts_not_in_list          EXCEPTION;
  PRAGMA exception_init(ts_not_in_list, -29347);
  ts_not_in_list_num      NUMBER := -29347;

  datafiles_missing          EXCEPTION;
  PRAGMA exception_init(datafiles_missing, -29348);
  datafiles_missing_num      NUMBER := -29348;

  ts_name_conflict           EXCEPTION;
  PRAGMA exception_init(ts_name_conflict, -29349);
  ts_name_conflict_num       NUMBER := -29349;

  sys_or_tmp_ts         EXCEPTION;
  PRAGMA exception_init(sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num          NUMBER := -29351;

  ts_list_overflow           EXCEPTION;
  PRAGMA exception_init(ts_list_overflow, -29353);
  ts_list_overflow_num       NUMBER := -29353;

  -- patch table metadata
  PROCEDURE kcp_ptmd(schemaName IN VARCHAR2,                     -- schema name
                     tableName  IN VARCHAR2,                      -- table name
                     mdClob     IN CLOB,                -- data pump's metadata
                  expSrvrEndian IN BINARY_INTEGER,      -- export server endian
                  impSrvrEndian IN BINARY_INTEGER);     -- import server endian

  -- patch dictionary
  PROCEDURE kcp_pd(str1 IN VARCHAR2,                  -- schema name
                   str2 IN VARCHAR2,
                   str3 IN VARCHAR2,
                   str4 IN VARCHAR2,
                   str5 IN VARCHAR2,
                   str6 IN VARCHAR2,
                   str7 IN VARCHAR2,
                   bin1 IN BINARY_INTEGER);           -- Bitmap, etc.

END dbms_plugtsp;
/
GRANT EXECUTE on dbms_plugtsp TO public
/

CREATE OR REPLACE PACKAGE dbms_tts IS

  -- Check if the transportable set is self-contained.  All violations are
  -- inserted into a temporary table that can be selected from view
  -- "transport_set_violations".
  --
  TYPE tablespace_names IS TABLE OF varchar(30) INDEX BY binary_integer;
  PROCEDURE transport_set_check (ts_list          IN clob, 
                                 incl_constraints IN boolean  DEFAULT FALSE,
                                 full_check     IN boolean  DEFAULT FALSE);

  -- Return TRUE if the transportable set is self-contained. FALSE otherwise.
  --
  --
  FUNCTION isSelfContained (ts_list          IN clob,
                            incl_constraints IN boolean,
                            full_check     IN boolean) RETURN boolean;

  -- Check if the transportable set is compatible with the specified
  -- char sets.
  -- Result is displayed in output. Must set serveroutput on.
  PROCEDURE transport_char_set_check_msg (
            ts_list                  IN  CLOB, 
            target_db_char_set_name  IN  VARCHAR2,
            target_db_nchar_set_name IN  VARCHAR2);

  -- char sets.
  -- Return TRUE is char set is compatible. msg is set to 'Ok' or
  -- error message.
  FUNCTION transport_char_set_check (
            ts_list                  IN  CLOB, 
            target_db_char_set_name  IN  VARCHAR2,
            target_db_nchar_set_name IN  VARCHAR2,
            err_msg                  OUT VARCHAR2) RETURN BOOLEAN;

  -- downgrade
  --
  PROCEDURE downgrade;

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/

  ts_not_found  EXCEPTION;
  PRAGMA exception_init(ts_not_found, -29304);
  ts_not_found_num NUMBER := -29304;

  invalid_ts_list  EXCEPTION;
  PRAGMA exception_init(invalid_ts_list, -29346);
  invalid_ts_list_num NUMBER := -29346;

  sys_or_tmp_ts    EXCEPTION;
  PRAGMA exception_init(sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num          NUMBER := -29351;

  /*******************************************************************
  **               Trusted callouts                                 **
  *******************************************************************/

  -- check compatibility
  --
  PROCEDURE kcp_ckcmp;

END dbms_tts;
/
GRANT EXECUTE ON dbms_tts TO execute_catalog_role
/
drop view sys.transport_set_violations
/

Rem suppress error message if table does not exist
BEGIN  
   EXECUTE IMMEDIATE 'truncate table sys.transts_error$';
EXCEPTION 
   WHEN OTHERS THEN
      IF SQLCODE = -942 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
drop table sys.transts_error$
/
drop table sys.transts_tmp$
/

/*****************************************************************************/
 -- The following package contains procedures and packages supporting 
 -- additional checks for the transportable tablespace feature.
 -- It adds support to capture any objects that would prevent the 
 -- transportable feature to be used because of dependencies between objects
 -- in the transportable set and those not contained in the transportable set 
 --
 --  Note that these are in addition to the ones that are captured by the 
 --  dbms_tts.straddling_ts_objects
 --
 -- If a new feature is introduced, developers should write a new function to
 -- build a tablespace list associated with any object that is part of the 
 -- feature and ensure its self containment by using the function 
 -- dbms_extended_tts_checks.objectlist_Contained
 --
 --  ********************************************************************  
 --  * The following shows example usage:                               *
 --  *                                                                  *
 --  * New Feature  --> Extensible Index                                *
 --  *                                                                  *
 --  * New Function                                                     *
 --  * FUNCTION dbms_extended_tts_checks.verify_Exensible               *
 --  *                                                                  *
 --  *   The above function ensures that all objects associated with    *
 --  *   extensible index are self contained. It                        *
 --  *     - Identifies objects of type Extensible indexes (o1,o2..oN)  *
 --  *     - Gets a list of dependent objects for each object oI        *
 --  *     - Generates a dependent tablespace list for that object      *
 --  *     - Ensures that the dependent list is either fully contained  *
 --  *       or fully outside the list of tablespaces to be transported *
 --  *       using dbms_extended_tts_checks.objectlist_Contained        *
 --  *                                                                  *
 --  * The above function should then be invoked from the function      *
 --  * dbms_tts.straddling_ts_objects                                   *
 --  ********************************************************************  
 --   
 -- I have provided some functions that identify the tablespace
 -- containing a base object
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tab
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_ind
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabsubpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indsubpart
 --
 -- for any new objects that take up storage
 -- a function that identifies the storage tablespace must be added
 --
 /****************************************************************************/

CREATE OR REPLACE PACKAGE SYS.DBMS_EXTENDED_TTS_CHECKS IS

  /*************************************************************************
      Data Structures 
   *************************************************************************/

   -- following data structure is used to pass information about an object 
   TYPE objrec IS RECORD (
       v_pobjschema    varchar2(30),
       v_pobjname      varchar2(30),
       v_objid         number,
       v_objname       varchar2(30),
       v_objsubname    varchar2(30),
       v_objowner      varchar2(30),
       v_objtype       varchar2(15));

   --  List of object records 
   TYPE t_objlist IS TABLE OF objrec
     INDEX BY BINARY_INTEGER;

  /*************************************************************************
      FUNCTION  verify_XMLSchema
   *************************************************************************/
  -- verify that the Schema based XMLType tables that are part of the transport
  -- set are self contained. i.e. the out of line pieces that the table points
  -- to are also part of the transport set. This will ensure that the SB
  -- XMLType table is self contained. 

     FUNCTION  verify_XMLSchema(tsnames dbms_tts.tablespace_names, 
                                fromExp in boolean) RETURN boolean;

  /*************************************************************************
      FUNCTION  verify_Extensible 
   *************************************************************************/
  -- Verify that any secondary objects that are associated with an extensible
  -- index are contained in the list of tablespaces or fully outside the 
  -- list. 
  -- This guarantees self containment of all or none of the secondary objects 
  -- associated with the extensible index.
  -- For simple types like tables and indexes it is clear why this check works
  -- what may not be so obvious is that this works even for objects like 
  -- partitions, lobs etc.  For e.g. if Table T1 is partitioned two ways P1 
  -- and P2, has a lob object L1;  and Table T2 is an IOT, And 
  -- extensible index E1 is associated with L1 and T2 then it is sufficient 
  -- just check that tablespace(L1) and tablespace(T2) are either fully 
  -- contained or fully out of the tts set. Self Containment of T1 and T2
  -- is guaranteed by the straddling_rs_objects function

     FUNCTION  verify_Extensible (tsnames dbms_tts.tablespace_names, 
                                  fromExp in boolean) RETURN boolean;


  /*************************************************************************
      FUNCTION  verify_MV
   *************************************************************************/

  -- This function checks that:
  --
  -- 1. Materialized view logs stored as tables and the corresponding 
  --    master tables are self contained. The containment check is similar
  --    to tables and its indexes: If full_check is TRUE, then BOTH the 
  --    MV log and the master table must be in or both must be out of the 
  --    transportable set . If full_check is FALSE, then it is ok for the 
  --    MV log to be out of the transportable set but it is NOT ok for 
  --    the MV log to be in and its master table to be out of the set.
  --
  -- 2. Updateable Materialized view tables  and their corresponding logs 
  --    are fully contained in the transportable set
  --  
  --    The return value is TRUE if no violations occur and FALSE otherwise 
  --  
  --    If called from export, it returns on occurence of the first violation 
  --    of either of the above conditions. For other calls it populates the 
  --    violation table with the offending violation object information for 
  --    each violation
  --    It returns TRUE if no violation of the above conditions occurs.   
  --   
  --    Note that it is ok to transport just the MVs and not their masters or
  --    vice versa. It is also ok to just transport master tables without 
  --    the mv logs, but NOT vice versa.
 
     FUNCTION  verify_MV (tsnames dbms_tts.tablespace_names, 
                          fromExp in boolean, full_check in boolean) 
                          RETURN boolean;

  /*************************************************************************
      FUNCTION  verify_NT
   *************************************************************************/
  -- Verify that all nested tables are fully in or out of the tts set

     FUNCTION  verify_NT (tsnames dbms_tts.tablespace_names, 
                                  fromExp in boolean) RETURN boolean;

  /*************************************************************************
        FUNCTION verify_unused_cols
  /*************************************************************************/

  -- The following function ensures that tables containing UNUSED columns
  -- are not part of the transportable tablespace set. See bug 802808
  -- Once there's kernel support for column ordering within tables, this
  -- check should be disabled
  -- The workaround this is to issue an ALTER TABLE DROP UNUSED COLUMNS
  -- to free up the space in the data block and get around the column
  -- reordering problem

     FUNCTION  verify_unused_cols (tsnames dbms_tts.tablespace_names, 
                                  fromExp in boolean) RETURN boolean;

  /*************************************************************************
        FUNCTION objectlist_Contained
   *************************************************************************/
  
  -- The following function ensures that the group of objects that are passed
  -- in either are fully IN or OUT of the tslist (set of tablespaces to be 
  -- transported 

     FUNCTION objectlist_Contained(vobjlist t_objlist, 
                                   tsnames dbms_tts.tablespace_names) 
                                   RETURN number ;
                        -- RETURN CODES
                        -- straddling objects across transportable set - 0
                        -- all objects in list are fully contained     - 1
                        -- all objects in list are fully outside       - 2

  /*************************************************************************/


  -- The following get_tablespace_* functions take in information about
  -- an object that takes up physical storage in the database and return
  -- the tablespace associated with the tablespace.
  
  --  *******
  --   TABLE 
  --  *******

  -- if table is non partitioned and not an index only table then return
  -- its tablespace
  -- if TABLE is an IOT or partitioned then just return the tablespace 
  -- associated with the index or the first partition respectively. If
  -- a specific tablespace is needed then the get_tablespace_tabpart
  -- routine should be invoked by the caller.

     FUNCTION get_tablespace_tab(object_id  number,
                               object_owner  varchar2, 
                               object_name  varchar2, 
                               object_subname  varchar2,
                               object_type  varchar2)  RETURN varchar2 ;

  -- *******
  --  INDEX
  -- *******

  -- if INDEX is partitioned then simply return the tablespace associated 
  -- the first partition
     FUNCTION get_tablespace_ind(object_id number,
                                 object_owner  varchar2, 
                                 object_name varchar2, 
                                 object_subname varchar2,
                                 object_type varchar2)  RETURN varchar2 ;

  -- ***************  
  -- TABLE PARTITION
  -- ***************
     FUNCTION get_tablespace_tabpart(object_id  number,
                                     object_owner varchar2, 
                                     object_name varchar2, 
                                     object_subname  varchar2,
                                     object_type varchar2) RETURN varchar2 ;

  -- ***************
  -- INDEX PARTITION
  -- ***************
     FUNCTION get_tablespace_indpart(object_id IN number,
                                     object_owner  varchar2, 
                                     object_name  varchar2, 
                                     object_subname  varchar2,
                                     object_type  varchar2)  RETURN varchar2 ;

  -- ******************
  -- TABLE SUBPARTITION
  -- ******************
     FUNCTION get_tablespace_tabsubpart(object_id number,
                                        object_owner  varchar2, 
                                        object_name  varchar2, 
                                        object_subname  varchar2,
                                        object_type varchar2) RETURN varchar2 ;

  -- ******************
  -- INDEX SUBPARTITION
  -- ******************
     FUNCTION get_tablespace_indsubpart(object_id  number,
                                        object_owner varchar2, 
                                        object_name varchar2, 
                                        object_subname  varchar2,
                                        object_type varchar2)  
                                        RETURN varchar2 ;

  /*************************************************************************/
   -- This function returns objects associated with an extensible index  
   -- in a list format
  

  FUNCTION get_domain_index_secobj(objn number)
                                   RETURN t_objlist;
  /*************************************************************************/
   -- This function returns child nested tables associated with 
   -- a parent nested table object in a list format

  FUNCTION get_child_nested_tables(objn number)
                                   RETURN t_objlist;
  /*************************************************************************/

  /*************************************************************************
   **             Possible Exceptions                                     **
   ************************************************************************/
END DBMS_EXTENDED_TTS_CHECKS;
/

/***************************************************************************
 -- NAME
 --   dbms_tdb - Transportable DataBase
 -- DESCRIPTION
 --  This package is used to check if a database if ready to be
 --  transported.
 **************************************************************************/
CREATE OR REPLACE PACKAGE SYS.DBMS_TDB IS
  -- The following function is used to check if a database is ready to be
  -- transported to a target platform. If the database is not ready to 
  -- be transported and serveroutput is on, this function will give detailed
  -- description of the reason why the database cannot be transported and 
  -- possible ways to fix the problem. 
  --
  -- INPUT PARAMETERS:
  --   target_platform (IN): name of the target platform
  --
  -- RETURN:
  --   TRUE if the datababase is ready to be transported.
  --   FALSE otherwise. 
  --
  -- EXCEPTIONS:
  --   None.
  SKIP_NONE          constant number := 0;
  SKIP_INACCESSIBLE  constant number := 1;
  SKIP_OFFLINE       constant number := 2;
  SKIP_READONLY      constant number := 3;

  FUNCTION check_db(target_platform_name IN varchar2,
                    skip_option IN number) RETURN boolean;
  FUNCTION check_db(target_platform_name IN varchar2) RETURN boolean;
  FUNCTION check_db RETURN boolean;

  -- The following function is used to check if a database has external table, 
  -- directory or BFILE. It will use dbms_output.put_line to output
  -- the external objects and their owners. 
  --
  -- INPUT PARAMETERS:
  --   None. 
  --
  -- RETURN:
  --   TRUE if the datababase has external table, directory or BFILE. 
  --   FALSE otherwise.
  --
  -- EXCEPTIONS:
  --   None.
  FUNCTION check_external RETURN boolean;

  -- The following procedure is used in transport script to throw SQL 
  -- error so that the transport script can exit. 
  --
  -- INPUT PARAMETERS:
  --   should_exit (IN) whether to exit from transport script 
  --
  -- RETURN:
  --   None. 
  --
  -- EXCEPTIONS:
  --   ORA-9330
  PROCEDURE exit_transport_script(should_exit IN varchar2);

END;
/

GRANT EXECUTE ON SYS.DBMS_TDB TO dba;
