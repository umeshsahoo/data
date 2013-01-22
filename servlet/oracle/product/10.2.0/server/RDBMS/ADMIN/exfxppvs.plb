/****************************************************************************/
/*** EXF$XPPOSARR : XPATH Tag position array and Value arrays             ***/
/****************************************************************************/
create or replace type exf$xpposlst is VARRAY(100) of NUMBER;
/
grant execute on exf$xpposlst to public;
/****************************************************************************/
/*** EXF$XP<type>LST - List of constants for the Tags                     ***/
/****************************************************************************/
create or replace type exf$xpvarclst is VARRAY(100) of VARCHAR2(500);
/
grant execute on exf$xpvarclst to public;
create or replace type exf$xpnumblst is VARRAY(100) of NUMBER;
/
grant execute on exf$xpnumblst to public;
create or replace type exf$xpdatelst is VARRAY(100) of DATE;
/
grant execute on exf$xpdatelst to public;
/****************************************************************************/
/*** EXF$XPTAGINFO - The information for all the Tags listed for an XML   ***/
/***                 type for an instance of the XMLType                  ***/
/****************************************************************************/
create or replace type exf$xptaginfo wrapped 
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
be ba
v5WLQvpE7gyBPhQ5rM+xQvpM1ZQwg5n0dLhcuPC4XvTn51L1/tLHTuq4dCulv5vAMsvMUI8J
aaYY1PitkkXFFkatOa0SVzmI3nX9EfwWqRpnI6/dlnex+irnVgSPLIq2duHTRnWe7tZjZzln
XcoJaSJUy5HhwnaJKKfHUnRS6afWmyo7iKZ0D2It

/
show errors;
grant execute on exf$xptaginfo to public;
create or replace type exf$xptagsinfo as VARRAY(490) of exf$xptaginfo;
/
grant execute on exf$xptagsinfo to public;
/****************************************************************************/
/*** EXF$GETDUMMYTAGS- This gets the dummy tags when the LOB attribute is ***/
/***                   NULL                                               ***/
/****************************************************************************/
create or replace procedure getDummyTags wrapped 
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
7
2a1 1a5
XXVYPHn5hPRzuFgbkSaHUtYaZ1Awg43M+txqfC9DbmQEvcv0q8UV901bSUGgNQhRLR0ptbXn
gmGYuFHOkXKb3xLA7/yNL0oEgSdHreULqSM8EzKmA0SY7PsmO4/ujOAU9pH+DLMwCdIZFSQ8
k6lm8TLEYN15IzE04+zNXatpN2vUjazvBJhW0lF/gg+T/XWEG8tTjwQ3ODDKj4u6MM0E8lMG
Me9ZXVlRm0ajQF+bpRDmFWZogBvAasGCdsrMxQo4ggzmXaPJnxr3cFcf6JP+PZVyCaIVxvsZ
kifd7/1duRQiPJG/isCKlQfecFL/6sRZM1PpoL3SOdkwQ0UeudoyJt9lUi7M5thYIKpPAjQM
06rkx9QI0VaoPC66GdPOZKxU1wKAj1e4WevwfRfW+r8P9D2wLDalpwY=

/
show errors;
/****************************************************************************/
/*** EXF$GETTAGSARRPS- PL/SQL implementation of the get tags array - to   ***/
/***     get the info about the tags in the current document              ***/
/****************************************************************************/
/****************************************************************************/
/*** EXF$GETTAGSARROCI- OCI Implementation of the Get Tags array - to get ***/
/***     the info about the tags in the current document                  ***/
/****************************************************************************/
create or replace procedure getTagsArrOCI wrapped 
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
7
fd 103
B0Lq9mskPmsawbScpWBZNMK43NMwg+lKf8vWfC82XviU1YnhFOreXqTUBAxwjIZabhi1tWYX
44lIDRn9cpcxOjgX0I/pFn7bg6KgUhY+jND0zsfbFCIwYXymWkbrrB8tE+MsbwFYB4qPi2i6
FoTz471CH85lGdmjvn/wvh15YNoIbhHf6CXTYhzwuUq4shOD/y0Xc1MZbcnWv4m90QqA89aN
VHKOA2s7TprWOzqOxKqzgocYFzQ2skXBzZkoTQDr

/
show errors;
create or replace function getTagsArray wrapped 
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
1fb 154
OGKSMRtYkoAwnUbnoMmyDBmtewwwg/D32stqyi+iXscYYgm08UNmAWmedPZbvafnuJGatWaT
rE73jWaOhYNyNIh6/xoDsja2i9joGuDD1SE8Vo6pySRwimdDdvpqTOkQXAh3vc7+VhlYDqg7
JsFyNBlLlC9/cvemnAhTaJ53JQRnbKdDb9q0xP+cTGPebCgecMiIPQE+fBUC+yEPCXRXkwZR
pGsxfrTbav8NyGRapVmvLdeKc6OJ9vzqaEiCTqJrDBZhZ0SvSuXJcuECv+ri7CMd2bQoj5pa
QPE4fzqbvnNBDs0/CiW8Ydk6irG/Yq6HWxqPSnp6pgtav6w=

