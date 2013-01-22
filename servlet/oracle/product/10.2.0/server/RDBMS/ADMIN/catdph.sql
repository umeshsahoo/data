Rem
Rem $Header: catdph.sql 15-oct-2004.15:54:05 dgagne Exp $
Rem
Rem catdph.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catdph.sql -  Main install script for all DataPump header components
Rem
Rem    DESCRIPTION
Rem     The DataPump is all the infrastructure required for new server-based
Rem     data movement utilities. This script handles the installation of all
Rem     of the header components.  catproc.sql will invoke this script
Rem     (catdph.sql) first and then invoke catdpb.sql (for package bodies)
Rem     later.
Rem
Rem    NOTES
Rem     1. Ordering of operations within this file:
Rem        a. Drop types
Rem        b. Separate type definitions
Rem        c. Package definitions (headers... may incl. types assoc withheader)
Rem     2. catnodp.sql drops all DataPump components. catnodpt.sql which drops
Rem        just the DataPump's type definitions is invoked
Rem        from catnodp and is the only 'drop' script invoked here in the
Rem        install script. This is necessary because CREATE OR REPLACE on
Rem        types does not work if there are dependencies on the type.
Rem     3. Please note inter-module dependencies (both internal and external
Rem        to catdp) and ordering, particularly between header files.
Rem        Ordering between bodies and headers is less critical since the
Rem        migration team is working on a plan to separate load of headers and
Rem        bodies into distinct phases.
Rem     4. When adding components to this file, remember to:
Rem        Update catnodp.sql, ship_it, getcat.tsc, tkdp2pfg.tsc, tkdpsuit.tsc,
Rem        tkdppfr.sql and tkdp2rst.tsc. (The last four are used for PL/SQL 
Rem        code coverage.)
Rem        Also consider upgrade/downgrade
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dgagne      10/15/04 - dgagne_split_catdp
Rem    dgagne      10/04/04 - Created
Rem

-- First drop all types FORCE. Don't have to drop other object types as
-- CREATE OR REPLACE works for them.
@@catnodpt.sql

-------------------------------------------------------------------------
---     Separate type definitions go here. It is also OK to include public
---     type defs in scripts that contain package header defs rather than
---     isolating them here.
-------------------------------------------------------------------------


-------------------------------------------------------------------------
---     Public and private package headers go here. Type defs can be included
---     in these files as long as creation ordering dependencies are obeyed.
-------------------------------------------------------------------------

-- Metadata API public package header and type defs
@@dbmsmeta.sql

-- Metadata API private definer's rights package header
@@dbmsmeti.sql

-- Metadata API private utility package header and type defs
@@dbmsmetu.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types
@@dbmsmetb.sql

-- Metadata API private package header and type defs for building 
--  heterogeneous object types used by Data Pump
@@dbmsmetd.sql

-- Metadata API type and view defs for object view of dictionary
-- Dependent on dbmsmetu
@@catmeta.sql

-- DBMS_DATAPUMP public package header and type definitions
@@dbmsdp.sql

-- KUPV$FT private package header (depends on types in dbmsdp.sql)
@@prvthpv.plb

-- KUPCC private types and constants (depends on types in dbmsdp.sql
--                                    and routines in prvtbpv)
@@prvtkupc.plb

-- KUPC$QUEUE invoker's private package header (depends on types in prvtkupc)
@@prvthpc.plb

-- KUPC$QUEUE_INT definer's private package header (depends on prvtkupc)
@@prvthpci.plb

-- KUPW$WORKER private package header (depends on types in prvtkupc.plb)
@@prvthpw.plb

-- KUPM$MCP private package header  (depends on types in prvtkupc.plb)
@@prvthpm.plb

-- KUPF$FILE_INT private package header
@@prvthpfi.plb

-- KUPF$FILE private package header
@@prvthpf.plb

-- KUPP$PROC private package header
@@prvthpp.plb

-- KUPD$DATA invoker's private package header
@@prvthpd.plb

-- KUPD$DATA_INT private package header
@@prvthpdi.plb

-- KUPV$FT_INT private package header
@@prvthpvi.plb


