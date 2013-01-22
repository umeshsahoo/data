/* Copyright (c) 1998, 2004, Oracle. All rights reserved.  */
/* 
   NAME 
     pvm.h - PL/SQL Virtual Machine micro-kernel implementations.

     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     **!!!! THIS FILE IS SHIPPED FOR NCOMP.                        !!!!
     **!!!!                                                        !!!!
     **!!!! If you change it for a bug fix, you will need to make  !!!!
     **!!!! sure it is re-shipped also along with the new binaries.!!!!
     **!!!! Please make this note in the BUGDB along with your fix.!!!!
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   DESCRIPTION 
     PL/SQL runtime kernels. Implementation of most instructions.
     Contains runtime libraries/interfaces used by:
       -- ncomp generated C code
       -- native run-time libraries (pen.c, pvm.c, etc.)
       -- interpreted run-time (pfrrun.c/pvm.c, etc.).

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
     All routines in this module return a PVM processor status.
     Unless the instruction is a comparison which sets the
     processor status word, the return status will be
      PW_NONE - success
      PW_NUL  - failure. In this case percerr has the actual error
                code.

   MODIFIED   (MM/DD/YY)
   dbronnik    07/02/04 - add real INSI routines for SCALAR and CURSREF
   astocks     05/07/04 - Simplify pevm_INSI_CURSREF
   jciminsk    04/28/04 - merge from RDBMS_MAIN_SOLARIS_040426 
   jciminsk    02/06/04 - merge from RDBMS_MAIN_SOLARIS_040203 
   kmuthukk    08/02/03 - grid: add pevm_BRRESTORE 
   astocks     04/01/04 - Add pevm_VCAL
   dbronnik    11/25/03 - Add pevm_RAISE_JUMP
   dbronnik    09/29/03 - Change exception handling
   astocks     09/11/03 - NVL 
   astocks     10/25/03 - Lint
   kmuthukk    06/12/03 - cache dynamic SQL cursors
   lvbcheng    09/24/03 - Remove subopcode from pevm_ADT 
   lvbcheng    09/19/03 - Add pevm_MSET_ADT 
   lvbcheng    09/02/03 - 2638641 
   dbronnik    08/27/03 - INHFA1
   dbronnik    06/30/03 - Add pevm_SUBSTR
   astocks     07/23/03 - Bug 3059375
   sylin       06/19/03 - Remove use_cstack, and set it in flags_pemtenter
   sylin       03/24/03 - Add pevm REGEXP function protos
   astocks     03/27/03 - Materialized booleans
   kmuthukk    03/24/03 - special get/ins for each collection type
   kmuthukk    03/14/03 - remove pevm_MOVSHADT
   kmuthukk    01/07/03 - ncomp tuning
   astocks     01/20/03 - Remove unused opcodes
   cbarclay    11/07/02 - overlaps
   astocks     01/10/03 - Native CTRL-C 
   cbarclay    11/06/02 - 
   eehrsam     10/30/02 - 
   sylin       01/09/03 - 2711796: Remove pevm_INSTNL
   dbronnik    11/04/02 - Faster MOVN
   kmuthukk    10/08/02 - plstimer: plsql perf analyzer
   dbronnik    09/24/02 - add VATTR and FTCHC_PSEUDO
   sylin       10/08/02 - Add line number argument to pevm_I4EXIM and
                          pevm_I4OPND
   sagrawal    07/09/02 - Sparse collection support for bulk binds
   rdecker     09/09/02 - added pevm_VALIST and pevm_VALISTINI
   sylin       09/10/02 - 1894991: Add use_cstack argument to pevm_ENTER
   astocks     07/10/02 - MOVFCU
   mxyang      04/26/02 - IEEE 754 FP support
   mvemulap    01/29/02 - change pevm_INRDH_common into macro
   sursrini    06/18/02 - 2269576: Drop off the unnecessary casting on 
                          pevm_INSI_ISSCALAR
   kmuthukk    04/05/02 - DEFINE instruction format change
   astocks     04/12/02 - pevm_MOVC
   mvemulap    01/16/02 - bug fix for 1827146
   kmuthukk    12/20/01 - remove pevm_MOVL, pevm_MOVCADT, pevm_MOVS
   cbarclay    09/26/01 - pevm_CMPIO
   sagrawal    09/07/01 - array of record in binds
   sagrawal    08/31/01 - bulk define of record collections
   sylin       09/20/01 - Modify prototype for pevm_PIPE()
   cbarclay    08/07/01 - treat
   cwethere    08/09/01 - Add ABSN.
   dbronnik    09/07/01 - Add pevm_CONCN.
   cwethere    08/27/01 - Add instructions.
   sagrawal    05/07/01 - pevm_DRCAL
   dbronnik    04/17/01 - add flags to i4exim
   mvemulap    04/08/01 - fix prototype for pevm_INBI_INDEXED_UROWID
   mvemulap    04/10/01 - bug fix for 1712683
   kmuthukk    02/02/01 - move pevm_BSETN to pfrrun.c
   kmuthukk    01/26/01 - fast reinit pkgs
   mvemulap    03/29/01 - compiler warnings
   mvemulap    03/07/01 - fix native compiler warnings
   mvemulap    02/28/01 - remove while(0) to reduce compile time
   mvemulap    02/12/01 - olint fixes
   mxyang      02/20/01 - remove pevm_MOVCT
   mxyang      02/09/01 - CMP3LOB
   kmuthukk    12/21/00 - remove obsolete COPM instruction
   kmuthukk    12/19/00 - INCI/DECI support
   kmuthukk    12/12/00 - optimize pevm_INSI_SSCALAR
   gviswana    12/01/00 - ub4 for line numbers
   kmuthukk    12/01/00 - remove s.h include
   kmuthukk    12/01/00 - pvm.h cannot refer to ped.h functions
   dbronnik    11/29/00 - add pvm_ctx_pub
   wxli        12/01/00 - remove pvm_cnschk() from this file
   mvemulap    11/02/00 - change pevm_SNCAL
   mvemulap    10/30/00 - move lnr to perc
   mvemulap    10/20/00 - add arg_block to pevm_RCAL
   mvemulap    10/16/00 -  
   mvemulap    10/05/00 - add HS to pevm_ENTER
   jmuller     10/23/00 - Fix bug 1089498: publish pvm_cnschk()
   mvemulap    09/28/00 -  
   wxli        09/07/00 - pevm_CCNST with ctx
   mvemulap    09/14/00 -  
   mvemulap    09/07/00 - change GRWFCC
   wxli        08/25/00 - set lensem into CHINFO
   mvemulap    08/24/00 - lrg
   mvemulap    08/14/00 -  
   mvemulap    06/21/00 - more microkernels
   mvemulap    06/19/00 - native exec
   mvemulap    05/19/00 - pvm -> pevm
   wxli        07/17/00 - char/nchar implicit conversion
   mvemulap    07/09/00 - nested coll
   asethi      07/12/00 - Bulk bind extensions
   sagrawal    07/03/00 - Dynamic dispatch
   kmuthukk    05/27/00 - newrep: remove pvm_MOVFADT
   kmuthukk    04/26/00 - change INRDH prototyp
   asethi      06/13/00 - Added code to process PIPE statement
   wxli        06/11/00 - length semantics implementation
   mvemulap    05/16/00 - 
   mvemulap    04/24/00 - plsql ncomp
   mvemulap    04/19/00 - more micros
   mvemulap    04/08/00 - more micro kernels
   mvemulap    02/23/00 - Microkernels for PL/SQL VM
   mvemulap    02/23/00 - Creation

*/

