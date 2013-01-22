CREATE or REPLACE PACKAGE BODY dbms_frequent_itemset wrapped 
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
2b 61
Z8YRhJJxVwSdQT5kDw2qnSQfigQwg5m49TOf9b9cuJu/9MO4UpuySr+ZwLJ0MoGZ9P50UoGy
n7LMuHSLwIHHLcmmpjmUmYk=

/
CREATE OR REPLACE TYPE ORA_DM_Tree_Node wrapped 
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
d
ef e3
XZbEghTLwgM0hB0QcU3MNtI2EVQwg0zwmMsVfHTpk7dkpbTypGZwC8D9CmInHMBVyujktQ8O
NhaUGbm+RcabXzY3f7qcAvTCKKem6udzkDk3YICRmwktCZcg4km59ddEipHw2Va7prVX7vGx
YmBEneHptIwKPEZ6WYXBi+CD3JbuzDlKUCyi63rcRLryD7HMXMWI2Uljj8eYMydf3jIS2u2m
qjOtHw==

/
CREATE OR REPLACE TYPE ORA_DM_Tree_Nodes AS
  TABLE OF ORA_DM_Tree_Node;
/
CREATE or REPLACE FUNCTION ORA_FI_DECISION_TREE_HORIZ wrapped 
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
8
252 150
oFsDazsw5bpDKT08aDU4QuNjIj8wg433r9xqfHRArf4+z3bTW9v3GITsUwpj2/R2WzuYznOa
rIny66b7EyjMis5Ou7THC2SJiMJXE/rhI+VVeJSiusJQOnymz4dHeCaTj+Dbc032Kq9CqhL8
vonytiU90+XInf8QvwYfSZYvuJ9ixbhtUguObJPAsOIP9ToJT7rsaT+o40TtPdOhIBsYsdr0
LtbHZ1MMht8VweVzwRAJSc72wiTdZoljFXj4W3YcNWkTivjL3g9OPN4CBtuV47PIVY7znpRf
2wSpJ7GZYmMNsep6UV9qRoAGDM6BskHG+61fKCzNe7f3

/
CREATE or REPLACE PUBLIC SYNONYM ORA_DM_Tree_Nodes  for sys.ORA_DM_Tree_Nodes;
CREATE or REPLACE PUBLIC SYNONYM ORA_FI_DECISION_TREE_HORIZ
  for sys.ORA_FI_DECISION_TREE_HORIZ;
grant execute on ORA_DM_Tree_Nodes  to PUBLIC;
grant execute on ORA_FI_DECISION_TREE_HORIZ to PUBLIC;
