/******************************************************************************
 HA ALERT ATTRIBUTES
 Fast Application Notification (FAN) defines a number of event attributes,
 some of which apply to all events, and others which apply only to certain
 events. Here, the attributes are listed along with the relevant events. Also,
 any notes on their usage (especially during submission) are included. More
 details on these events and attributes can be found in the FAN document listed
 in the RELATED DOCUMENTS section.
  HOST_NAME
  Used by: Node down, and instance, service member, service preconnect, and ASM
           instance up/down events
  Required: no default value
  DATABASE_DOMAIN
  Used by: All events except node down
  Default if unspecified at submission: domain of current database
  DATABASE_UNIQUE_NAME
  Used by: All events except node down
  Default if unspecified at submission: db_unique_name of current database
  INSTANCE_NAME
  Used by: Instance, service member, service preconnect, and ASM instance
           up/down events
  Required: no default value
  SERVICE_NAME
  Used by: Service, service member, and service preconnect up/down events
  Required: no default value
  INCARNATION
  Used by: node down
  Required: no default value
  CARDINALITY
  Used by: Service member up
  Required: no default value
******************************************************************************/
CREATE OR REPLACE LIBRARY DBMS_HA_ALERT_LIB wrapped 
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
16
2d 65
rC5gRJkLC5DbiamH5wCrjNGiPcYwg04I9Z7AdBjDuFKbskr+uF+/0lKynvT+CPUJ572esstS
Msy4dCvny1J0CPVhyaamFm50xw==

/
CREATE OR REPLACE PACKAGE dbms_ha_alerts wrapped 
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
2e3 130
5gGYSCz6Ic7zq411pxDD3of+0m0wg2PxNdzbfHTpk3I+NEZiBZO++rANdVeVUm2XG/6dRFjh
73/WL54PKxQM+XL0kFhqgtAOVxoJSeLPrEKo0VtRx8+2s+tRr2zV8KWjcAo2UAe5v9XNF4F5
1B2Iz39jjWJZftDG9qkRUjyW5lvKyzLMQpNpjbaSpn9Jb83tr4lt6+lMgud+lxIZRBEzFpdJ
CM3q3VAYfvZzdu+KOdaUg3bxpU6EIj7BrGGgIesKzqCw0qeUeHodnNi1BEee1cCo5LK4qdQK
ZM80EltOPe0s

/
CREATE OR REPLACE PACKAGE BODY dbms_ha_alerts wrapped 
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
c8c 2f6
Do4Kn9Z4WYQjI1xfiIOIqXv0tN0wgz2czCCDfC+p/kdkS5J38npZ60Erza9SSK+rbljNULMf
1dYR12Bq8gkac/iQt4lnFo3onsPc44/a+M/+Kblm1HHPQ/NLZwJebznvhjloCKgR9gR4ANTk
xm2qfDNsYDhj5m83MjnSop5wDXErsFSBzYr1dOpZ1vAqwr2x4N2BWxvtaqjGFjPqnp3IN4tF
xwPvYjHI0KlM5PkynJhP3ikY9Q3/ySb4AxYcbx+Rnfef3UbmmZpiYsZx6/uZg3Hflz+kWU5w
04Q+U1zsiAoLNZIbvPBrmgsFJXUHqfNVjoz38+ZaBQWMXaHg9TLtxht0cV+bunT/sFJ+304s
uX9yHBxenEn+IJTMXAzayBSr2QgmrEqyPtltZfoXwdYHJxbD79EIFDBNQIvZ+BTZchpqOZe0
POstKWhibZtfkvK48DSjT1FkyfrFrpd+WE+yqAa28l2E3rCW054Rt0HTaZnzfbFSZvJOVq5v
kzr+524Gj4Ze6As7NkYtQMVcdaYJK8A2uxN69t7Ulys8pBWk3nPDF1xZSuQYYM4RccHMiCCU
053q9/Kx3odFZfhy6jFIzrJhEDGsS4ADvxYBbJGFYs6ac6Rq1JUDMug3/QKwqwkKIT7/Tb1J
jvRoUK3fbjJFxRnO4/zhJ9mKfG6EYlRqg2IG1hIkEMnJJ9/JLNym99uDagNeGp1DUxidLlMq
MABwtAhnu5tBsbn5VVM//iiglOlw

/
CREATE OR REPLACE PACKAGE dbms_ha_alerts_prvt wrapped 
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
90f 2c9
a2Z7S9LmfQxbHUWMTPjesAC9Pyowgw0rr0qMfHRVgg/3urreoAftM5HTxKKyyx5Xip/ROrWd
tKaknu+XoF885uWrlSidH/gCOdJE/01ZkwfDNeEHVqgqaBisaRY9ALXaiSe09iH3zCoihVSF
QfOssJHw7EBjaxmpaGYouqpv/IEE7rc0O11bTX+9HURQ4ADwXIkZ2jaj2T1CHUm7R2noI2yx
qWe9+7cIKlRFwWHdReH5Y3RBynsxFQBxhCVBNrWXPx8DiVrNuXmZJSGf6DRcmNp66WLxc6R/
zKcw9+xRfWir8WPKZ5IdBi1aD2YyzZEkHXnm5UUbQWpNO4ohfK/tHt/vOG0U3n3O6Rpkt5X/
iENdSD4eD3j80I3ltQoZAO78Wqb9DI/YccFwAYdD9sK+PnKFlmX4XfOkHJVFz/uwYDgKXpnR
Br+4e/PPiX6uQrxZzt8kurERVufo/ZvjeFSF5xR26gKWAzFPMYBlJnhoLxymkN0CXBpwcjqm
Ehu+2lVGBm1sWLRXCoLEyOQBPJkMbKRKajJ/erBaeNq5lvCz5+C38Exmmrr4VEdhHp6BY5iR
BNbQbgJUWVMP8tb00JYE6zNtywCQPg0VEMVq8aRI3ZMhakkXz9NthiITM8G4HJVo1Zsm3J2C
G0kqJfokVi2hC/uhGf7rldw1eo78hsosOgm15eH6VhAIdqrkHTTQhWA=

/
CREATE OR REPLACE PACKAGE BODY dbms_ha_alerts_prvt wrapped 
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
3fff f6a
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
j1c=

/
