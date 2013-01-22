create or replace package xdb.XDB_RVTRIG_PKG wrapped 
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
11d d2
e7L5J9C9fKiefHIEHX1UEiLsvrcwg5DIf8sVfC82Jk4YYtaOzFDoZTP6YdOK65CkbI21tZkJ
UKkmEeraAyXCLW0IRlUA7H7pUSA0MHWj5vVLXEYJ3lyhL5RqpkuRDOKe7lXQoYCoAhwjBU/2
rXUbSz77E/P9X2hkTq5Qs5IsVDHwvjIR/O9dM6huuJK435iI8rkeRjqb4etbDJA=

/
show errors;
create or replace public synonym xdb_rvtrig_pkg for xdb.xdb_rvtrig_pkg;
grant execute on xdb.xdb_rvtrig_pkg to public;
create or replace trigger xdb.xdb_rv_trig INSTEAD OF insert or delete or update
on xdb.resource_view for each row 
begin 
  if inserting then 
    xdb_rvtrig_pkg.rvtrig_ins(:new.res, :new.any_path);

    
  end if;

  if deleting then 
     xdb_rvtrig_pkg.rvtrig_del(:old.res, :old.any_path);

    
  end if;

  if updating then 
     xdb_rvtrig_pkg.rvtrig_upd(:old.res,    :new.res,
                               :old.any_path,   :new.any_path );
  end if;
end;
/
show errors;
create or replace package body XDB.XDB_FUNCIMPL wrapped 
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
5fd 1d2
8PekypcLVZmDY/LMeVSF6l84uhkwgz1erydqfHRVvg+oIyevjkX2rko7G+BKkPqfE0Gbtap/
rfqDjXkCLcw8Z3SnQU+BQV3cEx9M78OvQQ7EPUtyGWkFrVBS+2mf9KwHimKbUCl3X+OUC0Yw
GBO8Mil3a+FtTCfdwWHmK2mpf392IRNgTgPhqPgz7wDARPbjXUEZGoc1iZSFhIUmjmH3nWs3
gwXDUrv8vhgNjwReySRbqeCtHqBkx7N+3R5vOEIrKl+/Vq/MleyAJN9mIZHfV3bn0NaRRu5a
Zj02T0uuZo0CbKiAVKFIy9Bcl5Ncb/c4+n2OMHSuK0SEu0guN5lafAM3H0mkknsqnHMqbN5c
cXpbNcoxWVzb0J8/jR/Zd5FoKil+Gb5QgUhSCxRhTxcGF16lnAulmK20Gd4vHA76zuwNmIG5
LNjGt0HaIjOqgwvSn/7SOTPCx1Y=

/
show errors;
create or replace function xdb.contentSchemaIs wrapped 
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
1eb 13c
ovGqVibqzHHAVp3OqkcotAfZDmMwg43ILUhqfHSi2v7V41m9cJF9g6ErtHWpokQUjbS3tbWW
5VQJJ/Vt35v1W7z4+orw09aufoXoPxV9WtCsntsObUHBBH6+7qZPpRnZ00GIv0k/wJsqNB7G
qVIsuIPhNmKZHcFXUX79Cd0xabREcB/zy/DJO1fVKfvh8AaRNzplQZlxlwZS7bYiPFHDoFsx
w211skjc8sOhPcUcBYEuqg3MwjlNeUyF2gwlrU/ODhvbsWvL+zonXv35+f5N8MT9YWv9o7a1
smRlnwkPbK6YGNyaLJ3Ht35/

