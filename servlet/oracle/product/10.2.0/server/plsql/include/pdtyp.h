/* Copyright (c) 2000, 2004, Oracle. All rights reserved.  */
/*
   NAME
     pdtyp.h -

   DESCRIPTION
     This file has definition of types that are PRIVATE to
     PL/SQL AND that are common to the native and interpreted
     execution environment.

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

   EXPORT FUNCTION(S)

   INTERNAL FUNCTION(S)

   EXAMPLES

   NOTES

   MODIFIED   (MM/DD/YY)
   kmuthukk    11/30/04 - slun is now siobn 
   dbronnik    08/28/03 - Add PE_SWITCH_LOOP
   sylin       03/28/03 - REGEXP: add TC_RCP
   astocks     01/10/30 - compact pemtrhd
   astocks     01/10/03 - Make pevm_excs a uword
   dbronnik    04/05/02 -
   dbronnik    03/11/02 - Add TC_VCHARX
   mvemulap    01/29/02 - new handle pemtahd
   mvemulap    01/16/02 - bug fix for 1827146
   mvemulap    01/03/02 - move const pool back to sga for ncomp
   astocks     11/05/01 - Allow null constants in constant segment
   sylin       09/18/01 - Add pipeline return code for natively compiled code
   mvemulap    04/27/01 - penscd modification
   mvemulap    04/10/01 - bug fix for 1712683
   dbronnik    01/08/01 - remove penul
   kmuthukk    12/01/00 - remove s.h include
   mvemulap    10/16/00 - move pemtexh to this file
   mvemulap    10/05/00 - add penscd type
   mvemulap    08/14/00 -
   mvemulap    05/19/00 - pvm -> pevm
   mvemulap    07/10/00 - nested coll
   kmuthukk    06/03/00 - newrep: peval fields are now plsmut type
   kmuthukk    05/19/00 - newrep: move some defns from pdtyp.h to plsm.h
   kmuthukk    04/27/00 - change PMUnicopy
   kmuthukk    04/26/00 - add PMUnicopy
   kmuthukk    04/20/00 - move plsmut to pptyp.h
   dbronnik    04/14/00 - switch to plsmut
   rdani       06/22/00 - ALTER TYPE stop using TOID use type name.Store HTSIG
   wxli        06/11/00 - length semantics implementation
   mvemulap    05/04/00 - change psw values
   mvemulap    04/27/00 - make retcode enum type
   mvemulap    04/11/00 - opcode_fault
   mvemulap    02/24/00 - add PE_SUSPEND
   mvemulap    02/18/00 - PL/SQL data type definitions
   mvemulap    02/18/00 - Creation

*/


#ifndef PDTYP_ORACLE
# define PDTYP_ORACLE


# ifndef PPTYP_ORACLE
#  include <pptyp.h>
# endif


/*---------------------------------------------------------------------------
                     PUBLIC TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/
/*
 * pvm instruction return status
 */
#define PE_NONE 0x00                                     /* Normal Execution */
#define PE_ZER  0x02
#define PE_NEG  0x04
#define PE_NUL  0x09                          /* instruction detected a null */
#define PE_EXC  0x07                     /* instruction  raised an exception */
#define PE_RESTART 0x11
#define PE_SUSPEND 0x21
#define PE_SUSPEND_RESTART 0x31
#define PE_BREAK_FAULT 0x41
#define PE_OPCODE_FAULT 0x51
#define PE_FINAL_EXIT 0x61
#define PE_PSUSPEND 0x71       /* suspend code for native pipeline functions */
#define PE_SWITCH_LOOP 0x81 /* switch interpreter loop after tool activation */

/* Status word. This could be a ub1, but we make it a naturally sized word for
   the target platform to avoid having the C compiler generate byte extract
   operations
 */
typedef uword pevm_excs;


/* typedefs for pl/sql's notion of certain entities */
typedef ub1    pemttcat;                                /* for Type-CATegory */

/* Character Set definitions:
 *  there are no typedefs for these in SQLdef.h or lx.h
 */
/* cs form: SQLCS_IMPLICIT, SQLCS_NCHAR, SQLCS_EXPLICIT, SQLCS_FLEXIBLE */
typedef ub1    pemtcsfr;

/* charset id, eb2 in lx.h */
typedef ub2    pemtcsid;


/* Base Representations for handles
 * ================================
 * Data items are accessed via handles. Handles also serve the purpose of
 * holding together the meta-data associated with an item.
 */

/* pemtshd -
 *  Handle for Simple Scalars (TC_SSCALAR) and Cursors (TC_CURSREF)
 */
struct pemtshd
{
  plsmut *peval;                                               /* value part */
};
typedef struct pemtshd pemtshd;

