REM
REM Copyright (c) 1999, 2005, Oracle. All rights reserved.  
REM
@echo off
set ICINCHOME=%ORACLE_HOME%\oci\include
set ICLIBHOME=%ORACLE_HOME%\oci\lib\msvc
set OTT=%ORACLE_HOME%\bin\ott
if (%1) == () goto usage
if (%1) == (cdemo81) goto ocimake
if (%1) == ("cdemo81") goto ocimake
if (%1) == (CDEMO81) goto ocimake
if (%1) == ("CDEMO81") goto ocimake

if (%1) == (occidml) goto occidml
if (%1) == ("occidml") goto occidml
if (%1) == (OCCIDML) goto occidml
if (%1) == ("OCCIDML") goto occidml

if (%1) == (occiobj) goto occiobj
if (%1) == ("occiobj") goto occiobj
if (%1) == (OCCIOBJ) goto occiobj
if (%1) == ("OCCIOBJ") goto occiobj

if (%1) == (odbcdemo) goto odbcmake
if (%1) == ("odbcdemo") goto odbcmake
if (%1) == (ODBCDEMO) goto odbcmake
if (%1) == ("ODBCDEMO") goto odbcmake

cl -I%ICINCHOME% -I. -D_DLL -D_MT %1.c /link /LIBPATH:%ICLIBHOME% oci.lib kernel32.lib msvcrt.lib /nod:libc
goto end

:ocimake
cl -I%ICINCHOME% -I. -D_DLL -D_MT %1.c /link /LIBPATH:%ICLIBHOME% oci.lib msvcrt.lib /nod:libc
goto end

:occidml
cl -GX -DWIN32COMMON -I. -I%ICINCHOME% -I. -D_DLL -D_MT %1.cpp /link /LIBPATH:%ICLIBHOME% oci.lib msvcrt.lib msvcprt.lib oraocci10.lib /nod:libc
goto end

:occiobj
CALL %OTT% userid=hr/hr intype=%1.typ outtype=%1out.typ code=cpp hfile=%1.h cppfile=%1o.cpp mapfile=%1m.cpp attraccess=private
cl -GX -DWIN32COMMON -I. -I%ICINCHOME% -I. -D_DLL -D_MT %1.cpp %1o.cpp %1m.cpp /link /LIBPATH:%ICLIBHOME% oci.lib msvcrt.lib msvcprt.lib oraocci10.lib /nod:libc
goto end

:odbcmake
cl -I"%MSVCDir%\include" -I"%MSVCDir%\include\MFC" -DWIN32COMMON odbc32.lib %1.c
goto end

:usage
echo.
echo Usage: makedemo_xeserver filename [i.e. makedemo_xeserver cdemo81]
echo.
:end
set ICINCHOME=
set ICLIBHOME=
