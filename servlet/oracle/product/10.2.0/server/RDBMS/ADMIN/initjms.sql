Rem
Rem $Header: initjms.sql 03-aug-2005.16:05:17 qialiu Exp $
Rem
Rem initaqjms.sql
Rem
Rem Copyright (c) 1999, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initaqjms.sql - script used to load AQ/JMS jar files into the database
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qialiu      08/03/05 - move prvtaqal to initjms.sql 
Rem    rburns      12/03/01 - remove echo
Rem    rbhyrava    09/07/00 - use one loadjava call
Rem    rbhyrava    04/07/00 - call only once
Rem    bnainani    10/22/99 - script to load JMS/AQ jar files
Rem    bnainani    10/22/99 - Created
Rem
call sys.dbms_java.loadjava('-v -f -r -s -g public rdbms/jlib/jmscommon.jar');
call sys.dbms_java.loadjava('-v -f -r -s -g public rdbms/jlib/aqapi.jar');

@@prvtaqal.plb