/* An abstract handle (pemtahd): a handle to any type which
 * uses durations (pemtdhd, pemtrhd, pemtlob, pemtchd, pemtihd, pemtohd,
 * pemtophd) can be cast to (pemtahd *) in order to get
 * the duration without using a big switch statement. Hence, the position
 * of pemdt field in all these handles should be the same as in
 * pemtahd (currently the second).
 */
struct pemtahd
{
  plsmut *peval;                                               /* value part */
  pehdt   pemdt;                                      /* memory duration tag */
};
typedef struct pemtahd pemtahd;

/* PETahmdt: macro to access the duration */
#define PETahmdt(item) (((pemtahd *)(item))->pemdt)

/* pemtphd
 * Handle for regexp compiled pattern
 */
struct pemtphd
{
 plsmut *peval;
 pehdt   pemdt;
};
typedef struct pemtphd pemtphd;

/* pemtdhd
 * Handle for datetime/interval
 */
struct pemtdhd
{
  plsmut *peval;                                               /* value part */
  pehdt   pemdt;                                      /* memory duration tag */
  ub1     peldp;                                       /* leading constraint */
  ub1     petlp;                                      /* trailing constraint */
  ub1     pekind;                       /* kind: DTY for datetimes/intervals */
};
typedef struct pemtdhd pemtdhd;


/* pemtrhd -
 *  Handle for TC_FCHAR, TC_VCHAR, TC_RAW, TC_MLS.
 *  Also used for UROWID though in this case the charset form and id are not
 *  used.
 */
struct pemtrhd
{
  plsmut   *peval;                                             /* value part */
  pehdt     pemdt;                                    /* memory duration tag */
  pemttcat  petcat;                 /* Type-CATegory: TC_FCHAR,VCHAR,MLS,RAW */
  pemtcsfr  pecsfr;                                          /* charset form */
  pemtcsid  pecsid;                                            /* charset ID */
  ub1       pelnsm;                            /* length semantics attribute */
  ub4       pemxln;                                 /* max length constraint */
};
typedef struct pemtrhd pemtrhd;

/* pemtlob -
 *  Handle for LOB Locators (TC_LOB).
 */
struct pemtlob
{
  plsmut   *peval;                                             /* value part */
  pehdt     pemdt;                                    /* memory duration tag */
  ub1       pelobtyp;                 /* type of lob: DTYCLOB, DTYBLOB etc.. */
  pemtcsfr  pecsfr;                             /* CLOB, NCLOB: charset form */
  pemtcsid  pecsid;                                            /* charset ID */
};
typedef struct pemtlob pemtlob;


/* pemtchd -
 *  Handle for Composite Types (TC_ADT).
 */
struct pemtchd
{
  plsmut  *peval;                                              /* value part */
  pehdt    pemdt;                                     /* memory duration tag */
  ub2      pesiobn;         /* session unique iob number where pemttdo lives */
  ub4      petdo;                /* HS offset in pesiobn where tdo handle is */
};
typedef struct pemtchd pemtchd;

/* pemtihd -
 *  Handle for Collections (Index-tables, Nested Tables, Varrays).
 */
struct pemtihd
{
  plsmut  *peval;                                              /* value part */
  pehdt    pemdt;                                     /* memory duration tag */
  ub2      pesiobn;        /*  session unique iob number where pemttdo lives */
  ub4      petdo;                /* HS offset in pesiobn where tdo handle is */
  dvoid   *peehd;                                   /* ptr to element handle */
  pemttcat petcat;                                           /* element TCAT */
};
typedef struct pemtihd pemtihd;


/* pemtohd -
 *  Handle for an object-ADT (TC_OBJREF).
 */
typedef struct pemtchd pemtorhd;


/* pemtophd -
 *  Handle for an Opaque Type variable (TC_OPQ)
 */
typedef struct pemtchd pemtophd;



/* TCATs -- Type CATegory based classification of types.

   Rationale for TCATs:
     Several operations in the pl/sql runtime depend only on the TCAT of the
    item, not on the what specific type the item is.
     The primary use of the TCAT notion is during instruction execution where
    the instruction essentially 'dispatches' on the TCAT. For example, handle
    initialization instructions fall in this category.

   Directive TCATs:
     These begin with _TC
         (e.g. _TC_iVCHAR for inlined varchar2s,
               _TC_iFCHAR for inlined fixed-chars)

     These TCATs get used only in the frame descriptor (INFR instr) that
     initializes top-level items (or bind-variable proxies). This is a way
     for the compiler to give "hints" (directives) to the run-time about
     the item.

     Typically, other parts of the run-time (like lib-unit loader, RPC etc)
     need not deal with _TC_<xxx> type category.

     E.g: Varchar2s are normally kept of out of line. But for top-level
          varchar2s, if they are small enough we do an optimization of
          inlining them on stack.

     If the compiler decides to inline top-level varchar2 variables on
     the stack when its declared length is less than a certain size- (say
     PFM_vc2_prealloc_theshold) then the run-time needs to know about this.

     TC_mINLINED modifier indicates data part immediately follows plsmut
     on FP stack, and it extends to all types that use plsmut handle, not
     only char/varchar. _TC_iFCHAR and _TC_iVCHAR are not used anymore.
     Codes 3 and 5 can be re-used.

   Caution:
     Do not change the values for the # defines below if you want upgrades
     and downgrades to work. [Reason: These values are stored in the compiled
     version of the mcode in the SDCH (static descriptor for constant pool
     handles).]
 */