#ifndef PVM_ORACLE
# define PVM_ORACLE

#ifndef PDTYP_ORACLE
# include <pdtyp.h>
#endif

/*---------------------------------------------------------------------------
                     PUBLIC TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/* public part of the run-time context structure */
struct pvm_ctx_pub
{
  sb4 ctlc_cnt;
};
typedef struct pvm_ctx_pub pvm_ctx_pub;

/* exception handling macro */
#define pevm_jmpbuf slgbuf
#define pevm_jmpset slgset
#define pevm_jmpjmp slgjmp

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
                           PUBLIC FUNCTIONS
 ---------------------------------------------------------------------------*/


/* Bad instructions */
void      pevm_BAD(void *ctx);

/* The following branch instructions are directly implemented, 
 * so should never execute them through PVM
 */
#define pevm_BRGE   pevm_BAD
#define pevm_BRGT   pevm_BAD
#define pevm_BRLE   pevm_BAD
#define pevm_BRNCH  pevm_BAD
#define pevm_BRNE   pevm_BAD
#define pevm_BRNEG  pevm_BAD
#define pevm_BRNUL  pevm_BAD
#define pevm_BRZER  pevm_BAD

/*
 * BRREINI (Special Branch): used for fast package reinitialization.
 */
boolean pevm_BRREINI(void *ctx);
boolean pevm_BRRESTORE(void *ctx);

