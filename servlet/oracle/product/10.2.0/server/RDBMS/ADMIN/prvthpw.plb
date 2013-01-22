/* WORKER header */
CREATE OR REPLACE PACKAGE kupw$worker wrapped 
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
1df 144
pMvXvSvOigi4yBs6PH5ZHFFhk/kwgxDMmEhqfHSKimSPUKjpt2P2G6Pg4Go8HYlU77f5tZbm
JtwvH6FI81ocQoDFUVilWXyhcSKc3bZ/Dl04oHBGWM/R8SfRMp4wN7m4zrkcaWqFr8iUG7hX
I7RVE6ToWXF6eyctb/0/99ep5AO1cnRt6luudQ/GXPZtOyOXWX0YAwL6OFb6dJLiP6BU1cnL
cxBYE/Iu+ULe8PffegFE+qYidS+W8HQ9cgUMFJeVCZYXtCnn/TxnF0JSAAj5QwLGVFCjSEXE
ga8lvQH/g3pyLm40EOT6hsaUwKTgww==

/
grant execute on SYS.KUPW$WORKER to public;
CREATE OR REPLACE VIEW sys.ku$_table_est_view (
                cols, rowcnt, avgrln, object_schema, object_name) AS
        SELECT  NVL(t.cols,0), NVL(t.rowcnt, 0), NVL(t.avgrln, 0), u.name,
                o.name
        FROM    SYS.OBJ$ O, SYS.TAB$ T, SYS.USER$ U
        WHERE   t.obj# = o.obj# AND
                o.owner# = u.user# AND
                (UID IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_table_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_partition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                partition_name) AS
        SELECT  NVL(t.cols,0), NVL(tp.rowcnt, 0), NVL(tp.avgrln, 0), u.name,
                ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, SYS.TABPART$ TP,
                SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tp.bo# AND
                ot.owner# = u.user# AND
                (UID IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'));
GRANT SELECT ON sys.ku$_partition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_subpartition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                subpartition_name) AS
        SELECT  NVL(t.cols,0), NVL(tp.rowcnt, 0), NVL(tp.avgrln, 0), u.name,
                ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, sys.tabcompart$ tcp, 
                SYS.TABSUBPART$ TP, SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tcp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tcp.bo# AND
                tp.pobj# = tcp.obj# and
                ot.owner# = u.user# AND
                (UID IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_subpartition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_view_status_view (
                status, owner, name) AS
        SELECT  o.status, u.name, o.name
        FROM    sys.obj$ o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# = 4 AND
                (UID IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_view_status_view TO PUBLIC
/
