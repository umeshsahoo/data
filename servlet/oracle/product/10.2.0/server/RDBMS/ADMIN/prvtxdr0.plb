/* drop objects */
drop view xdb.xdb$resource_view;
drop view xdb.xdb$rv;
declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
  if ct > 0 then
    execute immediate 'disassociate statistics from ' ||
                      'indextypes xdb.xdbhi_idxtyp force';
    execute immediate 'disassociate statistics from ' ||
                      'packages xdb.xdb_funcimpl force';
    execute immediate 'drop index xdb.xdbhi_idx';
  end if;
end;
/
drop indextype xdb.xdbhi_idxtyp force;
drop operator xdb.path force;
drop operator xdb.depth force;
drop operator xdb.abspath force;
drop operator xdb.under_path force;
drop operator xdb.equals_path force;
drop package xdb.xdb_ancop;
drop package xdb.xdb_funcimpl;
drop type xdb.xdbhi_im;
drop type xdb.path_array;
/*-----------------------------------------------------------------------*/
/*  LIBRARY                                                              */
/*-----------------------------------------------------------------------*/
create or replace library xdb.resource_view_lib wrapped 
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
91Fh1Ff3QHhYoxcrUcYF88XWl8Mwg04I9Z7AdBjD58CyMyiywJ/wKE71stD+CPUJ572esstS
Msy4dCvny1J0CPVhyaamVgt0yA==

/
create or replace library xdb.path_view_lib wrapped 
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
29 5d
CMapU7DnS/QjiEj5WPvQZTswNdUwg04I9Z7AdBjD57h0COMoTvWy0P4I9QnnvZ6yy1IyzLh0
K+fLUnQI9WHJpqb+mJlc

/
create or replace type xdb.path_linkinfo OID '00000000000000000000000000020117' wrapped 
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
6f 9e
7hWpG6MadrP3cj0+1Szc2Q28Ilswgy76f56pyo6mUMmuCIACQInAtSZrAcUb6bf+nek4DCAQ
Q9w502+67ZkTmQwUMGdu6oyeazaDr8Hb2FbJNTrKYDydJthOe49IPz4bMdE432t3fSGRNBac
X0u5+5XFiCc=

/
create or replace type xdb.path_array OID '00000000000000000000000000020154'
as varray(32000) of xdb.path_linkinfo
/
show errors;
grant execute on xdb.path_linkinfo to public;
grant execute on xdb.path_array to public;
create or replace type xdb.xdbhi_im OID '00000000000000000000000000020118' wrapped 
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
b44 33f
fbGBDHEan0XhvUEyyRDVXybf8wMwg80rLtCMfHRVx6oCKknFa/efrtXNPrJI+p7T7FdzVwi1
tZVX+xVhz1na64aL4bSLMT8/vVANNVOOmAkN5Rmm565jxWcj9sxeHqSjL8tHuZbyl1fdoWts
TKmclMGK/t+aNtW9CdMzQRCXEXwCw1sUY73Nh1r1yCbyreGGvWg97QepyyF1xHD3ND0OEO2E
mOcm9Tcf3swvyfIUDhErIyDAEUY7pG5GjWNLnZuy2wKSiaw6P5m/OnAqa01TbT3P8sbUuevi
2OMx7BvJq+V1PDEdAK/cOC4DaR4Aksme7dxGJVZbo2fEVhOiphQ5IUGuURiWcfwYVEjr5kH8
KNVxbvlZsujFh+yaeALOSPkHV0Ije4qP7lNLrRIAm7w/LDMzV/E6JS632PCVUYIcXGUcAIP2
oMtXSlZjl3Z/3aVpcIQBIyc2jXba70quYQEs6HbD5iw0V8paUFFgMG3tYS3EeE13/54S8M2j
9dS69M2h7r4BrijAK3H3Ic8cTBZ+o2DusoXGJWkMu/2YCxwgHHV35qE11ED/7XaEjYUdJm0/
66IjH3OAlFiH0ltRTkq5joLxBHW7Oizt1gPBP3bmApJnAZu/t2UJVUpIntuGKSFFVAEkRUYN
1w9rPB/0MpMKXjLcXK2/niQb/0+1PTqyMj9c9SpA+IizzfeRWN72/9G9qXJ+v066FUClrmXS
S/kt5zXHq+NYHAAOPMYkR7yxa2onT7+cRIfgqkK/vhcA9RO/nBKxSX4koQ3YX4SFvNSHzzoN
inNqVZ4y99YXWrR+teTOpj6Zxhc=

/
show errors;
create or replace type body xdb.xdbhi_im wrapped 
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
e
598 1de
EYKnoRFwcjQ+TyVlU5B1llrAecMwg2O3LkjWfC9gmIuOAx0Uiemn6UwEEvFZRN/CW+zYwLW6
dyQJjtPKoDhEC/a8/gQTlgDmC3dE/+Wts41FX3aRpkpEt0ZqDmy3s3CJGu9l3mASL9NMNWKt
OYJ8U20FAjLrz4xdadGEmaZtelSyI32roMireDAUkKdeB3JkWDmVoMNd+dpkyihsJZ5y+DRW
HvjIS2bwnzTH1tLP0dhRK3JdMmGPH/0MbawtylKMGAElW141ln7BcI4rQUZV6n8sgTAF/JrZ
W/YIEe2IkssXpJOgh3mNtBcHNS6v6k+0TieSdYnD5Rc9WD6ZeD1Vfqu2semNKnOswTkhD2v+
QPObsb2h2qA03RGhAF9nhnIWg1P+aA2KlguB/HrXk35vWjCWP2VhUzD7G54+aKD80MvM7k85
9EhVcH2NtMlLFksBfIIHtaQDokwXvFSq5OEV6QHi

/
show errors;
grant execute on xdb.xdbhi_im to public;
create or replace package XDB.XDB_FUNCIMPL wrapped 
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
29c 11f
uWG4peqUXpc5hxCiVwZLyLK8Sgowg9fxr54VfHRAAPiOrcWONWTaPd/irzsK3mZOd/6qmZgt
beMdr9YCXS/55PqA7NiYg2840sHAs31NrqRUjWccbmULiVGIiBYg+xsCUC81jIDR+vJ1mJ9f
iJvvLNS8t4DmHRy3NuODT/eyWRVWdL/Z0VQiiE3JLCwxMfalSk3/iJBfOcDXZ/M5jd4xhPBn
ApIyCs8pgwFtED1/GMBxntefAn3OStKk25Y+vN3dE4NIzXyqDDezneQVyU42QcdYuA==

/
show errors;
grant execute on XDB.XDB_FUNCIMPL to public ; 
create or replace package xdb.xdb_ancop wrapped 
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
551 11b
dGUCCgrzFloXmohOrBlf2obgSN0wgz3rLZ5qyi+mUP9zGP26yHRMgkx3YCbMswN1PrW1H1y6
e43x3KFERIFTEnb895q4iciVSw5D/x1gV+Fxt0MakETQGqdF2lIXyv8t2bdrMQw55iMJcOsh
hd2jcBqmv3RxOFNL7ItqULTCV68NYebJ3Fg1VtURmdHMY/UBxe19Jmhx187lUtG91hqOipha
nfFFAOIq9qrwzxzYp0h5hAszOsr2Wbc451e1cBnwwOOq0j2d9nibodWSah0mhq4h

/
show errors;
grant execute on xdb.xdb_ancop to public ; 
alter type xdb.xdbhi_im compile;