void      pevm_ABSI(void *ctx, void const *src1, void *dst);
void      pevm_ADDI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_ADDN(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_BNDUC(void *ctx, void const *src1, ub2 position, ub2 tmpub2, ub2
              flags);
void      pevm_BREAK(void *ctx);
pevm_excs pevm_BFTCHC(void *ctx, void const *src1, void const *src2);
void      pevm_CLREX(void *ctx);
void      pevm_RASRX(void *ctx, boolean native_exec);
void      pevm_CBEG(void *ctx, ub1 subopc, 
                    void const *src1, void *dst, void const *src2);
void      pevm_CSBEG(void *ctx, ub1 subopc, void *dst, void const *src1);
pevm_excs pevm_CMP3C(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3D(void *ctx, ub1 opc, void const *src1, void const *src2);
pevm_excs pevm_CMP3I(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3N(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3R(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3LOB(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3REF(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3UR(void *ctx, void const *src1, void const *src2);
void      pevm_CNVMSC(void *ctx, void const *src1, ub1 opc, void *dst);
void      pevm_CONCN(void *ctx, void **args, ub4 nargs, boolean nocheck);
#define    pevm_CVTCD(ctx, src1, dst) pevm_CVTCFD(ctx, src1, (void *)0, dst)
void      pevm_CVTCFD(void *ctx, void const *src1, void const *src2, 
                      void *dst);
#define   pevm_CVTCL(ctx, src1, dst) pevm_CVTCFL(ctx, src1, (void *)0, dst)
void      pevm_CVTCFL(void *ctx, void const *src1, void const *src2, 
                      void *dst);
#define   pevm_CVTCI(ctx, src1, dst) pevm_CVTCI_i(ctx, src1, dst, TRUE)
#define   pevm_CVTNI(ctx, src1, dst) pevm_CVTCI_i(ctx, src1, dst, FALSE)
void      pevm_CVTCI_i(void *ctx, void const *src1, void *dst, boolean cvtci);
void      pevm_CVTCN(void *ctx, void const *src1, void *dst);
void      pevm_CVTCUR(void *ctx, void const *src1, void *dst);
#define   pevm_CVTDC(ctx, src1, dst) pevm_CVTDFC(ctx, src1, (void *)0, dst)
void      pevm_CVTDFC(void *ctx, void const *src1, void const *src2, 
                      void *dst);
void      pevm_CVTEI(void *ctx, void const *src1, void *dst);
void      pevm_CVTHR(void *ctx, void const *src1, void *dst);
void      pevm_CVTIC(void *ctx, void const *src1, void *dst);
void      pevm_CVTIE(void *ctx, void const *src1, void *dst);
void      pevm_CVTIN(void *ctx, void const *src1, void *dst);
#define   pevm_CVTLC(ctx, src1, dst) pevm_CVTLFC(ctx, src1, (void *)0, dst)
void      pevm_CVTLFC(void *ctx, void const *src1, void const *src2, 
                      void *dst);
#define   pevm_CVTNC(ctx, src1, dst) pevm_CVTNFC(ctx, src1, (void *)0, dst)
void      pevm_CVTNFC(void *ctx, void const *src1, void const *src2, 
                      void *dst);
void      pevm_CVTRH(void *ctx, void const *src1, void *dst);
void      pevm_CVTURC(void *ctx, void const *src1, void *dst);
void      pevm_DECI(void *ctx, void *src1);                 /* pls_integer-- */
void      pevm_DIVN(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_EXECC(void *ctx, void const *src1, ub4 tmpub4);
#define   pevm_FTCHC(ctx, src1) pevm_BFTCHC(ctx, src1, (void *)0)

/* dynamic sql: initialize stmt (cursor) for execute immediate */
void      pevm_I4EXIM(void *ctx, void *stmt, const void *sql_str, ub2 nbinds,
                      ub2   ndefines, ub4 epurity, ub4 opf, sb4 line,
                      void *cached_cursor);

/* dynamic : execute immediate */
void      pevm_EXIM(void *ctx, void const *src1);

/* initialize for opening a cursor for a dynamic string */
void      pevm_I4OPND(void *ctx, ub1 regs, sb4 offs, void *stmt,
                      void const *sql_str, ub2 nbinds, ub4 epurity, sb4 line);

/* dynamic sql: do a dynamic OPEN on a query string */
void      pevm_OPND(void *ctx, void const *src1);

void      pevm_INCI(void *ctx, void *src1);                 /* pls_integer++ */
pevm_excs pevm_INITX(void *ctx, void const *src1, const void *src2);
void      pevm_MODI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_MOVA(void *ctx, void const *src1, void *dst);
void      pevm_MOVADT(void *ctx, void const *src1, void *dst);
#define pevm_MOVC(ctx, src1, dst) pevm_MOVC_i(ctx, (ub1)MOVC, src1, dst)
#define pevm_MOVCB(ctx, src1, dst) pevm_MOVC_i(ctx, (ub1)MOVCB, src1, dst)
void      pevm_MOVC_i(void *ctx, ub1 opc, void const *src1,
                      void *dst);
void      pevm_MOVCR(void *ctx, void const *src1, void const *src2, 
                     ub1 tmpub1, void *dst, ub1 dregs, sb4 doffs);
void      pevm_MOVD(void *ctx, void const *src1, void *dst);
void      pevm_MOVDTM(void *ctx, void const *src1, void *dst);
#define pevm_MOVFCU(ctx, src1, dst) pevm_MOVC_i(ctx, (ub1)MOVFCU, src1, dst)
void      pevm_MOVI(void *ctx, void const *src1, void *dst);
void      pevm_MOVITV(void *ctx, void const *src1, void *dst);
void      pevm_MOVLOB(void *ctx, void const *src1, void *dst);
void      pevm_MOVN(void *ctx, void const *src1, const ub1 prec,
                    const ub1 scale, void *dst);
void      pevm_MOVNU(void *ctx, void const *src1, void *dst);
void      pevm_MOVOPQ(void *ctx, void const *src1, void *dst);
void      pevm_MOVRAW(void *ctx, void const *src1, void *dst);
void      pevm_MOVREF(void *ctx, void const *src1, void *dst);
void      pevm_MOVSELFA(void *ctx, void const *src1, void *dst);
void      pevm_MOVUR(void *ctx, void const *src1, void *dst);
void      pevm_MULI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_MSET_ADT(void *ctx, const ub2 dty, void *callback, 
                        void *bhndl, void *ret);
void      pevm_MSET(void *ctx, const ub1 subcode, void const *src1,
                    void const *src2, void *dst);
/*
  General instruction for multiset operations.
  ctx - the perc
  subcode - the mset subopcode
  src1 - src1 of the multiset operation
  src2 - src2 of the multiset operation, if applicable, otherwise, null.
  dst  - dst of the multiset operation
  */
void      pevm_MULN(void *ctx, void const *src1, void const *src2, void *dst);
pevm_excs pevm_NCAL(void *ctx, ub2 did, ub2 ept, void **arg_block, void *ump);
pevm_excs pevm_SNCAL(void *ctx, ub2 did, ub2 ept, void **arg_block);
pevm_excs pevm_DCAL(void *ctx, ub2 ept, ub2 vti, ub1 **pc, dvoid ** arg_block);
void      pevm_NEGI(void *ctx, void const *src1, void *dst);
void      pevm_NEGN(void *ctx, void const *src1, void *dst);
void      pevm_PATXS(void *ctx);
pevm_excs pevm_PIPE(void *ctx, void const *var);
void      pevm_PRFTC(void *ctx, void const *src1, void const *src2);
void      pevm_RASIX(void *ctx, ub4 excp);
void      pevm_RASUX(void *ctx, ub2 did, ub2 idn);
pevm_excs pevm_RCAL(void *ctx, void const *src, void **arg_block);
void      pevm_REMI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_SETN(void *ctx, void *dst, ub1 tcat);
void      pevm_SUBI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_SUBN(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_SUBSTR(void *ctx, ub4 mode, void const *src1, void const *src2, 
                      void const *src3, void *dst);
pevm_excs pevm_TSTREF(void *ctx, void const *src1);
void      pevm_XORI(void *ctx, void const *src1, void const *src2, void *dst);

/* Frame Initialization */
#define PEVM_INIT_FRAME_HDL(hdl, mptr, dptr) \
      PETmut(hdl) = mptr;\
      PMUlen(((plsmut*)mptr)) = 0;\
      PMUpd(((plsmut*)mptr)) = (ub1 *)dptr;\
      if (dptr != (void *)0)\
       PMUflg(((plsmut*)mptr)) = PLSFPA | PLSFNULL;\
      else\
       PMUflg(((plsmut*)mptr)) = PLSFNULL;

/*
 * Scalars are quite common in generated code.
 * Rather than use the generic PEVM_INIT_FRAME_HDL
 * macro (which results in code bloat and possibly
 * poor optimization of generated code), let's use 
 * special case versions which are optimized for the
 * inlined/out-lined flavors of scalars.
 */
/* initialize Inlined Simple SCALAR */
#define pevm_INSI_ISSCALAR(hdl, mptr, dptr) \
      PETmut(hdl) = mptr;\
      PMUlen((mptr)) = 0;\
      PMUpd((mptr)) = (ub1 *)dptr;\
      PMUflg((mptr)) = PLSFNULL | PLSFPA;

/* initialize Outlined Simple SCALAR */
#define pevm_INSI_OSSCALAR(hdl, mptr) \
      PETmut(hdl) = mptr;\
      PMUlen((mptr)) = 0;\
      PMUpd((mptr)) = (ub1 *)0;\
      PMUflg((mptr)) = PLSFNULL;

/* Any scalar */
#define pevm_INSI_SCALAR(perc, hdl, mptr, dptr, flags)            \
    PETmut(hdl)  = mptr;                                          \
    PMUlen(mptr) = 0;                                             \
    PMUpd(mptr)  = dptr;                                          \
    PMUflg(mptr) = flags;                                         \

#define pevm_INSI_CURSREF(ctx, hdl, mptr, dptr) \
  pevm_INSI_OSSCALAR(hdl, mptr)

void      pevm_INSI_SCALAR_(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                            ub2 flags);

void      pevm_INSI_CURSREF_(void *ctx, void *hdl, plsmut *mptr, void *dptr);

void      pevm_INSI_UROWID(void *ctx, void *hdl, plsmut *mptr,  void *dptr,
                           ub4 maxlen, ub1 csform, ub1 lensem, 
                           pemttcat tcat, ub1 regs);

void      pevm_INSI_CHAR(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                         ub4 maxlen, ub1 csform, ub1 lensem,
                         pemttcat tcat, ub1 regs);

void      pevm_INSI_LOB(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub1 lobtype, ub1 csform,
                        ub1 regs);

void      pevm_INSI_DATETIME(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                             ub1 dtmtyp, ub1 prec, ub1 regs);

void      pevm_INSI_INTERVAL(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                             ub1 inttyp, ub1 ldp, ub1 tlp, ub1 regs);

void      pevm_INSI_ADT(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub4 ltdo_off, ub1 nact, ub1 regs);

void      pevm_INSI_OPQ(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub4 ltdo_off, ub1 regs);

void      pevm_INSI_OBJREF(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                           ub4 ltdo_off, ub1 regs);

void      pevm_INSI_INDEXED_SSCALAR(void *ctx, void *hdl, plsmut *mptr, 
                                    void *dptr, void *ehdl, ub4 ltdo_off, 
                                    ub1 eltcat, ub1 regs);

void      pevm_INSI_INDEXED_CHAR(void *ctx, void *hdl, plsmut *mptr, 
                                 void *dptr, void *ehdl, ub4 ltdo_off, 
                                 ub1 eltcat, ub1 regs,
                                 ub1 csf, ub4 mxl, ub1 lensem);

void      pevm_INSI_INDEXED_LOB(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                void *ehdl, ub4 ltdo_off, ub1 eltcat, ub1 regs,
                                ub1 csf, ub1 lobtype);

void      pevm_INSI_INDEXED_DATETIME(void *ctx, void *hdl, plsmut *mptr, 
                                     void *dptr, void *ehdl, ub4 ltdo_off, 
                                     ub1 eltcat, ub1 regs,
                                     ub1 dty, ub1 fsprec);

void      pevm_INSI_INDEXED_INTERVAL(void *ctx, void *hdl, plsmut *mptr, 
                                     void *dptr,
                                     void *ehdl, ub4 ltdo_off, ub1 eltcat, 
                                     ub1 regs,
                                     ub1 dty, ub1 ldp, ub1 fsprec);

void      pevm_INSI_INDEXED_ADT(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                void *ehdl, ub4 ltdo_off, ub1 eltcat, ub1 regs,
                                ub4 eltdo, ub1 nact);

void      pevm_INSI_INDEXED_OPQ(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                void *ehdl, ub4 ltdo_off, ub1 eltcat, ub1 regs,
                                ub4 eltdo);

void      pevm_INSI_INDEXED_OBJREF(void *ctx, void *hdl, plsmut *mptr, 
                                   void *dptr, void *ehdl, ub4 ltdo_off, 
                                   ub1 eltcat, ub1 regs, ub4 eltdo);

void      pevm_INSI_INDEXED_INDEXED(void *ctx, void *hdl, plsmut *mptr, 
                                    void *dptr, void *ehdl, ub4 ltdo_off, 
                                    ub1 eltcat, ub1 regs, ub4 eltdo_off);


#define pevm_INBI_ISSCALAR(hdl, mptr, dptr) \
        pevm_INSI_ISSCALAR(hdl, mptr, dptr)

#define pevm_INBI_OSSCALAR(hdl, mptr) \
        pevm_INSI_OSSCALAR(hdl, mptr)

void      pevm_INBI_CURSREF(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                            ub1 tcatval);

void      pevm_INBI_UROWID(void *ctx, void *hdl, plsmut *mptr,  void *dptr,
                           ub2 bind_num, ub1 csform, ub1 lensem, 
                           pemttcat tcat);

void      pevm_INBI_CHAR(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                         ub4 bind_num, ub1 csform, ub1 lensem,
                         pemttcat tcat, ub1 regs);

void      pevm_INBI_LOB(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub2 bind_num, ub1 lobtype, ub1 csform,
                        ub1 regs);

void      pevm_INBI_DATETIME(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                             ub2 bind_num, ub1 dtmtyp, ub1 prec, ub1 regs);

void      pevm_INBI_INTERVAL(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                             ub2 bind_num, ub1 inttyp, ub1 ldp, ub1 tlp, 
                             ub1 regs);

void      pevm_INBI_ADT(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub4 ltdo_off, ub2 bind_num, ub1 nact, ub1 regs);

void      pevm_INBI_OPQ(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub4 ltdo_off,  ub2 bind_num, ub1 regs);

void      pevm_INBI_OBJREF(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                           ub4 ltdo_off, ub2 bind_num, ub1 regs);

void      pevm_INBI_INDEXED_SSCALAR(void *ctx, void *hdl, plsmut *mptr, 
                                    void *dptr,
                                    void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                    ub1 eltcat, ub1 regs);

void      pevm_INBI_INDEXED_UROWID(void *ctx, void *hdl, plsmut *mptr, 
                                   void *dptr,
                                   void *ehdl, ub2 bind_num, 
                                   ub4 ltdo_off, ub1 eltcat,
                                   ub1 regs, ub1 csf,
                                   ub4 mxl, 
                                   ub1 lensem);

void      pevm_INBI_INDEXED_CHAR(void *ctx, void *hdl, plsmut *mptr, 
                                 void *dptr,
                                 void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                 ub1 eltcat, ub1 regs,
                                 ub1 csf, ub4 mxl, ub1 lensem);

void      pevm_INBI_INDEXED_DATETIME(void *ctx, void *hdl, plsmut *mptr, 
                                     void *dptr,
                                     void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                     ub1 eltcat, ub1 regs,
                                     ub1 dty, ub1 prec);

void      pevm_INBI_INDEXED_INTERVAL(void *ctx, void *hdl, plsmut *mptr, 
                                     void *dptr,
                                     void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                     ub1 eltcat, ub1 regs,
                                     ub1 dty, ub1 ldp, ub1 prec);

void      pevm_INBI_INDEXED_LOB(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                ub1 eltcat, ub1 regs,
                                ub1 csf, ub1 lobtyp);

void      pevm_INBI_INDEXED_ADT(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                 void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                 ub1 eltcat, ub1 regs,
                                 ub4 eltdo, ub1 nact);

void      pevm_INBI_INDEXED_OPQ(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                                void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                ub1 eltcat, ub1 regs,
                                ub4 eltdo);

void      pevm_INBI_INDEXED_OBJREF(void *ctx, void *hdl, plsmut *mptr, 
                                   void *dptr,
                                   void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                   ub1 eltcat, ub1 regs,
                                   ub4 eltdo);

void      pevm_INBI_INDEXED_INDEXED(void *ctx, void *hdl, plsmut *mptr, 
                                    void *dptr,
                                    void *ehdl, ub2 bind_num, ub4 ltdo_off, 
                                    ub1 eltcat, ub1 regs,  ub4 eltdo_off
                                    );

void      pevm_CCNST(void *ctx, void const *src1, void *dst);
void      pevm_INSTC2(void *ctx, void const *src1, void const *src2, 
                      void *dst, ub1 regs, sb4 offs, boolean instc2);
void      pevm_CCSINF(void *ctx, void const *src1, void *dst, ub1 srctc, 
                      ub1 dsttc);
void      pevm_EXCOD(void *ctx, void *dst);
void      pevm_EXMSG(void *ctx, void const *src1, void *dst);
void      pevm_CLOSC(void *ctx, void const *src1, ub1 suppress_error);
void      pevm_BIND(void *ctx, void const *src1, ub2 position, ub2 tmpub2,
                    void const *src2, ub2 flags, void const *src3, 
                    ub2 attr_no, ub1 opc);
void      pevm_DEFINE(void *ctx, void const *src1, ub2 position, ub2 sqlt_type,
                      ub2 flgs, void *src2);
void      pevm_FCAL(void *ctx, void const *src1);

/* Sometime, fix to use pevm_ADEFINE_i ... */
void      pevm_ADEFINE(void *ctx, void const *src1, ub2 position,
                       ub2 sqlt_type, ub2 flgs, void const *src2,
                       ub2 bind_num, void const *src3, void const *src4, 
                       ub2 attr_no, ub1 opc);
#define pevm_ARDEFINE pevm_ADEFINE

void      pevm_BDCINI_i(void *ctx, void const *src1, ub1 bdflags,
                      void const *arrhdl );


void      pevm_ARGEASCA(void       *ctx,
                        void const *src1,
                        void const *src2,
                        void       *dst);
void      pevm_ARGECOLL(void       *ctx,
                        void const *src1,
                        void const *src2,
                        void       *dst);
void      pevm_ARGEIBBI(void       *ctx,
                        void const *src1,
                        void const *src2,
                        void       *dst);
void      pevm_ARPEASCA(void       *ctx,
                        void const *src1,
                        void const *src2, 
                        void       *dst);
void      pevm_ARPECOLL(void       *ctx,
                        void const *src1,
                        void const *src2, 
                        void       *dst);
void      pevm_ARPEIBBI(void       *ctx,
                        void const *src1,
                        void const *src2, 
                        void       *dst);

void      pevm_BCNSTR(void *ctx, void const *src1, sb4 prec, sb4 scale, 
                      ub2 position, ub4 tmpub4);
pevm_excs pevm_RET(void *ctx, ub1 **pc);
#define pevm_RNDD(ctx, src1, dst) pevm_RNDDC_i(ctx, src1, (void *)0, dst, TRUE)
#define pevm_RNDDC(ctx, src1, src2, dst) \
  pevm_RNDDC_i(ctx, src1, src2, dst, TRUE)
#define pevm_TRND(ctx, src1, dst) \
  pevm_RNDDC_i(ctx, src1, (void *)0, dst, FALSE)
#define pevm_TRNDC(ctx, src1, src2, dst) \
  pevm_RNDDC_i(ctx, src1, src2, dst, FALSE)

void      pevm_RNDDC_i(void *ctx, void const *src1, void const *src2, 
                       void *dst, boolean rnddp);
void      pevm_LSTD(void *ctx, void const *src1, void *dst);

#define pevm_ADDDN(ctx, src1, src2, dst) \
  pevm_ADDDN_i(ctx, src1, src2, dst, FALSE)
#define pevm_SUBDN(ctx, src1, src2, dst) \
  pevm_ADDDN_i(ctx, src1, src2, dst, TRUE)
void      pevm_ADDDN_i(void *ctx, void const *src1, void const *src2, 
                       void *dst, boolean subdnp);
void      pevm_SUBDD(void *ctx, void const *src1, void const *src2, 
                     void *dst);
void      pevm_ADDMDN(void *ctx, void const *src1, void const *src2, 
                      void *dst);
void      pevm_MBTD(void *ctx, void const *src1, void const *src2, 
                    void *dst);
void      pevm_NXTD(void *ctx, void const *src1, void const *src2, 
                    void *dst);

struct pevmea_enter_args
{
  /* NCOMP mode related args */
  union {
    ub1      *state_buf;            /* IN: (used only if use_cstack is TRUE) */
    size_t    frame_sz;            /* IN: (used only if use_cstack is FALSE) */
  } pevmea_stack;
  void     *frame;         /* IN (use_cstack=TRUE); OUT (use_cstack = FALSE) */
  ub1     **preg_pevmea;                                  /* ncomp only, OUT */
  union {
    ub4      *lnr_pevmea;                                 /* ncomp only, OUT */
    ub1     **ppc;                           /* interpreted mode only IN/OUT */
  } pevmea_lnrppc;
};
typedef struct pevmea_enter_args pevmea_enter_args;

void      pevm_ENTER(void              *ctx,
                     ub2                entdesc_page_num,
                     ub2                entdesc_page_off,
                     pevmea_enter_args *args);


void      pevm_BNDS(void *ctx, void *bnds_curs, void const *src1, 
                    void const *src2);
void      pevm_COPN(void *ctx, void const *src1, void *dst);
pevm_excs pevm_icd_call_common(void *ctx, ub2 did, boolean not_PSDIOVER,
                               ub2 loc, ub2 argc,
                               boolean is_std, void **arg_block);
void      pevm_GBCR(void *ctx, ub2 tmpub2, void const *src1, void *dst);
void      pevm_CFND(void *ctx, void const *src1, ub1 Flag, void *dst);
void      pevm_CSFND(void *ctx, ub1 Flag, void *dst);
void      pevm_CRWC(void *ctx, void const *src1, void *dst);
void      pevm_CSRWC(void *ctx, void *dst);
void      pevm_BCRWC(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_BCSRWC(void *ctx, void const *src1, void *dst);
pevm_excs pevm_GBVAR(void *ctx, ub2 tmpub2, ub2 bind_num, void *dst);
pevm_excs pevm_SBVAR(void *ctx, ub2 tmpub2, ub2 bind_num, const void *src1);
void      pevm_GBEX(void *ctx, ub2 tmpub2, ub2 bind_num, 
                    void const *src1, void *dst);
void      pevm_SBEX(void *ctx, ub2 tmpub2, ub2 bind_num, 
                    void const *src1, void const *src2);
void      pevm_GETFX(void *ctx, ub2 tmpub2, void *dst, ub2 eltty);
void      pevm_SETFX(void *ctx, ub2 tmpub2, void const *src1, ub2 eltty);
void      pevm_MOVX(void *ctx, void const *src1, void *dst);
void      pevm_EXTX(void *ctx, void const *src1, ub4 tmpub4);

void      pevm_INMDH_CHAR(void *ctx, void *src1, ub1 csform, ub4 ctmxlen, 
                          ub1 lensem, ub1 tcat);

void      pevm_INMDH_LOB(void *ctx, void *src1, ub1 csform, ub1 lobtyp);

void      pevm_INMDH_DATETIME(void *ctx, void *src1, ub1 typ, ub1 tlp);

void      pevm_INMDH_INTERVAL(void *ctx, void *src1, ub1 typ, ub1 ldp, 
                              ub1 tlp);

void      pevm_INMDH_ADT(void *ctx, void  *src1, ub4 chtdo);
void      pevm_INMDH_INDEXED_SSCALAR(void *ctx, void  *src1, ub4 chtdo, 
                                     ub1 etcat, void *ehdl);
void      pevm_INMDH_INDEXED_OBJREF(void *ctx, void  *src1, ub4 chtdo, 
                                    ub1 etcat, void *ehdl, ub4 eltdo);
void      pevm_INMDH_INDEXED_OPQ(void *ctx, void  *src1, ub4 chtdo, 
                                 ub1 etcat, void *ehdl, ub4 eltdo);
void      pevm_INMDH_INDEXED_INDEXED(void *ctx, void  *src1, ub4 chtdo, 
                                     ub1 etcat, void *ehdl, ub4 eltdo);
void      pevm_INMDH_INDEXED_ADT(void *ctx, void  *src1, ub4 chtdo, 
                                 ub1 etcat, void *ehdl, ub4 eltdo);
void      pevm_INMDH_INDEXED_CHAR(void *ctx, void  *src1, ub4 chtdo, 
                                  ub1 etcat, void *ehdl, ub1 csf, 
                                  ub4 maxlen, ub1 lensem);
void      pevm_INMDH_INDEXED_UROWID(void *ctx, void  *src1, ub4 chtdo, 
                                    ub1 etcat, void *ehdl,  ub1 csf,
                                    ub4 maxlen, ub1 lensem);
void      pevm_INMDH_INDEXED_LOB(void *ctx, void  *src1, ub4 chtdo, 
                                 ub1 etcat, void *ehdl, ub1 csf, 
                                 ub1 maxlen);
void      pevm_INMDH_INDEXED_DATETIME(void *ctx, void  *src1, ub4 chtdo, 
                                      ub1 etcat, void *ehdl,
                                      ub1 sqlt, ub1 fsprec);
void      pevm_INMDH_INDEXED_INTERVAL(void *ctx, void  *src1, ub4 chtdo, 
                                      ub1 etcat, void *ehdl,
                                      ub1 sqlt, ub1 ldp, ub1 fsprec);
void      pevm_INMDH_OPQ(void *ctx, void  *src1, ub4 ophtdo);
void      pevm_INMDH_OBJREF(void *ctx, void  *src1, ub4 orhtdo);

void      pevm_INHFA_COMMON(void *ctx, void const *src1, void *dst, 
                             ub4 index_path_len, ...);

void pevm_INHFA1_COMMON(void *ctx, void const *src1, void *dst, ub4 idx);

void      pevm_INHFA_CHAR(void *ctx, void const *src1, void *dst, ub1 csform,
                         ub4 ctmxlen, ub1 lensem, ub1 tcat);

void      pevm_INHFA_FCHAR(void *ctx, void const *src1, void *dst, ub1 csform, 
                         ub4 ctmxlen, ub1 lensem, ub1 tcat);

void      pevm_INHFA_LOB(void *ctx, void const *src1, void *dst, ub1 lobtyp, 
                         ub1 csform);

void      pevm_INHFA_OBJREF(void *ctx, void const *src1, void *dst, 
                         ub4 ltdo_off);

void      pevm_INHFA_DATETIME(void *ctx, void const *src1, void *dst, ub1 typ,
                         ub1 tlp);

void      pevm_INHFA_INTERVAL(void *ctx, void const *src1, void *dst, ub1 typ,
                         ub1 tlp, ub1 ldp);

void      pevm_INHFA_ADT(void *ctx, void const *src1, void *dst, ub4 chtdo);

void      pevm_INHFA_OPQ(void *ctx, void const *src1, void *dst, ub4 ophtdo);

void      pevm_INHFA_INDEXED_SSCALAR(void *ctx, void const *src1, void *dst, 
                                     ub4 tdo_off, void *ehdl, ub1 eltcat);

void      pevm_INHFA_INDEXED_CHAR(void *ctx, void const *src1, void *dst, 
                                  ub4 tdo_off, void *ehdl, ub1 eltcat,
                                  ub1 csf, ub4 mxln, ub1 lensem);

void      pevm_INHFA_INDEXED_LOB(void *ctx, void const *src1, void *dst, 
                                 ub4 tdo_off, void *ehdl, ub1 eltcat,
                                 ub1 lobtyp, ub1 csf, ub1 lensem);

void      pevm_INHFA_INDEXED_DATETIME(void *ctx, void const *src1, void *dst, 
                                      ub4 tdo_off, void *ehdl, ub1 eltcat,
                                      ub1 typ, ub1 tlp);

void      pevm_INHFA_INDEXED_INTERVAL(void *ctx, void const *src1, void *dst, 
                                      ub4 tdo_off, void *ehdl, ub1 eltcat,
                                      ub1 typ, ub1 ldp, ub1 tlp);

void      pevm_INHFA_INDEXED_ADT(void *ctx, void const *src1, void *dst, 
                                 ub4 tdo_off, void *ehdl, ub1 eltcat,
                                 ub4 eltdo_off);

void      pevm_INHFA_INDEXED_INDEXED(void *ctx, void const *src1, void *dst, 
                                     ub4 tdo_off, void *ehdl, ub1 eltcat,
                                     ub4 eltdo_off);


void      pevm_INHFA_INDEXED_OPQ(void *ctx, void const *src1, void *dst, 
                                 ub4 tdo_off, void *ehdl, ub1 eltcat,
                                 ub4 eltdo_off);

void      pevm_INHFA_INDEXED_OBJREF(void *ctx, void const *src1, void *dst, 
                                    ub4 tdo_off, void *ehdl, ub1 eltcat,
                                    ub4 eltdo_off);


void      pevm_TREAT(void *ctx, 
                     void const *src1, ub4 src2, ub1 isref, void *dst);
void      pevm_CMPIO(void *ctx, 
                     void const *src1, ub4 src2, ub1 flag, void *dst);

void      pevm_ABSN(void *ctx, void const *src1, void *dst);
void      pevm_DIVI(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_ISNULL(void *ctx, const ub1 isn_code,
                      void const *src1, void *dst);

void      pevm_NULCHK(void *ctx, const ub1 nul_code, void const* src1);
void      pevm_RNGCHKI(void *ctx, const ub1 range_code,
                       void const* src1, void const* bndl, void const* bndh);
void      pevm_RNGCHKF(void *ctx, const ub1 range_code,
                       void const* src1, void const* bndl, void const* bndh);
void      pevm_ANDB(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_ORB(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_NOTB(void *ctx, void const *src1, void *dst);
void      pevm_CHSNULL(void *ctx, const ub2 chs_code, 
                       void const *src1, void const *src2, void const *src3, 
                       void *dst);
#define pevm_NVL(ctx, nvl_code, src1, src2, dst) \
        pevm_CHSNULL((ctx), (nvl_code), (src1), (src2), (src1), (dst))
void      pevm_REL2BOOL(void *ctx, const ub1 rel_code, 
                        void const *src1, void const *src2, void *dst);
void      pevm_MINMAX(void *ctx, const ub1 ext_code, 
                      void const *src1, void const *src2, void *dst);

void      pevm_ADDD(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_ADDF(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_SUBD(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_SUBF(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_MULD(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_MULF(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_DIVD(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_DIVF(void *ctx, void const *src1, void const *src2, void *dst);
void      pevm_NEGD(void *ctx, void const *src1, void *dst);
void      pevm_NEGF(void *ctx, void const *src1, void *dst);
void      pevm_ABSD(void* ctx, void const* src1, void* dst);
void      pevm_ABSF(void* ctx, void const* src1, void* dst);
void      pevm_MOVDBL(void *ctx, void const *src1, void *dst);
void      pevm_MOVFLT(void *ctx, void const *src1, void *dst);
pevm_excs pevm_CMP3DBL(void *ctx, void const *src1, void const *src2);
pevm_excs pevm_CMP3FLT(void *ctx, void const *src1, void const *src2);
void      pevm_VATTR(void *ctx, const ub1 subcode,
                     void const *src1, void *dst);
void      pevm_FTCHC_PSEUDO(void *ctx, void const *src1);
void      pevm_VALIST(void *ctx, const ub2 src1, void *src2, void *dst);
void      pevm_VALISTINI(void *ctx, const ub4 src1, void *dst);
void      pevm_VCAL(void *ctx, const ub1 sub_op, const ub1 argc, 
                    void **argblock);
void      pevm_OVER(void *ctx, ub2 src1, void const *src2,
                    void const *src3, void const *src4,
                    void const *src5, void *dst);

/*
 * function REGEXP_LIKE (srcstr   VARCHAR2 CHARACTER SET ANY_CS,
 *                       pattern  VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                       modifier VARCHAR2 DEFAULT NULL)
 */
void      pevm_REGEXP_LIKE_TXT(void *ctx, void *srcloc, void *patloc,
                               void *dst);


/*
 * function REGEXP_INSTR(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
 *                       pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                       position    PLS_INTEGER := 1,
 *                       occurrence  PLS_INTEGER := 1,
 *                       returnparam PLS_INTEGER := 0,
 *                       modifier    VARCHAR2 DEFAULT NULL)
 *      return PLS_INTEGER;
 */
void      pevm_REGEXP_INSTR_TXT(void *ctx, void *srcloc, void *patloc,
                                void *posloc, void *occurloc, void *retfloc,
                                void *dst);

/*
 * function REGEXP_SUBSTR(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
 *                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                        position    PLS_INTEGER := 1,
 *                        occurrence  PLS_INTEGER := 1,
 *                        modifier    VARCHAR2 DEFAULT NULL)
 *       return VARCHAR2 CHARACTER SET srcstr%CHARSET;
 */
void      pevm_REGEXP_SUBSTR_TXT(void *ctx, void *srcloc, void *patloc,
                                 void *posloc, void *occurloc,
                                 void *dst);

/*
 * function REGEXP_REPLACE(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
 *                         pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                         replacestr  VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                         position    PLS_INTEGER := 1,
 *                         occurrence  PLS_INTEGER := 0,
 *                         modifier    VARCHAR2 DEFAULT NULL)
 *      return VARCHAR2 CHARACTER SET srcstr%CHARSET;
 */
void      pevm_REGEXP_REPLACE_TXT(void *ctx, void *srcloc, void *patloc,
                                  void *reploc, void *posloc, void *occurloc,
                                  void *dst);

/* LOB REGEXP functions */
/*
 * function REGEXP_LIKE (srcstr   CLOB CHARACTER SET ANY_CS,
 *                       pattern  VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                       modifier VARCHAR2 DEFAULT NULL)
 */
void      pevm_REGEXP_LIKE_CLB(void *ctx, void *srcloc, void *patloc,
                               void *dst);

/*
 * function REGEXP_INSTR(srcstr      CLOB CHARACTER SET ANY_CS,
 *                       pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                       position    PLS_INTEGER := 1,
 *                       occurrence  PLS_INTEGER := 1,
 *                       returnparam PLS_INTEGER := 0,
 *                       modifier    VARCHAR2 DEFAULT NULL)
 *      return PLS_INTEGER;
 */
void      pevm_REGEXP_INSTR_CLB(void *ctx, void *srcloc, void *patloc,
                                void *posloc, void *occurloc, void *retfloc,
                                void *dst);

/*
 * function REGEXP_SUBSTR(srcstr      CLOB CHARACTER SET ANY_CS,
 *                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                        position    PLS_INTEGER := 1,
 *                        occurrence  PLS_INTEGER := 1,
 *                        modifier    VARCHAR2 DEFAULT NULL)
 *      return CLOB CHARACTER SET srcstr%CHARSET;
 */
void      pevm_REGEXP_SUBSTR_CLB(void *ctx, void *srcloc, void *patloc,
                                 void *posloc, void *occurloc, void *dst);

/*
 * function REGEXP_REPLACE(srcstr      CLOB CHARACTER SET ANY_CS,
 *                         pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                         replacestr  CLOB CHARACTER SET srcstr%CHARSET,
 *                         position    PLS_INTEGER := 1,
 *                         occurrence  PLS_INTEGER := 0,
 *                         modifier    VARCHAR2 DEFAULT NULL)
 *       return CLOB CHARACTER SET srcstr%CHARSET;
 */
void      pevm_REGEXP_REPLACE_CLB(void *ctx, void *srcloc, void *patloc,
                                  void *reploc, void *posloc, void *occurloc,
                                  void *dst);

/*
 * function REGEXP_REPLACE(srcstr      CLOB CHARACTER SET ANY_CS,
 *                         pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                         replacestr  VARCHAR2 CHARACTER SET srcstr%CHARSET,
 *                         position    PLS_INTEGER := 1,
 *                         occurrence  PLS_INTEGER := 0,
 *                         modifier    VARCHAR2 DEFAULT NULL)
 *       return CLOB CHARACTER SET srcstr%CHARSET;
 */
void      pevm_REGEXP_REPLACE_CLB2(void *ctx, void *srcloc, void *patloc,
                                   void *reploc, void *posloc, void *occurloc,
                                   void *dst);

/* Compile REGEXP pattern */
void      pevm_RCPAT(void *ctx, void *patloc, void *cflagloc, ub1 lobflag,
                     void *dst);

void      pevm_INSI_RCPAT(void *ctx, void *hdl, plsmut *mptr, void *dptr,
                        ub1 regs);

/* Raise an exception */

void pevm_RAISE_JUMP(void *ctx);

/*---------------------------------------------------------------------------
                          PRIVATE FUNCTIONS
 ---------------------------------------------------------------------------*/


/* DON'T ADD ANY PRIVATE FUNCTIONS TO THIS FILE. THIS FILE IS SHIPPED
 * FOR PL/SQL NCOMP. ADD PRIVATE FUNCTIONS TO pvm0.h.
 */


#endif                                              /* PEVM_ORACLE */
