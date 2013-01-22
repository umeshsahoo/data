/*
 * $Header: pptyp.h 01-oct-2003.15:57:31 rdecker Exp $
 */
/* Copyright (c) 1998, 2003, Oracle Corporation.  All rights reserved.  */

/* 
   NAME 
     pptyp.h - PL/SQL Public Type definitions.

   DESCRIPTION 
     This file has definition of types that are PL/SQL PUBLIC
     (i.e. used by RDBMS, ICD implementors etc.) and that are
     also common to the NATIVE and INTERPRETED execution 
     environments.

     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     **!!!! THIS FILE IS SHIPPED FOR NCOMP.                        !!!!
     **!!!!                                                        !!!!
     **!!!! If you change it for a bug fix, you will need to make  !!!!
     **!!!! sure it is re-shipped also along with the new binaries.!!!!
     **!!!! Please make this note in the BUGDB along with your fix.!!!!
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

     CAUTION:

     Do not put any interpreter specific definitions in pen.h (or files
     included by pen.h such as pvm.h/pdtyp.h/pptyp.h). Such definitions
     belong in pfrdef.h/pfmdef.h. Internal support functions not required
     by generated C code belongs to pet.h/pvm0.h.

   RELATED DOCUMENTS 
 
   INSPECTION STATUS 
 
   ACCEPTANCE REVIEW STATUS 
     Review date: 
     Review status: 
     Reviewers: 
 
   PUBLIC FUNCTION(S) 

   PRIVATE FUNCTION(S)

   EXAMPLES

   NOTES
     <other useful comments, qualifications, etc.>

   MODIFIED   (MM/DD/YY)
   rdecker     10/01/03 - bug 3147224: scrap memory for direct invocation
   mvemulap    04/04/02 - add another bit PLSFCNSTRD
   mvemulap    01/29/02 - add bit PLSFEXISTS to plsmflg
   rdecker     04/18/02 - add PLSDIRX flag for direct invocation
   wxli        08/16/01 - plsmut new flag PLSSINGLE
   kmuthukk    12/01/00 - remove s.h include, use oratypes.h
   kmuthukk    05/19/00 - newrep: move some defns from pdtyp.h to pptyp.h
   kmuthukk    04/20/00 - move plsmut to pptyp.h
   kmuthukk    01/06/99 - fix comments                                         
   kmuthukk    11/05/98 - pl/sql public types pptyp.h                          
   kmuthukk    11/05/98 - Creation

*/

/*
 * This file is shipped for PL/SQL NCOMP.
 *
 * DO NOT INCLUDE s.h FILE. WE ARE NOT ALLOWED TO SHIP s.h -- 
 * IT IS AN ORACLE PROPRIETARY FILE.  [KMuthukk]
 *
 * Include oratypes.h instead.
 *
 * pen.h/pvm.h/pn.h/pdtyp.h/pptyp.h should all only use
 * types specified in oratypes.h.
 */

#ifndef ORATYPES
# include <oratypes.h>
#endif

#ifndef PPTYP_ORACLE
# define PPTYP_ORACLE

/*---------------------------------------------------------------------------
                     PUBLIC TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/* Exception Value Type.
 * Must be large enough to hold the value MIN_AUTO_EXCN (see below).
 */
typedef ub4 perexc;

/* Memory Duration Tag used by the heap manager */
typedef ub2 pehdt;              /* OCIDuration (don't want to include oro.h) */

/* Indicator Type & Values */
typedef sb2 pemnul;          /* pl/sql type name for the null indicator */

/*
 * These constants should be used to refer to the state of a null
 * indicator for a value.  IND_NONE is for internal use and should
 * not be set or tested by a client. These indicators are made public
 * since they may be used by clients using ICDs.
 * Note: The IND_BAD_NULL value can appear in the null indicator for items 
 * that are fields (components) of composite items. When some composite item
 * is atomically null-- then the null indicator of all its components are set
 * to IND_BAD_NULL.
 * The semantics of IND_BAD_NULL are:
 *     -- equivalent to NULL when it appears as a RHS value.
 *     -- EXCEPTION on assignments (LHS context).
 */
/* undef any different definitions from pt.h (actually pt.h shouldn't be
   redefining these at all). */
#undef IND_NOT_NULL
#undef IND_NULL
#undef IND_BAD_NULL
#undef IND_NONE

#define IND_NOT_NULL (pemnul)0                   /* not-null indicator value */
#define IND_NULL     (pemnul)(-1)                    /* null indicator value */
#define IND_BAD_NULL (pemnul)(-2)   /* some enclosing composite item is NULL */
#define IND_NONE     (pemnul)(-4)                       /* value not present */
#define IND_BND_OUT  (pemnul)(-8)          /* internal: clients don't use it */


/*****************************************************************************\
 * mutable strucure for operand                                              *
\*****************************************************************************/
struct plsmut
{
  ub1          *plsbfp;                                    /* buffer pointer */
  ub2           plscvl;                              /* current value length */
  ub2           plsmflg;                                    /* mutable flags */
#define  PLSFAE      0x0001                             /* already evaluated */
#define  PLSFNULL    0x0002                      /* reserved, used by kafmut */
#define  PLSFBADNULL 0x0004              /* enclosing ADT is atomically null */
#define  PLSFPA      0x0008                 /* preallocated (no resize reqd) */
#define  PLSFBNDOUT  0x0010         /* temp flag for cursref bind proxy only */
/* The flag PLSSINGLE is used for optimazation for single byte data in
 * multibyte character set environments to improvement the performance.
 * It is used only on multibyte variable width character sets aush as UTF8.
 * The flag may be set in single byte character sets but has no affect.
 */
#define  PLSSINGLE   0x0020          
#define  PLSDIRX     0x0040        /* plsmut is "owned" by direct invocation */
  /* The flag PLSFEXISTS is used only for elements of a collection. This bit
   * is set when an element is allocated in a collection and is cleared
   * when it is deleted from the collection. sometimes, when an element
   * is deleted, we only clear this bit but do not actually free any 
   * secondary memory so that it can be reused if an element is re-inserted
   * at the same index at a later time.
   */
#define  PLSFEXISTS  0x0080              /* element (of a collection) exists */
#define  PLSFCNSTRD  0x0100         /* element (of a collection) constructed */
#define  PLSSCRAPMEM 0x0200     /* The buffer is pointing to peidx scrap mem */
};
typedef struct plsmut plsmut;

/* PMUpd: data part */
#define PMUpd(p) ((p)->plsbfp)

/* PMUlen: actual data length */
#define PMUlen(p) ((p)->plscvl)

/* PLSMUT flag */
#define PMUflg(pmut) ((pmut)->plsmflg)

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
                           PUBLIC FUNCTIONS
 ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
                          PRIVATE FUNCTIONS
 ---------------------------------------------------------------------------*/


#endif                                                       /* PPTYP_ORACLE */
