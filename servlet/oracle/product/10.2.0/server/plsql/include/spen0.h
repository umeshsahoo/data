/* Copyright (c) 2003, Oracle Corporation.  All rights reserved.  */
 
/* 
   NAME 
     spen0.h - Port-specific part of PL/SQL Execute Native interfaces

     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     **!!!! THIS FILE IS SHIPPED FOR NCOMP.                        !!!!
     **!!!!                                                        !!!!
     **!!!! If you change it for a bug fix, you will need to make  !!!!
     **!!!! sure it is re-shipped also along with the new binaries.!!!!
     **!!!! Please make this note in the BUGDB along with your fix.!!!!
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   DESCRIPTION 
     This file defines port-specific macro for PL/SQL Execute Natively
     compiled units.

   NOTES
     Remove slg macro definitions once we start shipping core macros.

   MODIFIED   (MM/DD/YY)
   dbronnik    11/22/03 - dbronnik_bug-3263250 
   dbronnik    11/20/03 - Creation

*/

#ifndef SPEN0_ORACLE
# define SPEN0_ORACLE

#ifndef ORATYPES
# include <oratypes.h>
#endif

/*---------------------------------------------------------------------------
                     PUBLIC TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/

#ifndef SL_ORACLE

#include <setjmp.h>

/* SOLARIS definitions. */

struct slgbuf 
{ 
  jmp_buf slgbuf_jb;
};
typedef struct slgbuf slgbuf;

#define slgset(p)     (eword)setjmp((p)->slgbuf_jb)
#define slgjmp(p, w)  longjmp((p)->slgbuf_jb, (w))

#endif

#endif                                              /* SPEN0_ORACLE */