/
show errors;
grant execute on xdb.contentSchemaIs to public;
create or replace public synonym contentSchemaIs for xdb.contentSchemaIs;
create or replace function xdb.under_path_func wrapped 
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
49d 32b
jP3G4mghcafDzFu+lNliTdUX0cswg41ezCATfC8Zxz+VAPWe92ZhyfwhKpcd+7ZWN/B+A2Ou
Fi56RGICnrTx8nMI2tpQUKETexSRiru5+M+apDjUz+mt1l9Eol0msFF624KAL72b3EUeFCu/
PljmZwmU+9nxbPNeBK8FLISeDwDugEF1Ljcjp3VbImMWRTM9krXOFMmmAd2CRB5wKQb9s24b
Xsg4NPziV4i9UWWvRWJp3iFZPo8XZsQsMBtaETPxba0V+WnoKIKpwwbh0mNXAxNyttZlHMhu
Qr1CAj/sk3waR20S0kQ0QRAtTQgbG4pZz7z8z6AU1VYgRkv3HCPpk4XWVqGk/L6WW6cWVBtl
gIAlWb7Oi38B24ht/FSKDhFw5ORf1JisObXjMwrCPbBh0HgimCX+uOY8dQLeISFVhAVUb8YO
ZjRTeXEXgYCELlSpUk5OQ3mszBALCeplRRCYqS0UfwiUilXATg7uEkwA3d6/qg1yKOk6HTNQ
oBNFAguzuTiYlsuYNBXgH6pH8et91hlhUHoqQr4qqOof5aN4PXIjCu5TsQ1Ag4MNqQXrkYXC
O5claWgkrwtMwyp6SCdMYZBo6UXlv0XfzFtzDCxwsBPNtDzbXlaDB8iZurobProy1HX8C//r
A4daiSw4FAEYD9QnSH9+Yawg1CK1AIbFXc7ZQfev42t51qTfUuQ4fqfqcdR5jN6AIovTqvQZ
kq9aZpTR1ZSti9tKsmGCDF5mdlhiLS/BZioCHt5PrVgO1cFXE94SIn46De2iX0WqpDZxwbs/
HdFfZj0=

/
show errors;
create or replace package body xdb.xdb_ancop wrapped 
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
f26 26c
kmZVopvZaP5Hh610BPd0aYBXFB4wg80rLiDWfHRVMnOUK647jqgysZDmWqijWmnTo1cItbWV
bi/yJH3bGi4L040YkcZSQXNBjcOJEFBuhOUDb+xWzU3gReE4OB242JTH5tVNTdV7IM11p3C6
EyFj9XmVvZE0wERNRVm+qKhQex1JJ1Q11/0I3hs/rEBWewvmTV94Ryo2Vj81FlANTmnT5B9R
tmzidgEccrQL5mpMeXdDL9LKh6Fch/gJBBajwLQ5UKjGbxpasiprFdu4CvZqML/T5Gjunrkk
mVas3kMwhkvn1r12eG+fAPlT5lGo9LXKd1l8/KApcy0zLb3xCmiUjBAfmr/cgn8hZL9o6b3y
z8TRh91ZKsctLTNFUuvzvDLqBzb4uV+0cvsgIcYOr9b0Apf+uxNYg862KqLN6HrG17FDlRTt
Fbf9tDbroaFgnhCxCyAIfNgEqQqKYaVnsZvoUb96WPQcTnuOTgcGUp7R+DNOgaVNqaHCeGTE
rM5CuSgMG6r3oAk+nEJzOnWpX6uEBUkaKH1JVCj5MmgXfeGZjZoJleAyuFTlL6daUie1Q5i/
3e0Zm51z0nOjqJl32yP4qhNItYqqOjbv8RVs

/
show errors;
create or replace package body xdb.XDB_RVTRIG_PKG wrapped 
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
380 189
+3uNmKZr1/vc7Y5Dx/tMx0AyxOEwg9def0pqyi80e2RUY8AUiQaDw/ZUOI5bUKykmAa1nVdf
9F1XH1UqSUwLbaTJyReREonqdzY7XoJZ5S56YN97Ogo5dLhXpjCf8XfdNpSC3yFZ+xV2/+s7
0ANJ+xwLW+/CisgkrshCcOHSEYFLfQxLMO9XydFSWTH0xgu+PROn9206rQpFN2xjs1AAAZG+
uHiTk3v93hgC7vcDKxTLUFbBWxaenpOiVih8K4j0s1JEp5QeUf1NbhLCe5+w2cRClIEkQxAf
eF5OUbUh0TT62jA9U9LxtLxK3WOwHOUDLp32Sf3uLMRewOOBDTuv4seYE+r/o0yyxDg9+qNP
tJGU0Eeub5iubdiDc+Cc0JbBb4+4

/
show errors;
