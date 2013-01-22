--
-- Copyright (c) Oracle Corporation 2003.  All Rights Reserved.
--
-- NAME
--   helpbld.sql
--
-- DESCRIPTION
--   Invoke and execute the script to loads the SQL*Plus HELP system and
--   upon completion, exit the SQL*Plus connection
--

@@&1/hlpbld.sql &2
exit