#define TC_NONE      0                         /* Reserved: used in SDCH map */
#define TC_SSCALAR   1         /* simple scalars: date, number, boolean, etc */
#define TC_FCHAR     2                                         /* Fixed-char */
#define TC_VCHAR     4                                           /* varchar2 */
#define TC_RAW       6                                                /* raw */
#define TC_MLS       7                                           /* mlslabel */
#define TC_ADT       8                    /* Abstract Data Type, PL/SQL Recs */
#define TC_OBJREF    9                                         /* Object Ref */
#define TC_RID       10                  /* ROWID (in riddef representation) */
#define TC_REF       11                               /* reference (dvoid *) */
#define TC_TDO       12                                          /* TDO-lite */
#define TC_CURSREF   13                                  /* cursor reference */
#define TC_INDEXED   14                                       /* Index table */
#define TC_LOB       15                                               /* Lob */
#define TC_DATETIME  16                                          /* Datetime */
#define TC_INTERVAL  17                                          /* Interval */
#define TC_UROWID    18                                            /* UROWID */
#define TC_OPQ       19                                       /* Opaque Type */
#define TC_VCHARX    20               /* TC_VCHAR managed by the String Pool */
#define TC_RCP       21                           /* REGEXP compiled pattern */

/* This is the last valid value for a TCat. Update whwn you add new ones */
#define TC_LAST      TC_RCP

/*
 * The top bits of the TCat can be used as modifiers, to convey additional
 * information about the object. To avoid using up too many bits, these
 * modifiers may be overloaded, when no confusion is possible. Any consumer
 * of a TCat must be careful to mask off any legal modifiers before
 * processing the type information
 */
#define TC_mNULLACTIVATE 64             /* modifier: null activate an Object
                                                  valid only for SETN        */
#define TC_mNULLCONST    64                    /* modifier: constant is NULL
                                                  valid only in USDCH        */
#define TC_mINLINE       64                  /* modifier: allocated on stack
                                                  valid only for INFR        */
#define TC_mOUTBIND     128                            /* modifier: OUT bind */


/* Null Indicator Definitions for OCI calls */
#define PET_NOT_NULL IND_NOT_NULL
#define PET_NULL     IND_NULL
#define PET_BAD_NULL IND_BAD_NULL
#define PET_BND_OUT  IND_BND_OUT  /* not an indicator value, not public, used
                                     only for TC_CURSREF and only during init,
                                     then cleared */

/* PETmut: pointer to plsmut handle of an item */
#define PETmut(item) (((pemtshd *)(item))->peval)

/* PETdat: pointer to data part of an item through plsmut */
#define PETdat(item) (PMUpd(PETmut(item)))

/* PETlen: data length of an item through plsmut */
#define PETlen(item) (PMUlen(PETmut(item)))

/* PETflg: flags including null ind through plsmut */
#define PETflg(item) (PMUflg(PETmut(item)))

/* PETpd: pointer to data part of an item */
#define PETpd(item) (((pemtshd *)(item))->peval)


/*
 * Representation of data part of scalar types using definitions
 * in oratypes.h. Don't want to include kol.h or lnx.h or ldx.h etc
 * -- because we don't want to ship those files for PL/SQL NCOMP.
 */
typedef sb4      penint;                                   /* binary_integer */
typedef ub1      pennum[22];              /* number w/ preceding length byte */
typedef dvoid   *penfc;                 /* fixed-char: has 4 byte len prefix */
typedef dvoid   *penvc2;                  /* varchar2: has 4 byte len prefix */
typedef dvoid   *penraw;                       /* raw: has 2 byte len prefix */
typedef dvoid   *penlob;                       /* lob: has 2 byte len prefix */
typedef dvoid   *penmlslabel;                                    /* mlslabel */
typedef ub1      penedt[7];                                 /* external date */
typedef dvoid   *penitb;                             /* pl/sql indexed-table */
typedef dvoid   *penobjref;                              /* REF (object-ADT) */

/* type for instance primary memory */
#define penipm(sz) union {ub1 ipm[sz]; size_t _s;void *_v;}

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
                           EXPORT FUNCTIONS
  ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
                          INTERNAL FUNCTIONS
  ---------------------------------------------------------------------------*/


#endif                                              /* PDTYP_ORACLE */
