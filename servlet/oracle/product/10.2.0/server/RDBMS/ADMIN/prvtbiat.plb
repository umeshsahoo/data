CREATE OR REPLACE VIEW  DBA_CACHEABLE_NONTABLE_OBJECTS
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS
SELECT u.username owner, u.username object_name, 'USER'
FROM   dba_users u
WHERE  u.username NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'ORDSYS', 'CTXSYS', 
                          'MDSYS', 'ORDPLUGINS', 'PUBLIC','DBSNMP',
                          'AURORA$JIS$UTILITY$', 'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
UNION ALL
SELECT o.owner, o.object_name, o.object_type
FROM   dba_objects o
WHERE  owner NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'ORDSYS', 'CTXSYS', 
                     'MDSYS', 'ORDPLUGINS', 'PUBLIC','DBSNMP',
                          'AURORA$JIS$UTILITY$', 'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
        AND
        ((object_type = 'VIEW'
            AND NOT EXISTS (SELECT 1 FROM dba_snapshots s
                            WHERE  s.owner = o.owner
                            AND    s.name  = o.object_name))
        OR 
        (object_type IN ('TYPE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'SEQUENCE')))
MINUS
SELECT r.sname, r.oname, r.type
 FROM  dba_repgenerated r
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_TABLES_BASE
(OWNER, TABLE_NAME, TEMPORARY, PROPERTY)
AS SELECT u.name, o.name, decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
         tab.property
   FROM   sys.user$ u, 
          sys.obj$ o, 
          (SELECT t.obj#, t.property 
           FROM   sys.tab$ t
           WHERE  /* Exclude the following tables
                   * 0x00008000    FILE columns
                   * 0x00020000    AQ table
                   * 0x08000000    sub-object
                   */
                  bitand(t.property,134381568) = 0 
             AND  
                  /* Exclude tables with LONG columns */
                  NOT EXISTS (SELECT 1 FROM   sys.col$ c
                              WHERE  t.obj# = c.obj#
                              AND  c.type# IN (8, 24) /* DTYLNG,DTYLBI */)) tab
   WHERE  o.owner# = u.user#
     AND  o.obj#   = tab.obj#
     AND  
          /* Exclude SYS,SYSTEM,ORDSYS,CTXSYS,MDSYS,ORDPLUGINS,OUTLN tables */
          u.name NOT IN ('SYS', 'SYSTEM', 'ORDSYS', 'CTXSYS', 'MDSYS', 
                         'ORDPLUGINS', 'OUTLN', 'DBSNMP','AURORA$JIS$UTILITY$',
                          'AURORA$ORB$UNAUTHENTICATED',
                          'LBACSYS', 'OSE$HTTP$ADMIN', 'ICPB', 'TRACESVR',
                          'XDB', 'PERFSTAT', 'RMAIL')
     AND 
          /* Exclude snapshot and updatable snapshot log container tables */
          NOT EXISTS (SELECT 1 FROM sys.snap$ s
                      WHERE  s.sowner = u.name
                        AND ((s.tname = o.name) OR (s.uslog = o.name)))
     AND 
          /* Exclude snapshot log container tables */
          NOT EXISTS (SELECT 1 from sys.mlog$ m
                      WHERE  m.mowner = u.name
                        AND  m.log    = o.name)
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_TABLES
(OWNER, TABLE_NAME)
AS SELECT t.owner, t.table_name 
   FROM   dba_cacheable_tables_base t
   WHERE  temporary = 'N'
          /* Exclude the following tables
                  - * 0x00000001    typed tables
                  - * 0x00000002    having ADT cols
                  - * 0x00000004    having nested table columns
                  - * 0x00000008    having REF cols
                  - * 0x00000010    having array cols
                  - * 0x00002000    nested table
                  - * 0x01000000    user-defined REF columns
         */
    AND   bitand(t.property,16785439) = 0  
/
create or replace public synonym DBA_CACHEABLE_TABLES for DBA_CACHEABLE_TABLES
/
grant select on DBA_CACHEABLE_TABLES to select_catalog_role
/
CREATE OR REPLACE VIEW DBA_CACHEABLE_OBJECTS_BASE
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS 
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE
FROM   dba_cacheable_nontable_objects
UNION ALL
SELECT t.owner, t.table_name object_name, 
       decode(t.temporary, 'Y', 'TEMP TABLE', 'TABLE')
FROM   dba_cacheable_tables_base t
/
create or replace public synonym DBA_CACHEABLE_OBJECTS_BASE
   for DBA_CACHEABLE_OBJECTS_BASE
/
grant select on DBA_CACHEABLE_OBJECTS_BASE to select_catalog_role
/
CREATE OR REPLACE VIEW  DBA_CACHEABLE_OBJECTS
(OWNER, OBJECT_NAME, OBJECT_TYPE)
AS
SELECT * FROM dba_cacheable_nontable_objects o
WHERE o.object_type != 'TYPE'
UNION ALL
SELECT t.owner, t.table_name object_name, 
       decode(t.temporary, 'Y', 'TEMP TABLE', 'TABLE')
FROM   dba_cacheable_tables_base t
WHERE  /* Exclude the following tables
                  - * 0x00000001    typed tables
                  - * 0x00000002    having ADT cols
                  - * 0x00000004    having nested table columns
                  - * 0x00000008    having REF cols
                  - * 0x00000010    having array cols
                  - * 0x00002000    nested table
                  - * 0x01000000    user-defined REF columns
         */
     bitand(t.property,16785439) = 0  
/
create or replace public synonym DBA_CACHEABLE_OBJECTS
   for DBA_CACHEABLE_OBJECTS
/
grant select on DBA_CACHEABLE_OBJECTS to select_catalog_role
/
CREATE OR REPLACE PACKAGE dbms_ias_template_utl wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
22c 107
0PVQR7l7TLcRzde164kUa8DZBA0wgzvxmJ5qfHTp2sHVIWFQJguEW5UrCV7G36dxfV21tW2D
EC/hstfIbdQSFMsWDkXuZw6Y9wM1/+YLSxaJt1R8aCGmAcgs3EOOIZ6fp/JtlVP7Dk4Z03tX
Dw6A2Xffjeez1SU+001aMpNVR2ARJNruuBR8y7kEPZSGKVRQQ8P58M8Dqy5ZUvNELgAb1WQ8
a3MEtU9YsEoifnCtreI2GwOyX+WOrXP4iINVtvz/x8Q=

/
CREATE OR REPLACE PACKAGE BODY dbms_ias_template_utl wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
987 378
yRIz6VUOhMoXa6Tg5TClh2sdsZEwg5UrLtCDfC/NrZ0VB/KpRlGnh+Xpdl8AqT3boXmwuiP0
aRNq8lWfRNLU0GTNV1JZFRglO6u9+lhYwTo/qMZdHYcdo8n1bX1ljWxqwsPIi70raW/FNVRg
8+a+hedQ5qZm4V+XtKHocHamV9z7f0oiODXfVEfoqyM6f86rJXrqhJm9BmaOzFTuZsw8J6x1
Ib2Jc2f9+AiYeLe+DQjzDUXEA/7cKRBBHd736LofxvFSVmFshp48yl9vRo/pGNIg3jajwkYq
ht8kusf7ra+Xw9q8HxvhbHw3CH0evIOkCps4vxYoKMb8y/DXCFQAIhB4myyYxid7e5CK6e8L
zG0/pOXtAC5vCzu5QxB78HTY1z3tgDVMDbhlwvqoCn3p1Twy2zZOX4KstjNE1Bdq8/7PeEyk
EcZ3lE45eHnF+SOWJ6swau15KuTth5FqDcCa3OqwyWa5bwBPGsgnb9qAefmft0AnJdE1scfI
h6p5eT1jFeXIXgAyoQYlB3I2wJVlGTZCnftKZQ37qPdlF3dFHuiRLYF0HkZdxkaRjoukbLoq
koe8f2KbFEcDIUA8kPQ7EigU08jdWTnEHbCD1px9v/7grsx5UjxFQlqjw5E6mWmnsAfV+0Fl
QYxJ0mQ6PlU8WmAgcGsg+E+utZzW+amprGDGcrnrmi9pfYtjfUk0gZ6bLZ69vS8CFaQLIeUk
GMUe9ZqXK2YM92jysuMeEYcHmeX6Z2BKLNK5FibXK+Fdi356H4TpoGfYHwlq5KDRRWwp7M5Y
TPVO9i4nq/YwQ+HZvr2I6KO6d8gREDXs7qvoYEGNjtVx4sIVohLckwCS9XdDBD596KejMVAP
2DoKmmG+ICM=

/
create or replace package body sys.dbms_ias_template wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
39a3 e0d
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
tgv2ub/onTpJjkRaUA==

/
CREATE OR REPLACE PACKAGE dbms_ias_template_internal wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
174 db
f99WHnsVm0f4AlK8rhWlwUmHDBEwg43ILZ5qfHSi2sHVIWFQJvYb6SJx61TfwoM9tbUfLsoM
b+uesqyGpL/lVpZKDktdPLbEuYUyAYCu/HxDjQkTG1En6S8ZOdNq4tq6Rv6ndrGGy4o0uB1s
YygTejEc/vCk/6/y+oj80h/V6ZTCArgMq66KeRle0DNoxVQmnZ+DNIC8UHzOwc864YdWaVU=


/
grant execute on dbms_ias_template_internal to execute_catalog_role
/
CREATE OR REPLACE PACKAGE BODY dbms_ias_template_internal wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
7ab 33f
aCm7y2gJr7MnOfBMBXd26cKJJyIwg1VcLiCDZy/NWA9/jQk4DIXTboPKxWIer9gnu3uYHqbt
2BYtUXbhlAj3LJqBg8twaBRxI02WYcELwdcTQp/yfSjTqFnpU6y47BZq42WrtyEbq7KGq2xJ
f3w9HvsaCWl0gvRnbKc/LpFGgxboswpPhFH6iRY21O5BWntJwCFLviCHMtGUoaxxaly+w7hK
d6xQ8Qh9VrHEvm++8KhxuOtgtEZCarN4LEhJ3QNXHAWlPmBfmEVK0/Q+bIORe8tv8Y15DOaz
HiAzOkWFLi0ZJIsCQkLFm7ql/MQHMi35DT/6W3Nqr5B3ZKQTVU7HvGI5E1WfEyB+oy2qgyKS
tnI5YaYcy3Ox0sdAJ3JCHjx9/nNScpUPDpzMPTeMrMzTA08fgv3dEpGxib+zranx1Oubfjl/
m1pysIcXQCiaB4xkDsGFHkXLS6M+1gmeiFoVjqe7n6jVt7+DCeMhy9LFlYg4Le6TZc4E5O+Q
ZFrU0bZCETXQrnuPnmNheGIOrPPDDSBKqyZKCYcq6McKODjX3hPYSmsrYU5Ykv+frgZ0Hp6y
SuglLh3dTamGCQW07EC5Pj28mXM5THBFBqOmVd1SoX89WbhUtDjmdWPUBnxheoao0Q+Aissy
XmKh0Sm8VnAoevh3RgkaLHNQcT7OYLs4pxTVCvmRGJuecySKv52aK6psHuJEzhfgc5oNo1IH
fydGWI76EntEXJRhbSecDETNpFj1gouek/F3TOTpGESUWHOuEEHdUMzhgGakKN0C2SGC/R/f
mIdqYiwFDHmk/+SxJKXO6yyWvymW

/