/
show errors;
grant execute on getTagsArray to public;
/**************************************************************************/
/***                Functions for dumping debug information             ***/
/**************************************************************************/
create or replace function v02c wrapped 
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
177 13c
BmwpkdU5I4+PCPplfcQKDsnnux8wgzJpDEgdqHTNI9zu6WN8CVwu60zMb0bsNvo397KMiiP3
rc+yOhYmw9/fcj8s5yo608esAYMjfH9yhanBpSNBwVYUATbUCZMfdviMhmKiiA43uAdHwSHw
K8wPk2XWtaYDUyRlkOiAyFAfpVj8PnNWSsXmj8+sBjNGcDS3JbTcQUR3cNAHdeKLD9pajYXL
IyjXA2XbGjyceF9nrXJVfzl88PNjgmAWgFmcVnhsbJ0kOcIQXxTONLGXRUgZ3x6SKGwQCg8e
urFm0qmxlnfgW6S0nA9j26Mn

/
show errors;
create or replace function v12c wrapped 
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
17a 13c
74xEohQjOBhAGqRyys3zFLHURrcwgzJp10jhqC+5Qk8G2nWFG/DMEtUp+ykOFOcT+98Zz/cQ
MFugLio+nDpzPznqjGIi6UeY7QKb3mY5TGj8ZddAeYUBNl4mVv0JT3S77k6pPNsgDBB+xIyn
4jtutmq5DslOl+tSm2VEwkTfAiNKsTFG8rhu/xaLL+eX7HGraF0fOfdXULPGB+TBH+CyNSgJ
mOijiCIYznNf86hjJgwjWz0vIr/b48BRMHhOahSP1w+ARdA+kSMZ9jiTPLseATpb053pZENi
9m9Fr8ZJ8lDWdNIFsmS/uog=

/
show errors;
create or replace function v22c wrapped 
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
17a 140
8/D6zLmYIff5JCJ6I7baNHzDudwwgzJp19xqfHSLaLCl+94mRlAWeFGkJY9LWuJeraEN/ZYl
B8b6OayhXeDBA51PFMMzbBtAeex6dXUrjt0MMDTYcZxYwIg1S8Ozskn5ipGsdVsRyuRni4Ew
djtRvPLc4flER4u5MnuurmDmD91J5ZmqSErF5sigZ1KCqAS7wN71nLuOd+DU0IV4+MS2uGzC
1hmExzvh9z3kkl/zFmMNutSm6H/guV/zl4g6q4u6ofpynbYxImCXzr9kjRAkeqQzcyyenQoP
HrqxZtKpxK534FuktAeW24m6Vg==

/
show errors;
create or replace function v32c wrapped 
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
17a 140
0w1OabcQPrYFBWmS/AzhCfvp4p4wgzLIr0jhqC9AEhmwzigukbfoLSPVCKlXw9NG16b9IBD3
EM7LEfDshQFAWDrB+K89EW2u806fC2vP7OM1F/4/QcvoaYUBNl4mVrZAzbOlOSIoEelo8ieY
h9Cj5WHA3HT4RCoTwQBMSUleyrpwXk2wztoTab1K672Vih01k7cMtxPkoDUvEpIICBi1Gag8
L9LKv7FNje6M3ZZyBPMJ7Hsl2k3opb7VYInvlW1YtS5m+TS/GhK6S9JXsRXC2CIr2Zvm0ygV
9kLZ7AJIpZL009LKsnMzW0Ysowg=

/
show errors;
create or replace procedure exf$xpdumptagsinfo wrapped 
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
7
2a4 191
NPCn/8i+YT5EH2w4qkOljJE8RPUwgwLxcvbWfI7GvzNkMAc3IxFUmLoBWy4GFhHTWWZVoXqJ
qNjNVFU4jyydHzJHO+ksNhnQu/62hW3FFENHb3bOIu2a1cnHAQYX7bYmRt0Bho+wiObYAKbF
dOcTSTTjSxXuZEcmZpbudab/CZPSJ9g8Z+PrJ+ZjlSsbY+aVj5oigYymDTh3v5PxHvKjjNio
MOV+SVc2+Serj7+ke0X/ByRzjSQdvc9enaxN0Ft9Cx4WMK2vXvRXwW2HToE/QxDMTiIyvCF5
xyKvusfeWw86S2u59/Txe+sbboGcgVtQtqNJ+YF9loas0eHbwQieS4j7SJxtpivEW4B14RyA
pm2yD6bkmlXwBGHURB61YF04b1UQHdGcO+I=

/
grant execute on exf$xpdumptagsinfo to public;
