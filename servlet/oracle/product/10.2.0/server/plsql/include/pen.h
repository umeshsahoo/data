/* Copyright (c) 1998, 2003, Oracle Corporation.  All rights reserved.  */
/* 
   NAME 
     pen.h - PL/SQL Execute Native interfaces.

     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     **!!!! THIS FILE IS SHIPPED FOR NCOMP.                        !!!!
     **!!!!                                                        !!!!
     **!!!! If you change it for a bug fix, you will need to make  !!!!
     **!!!! sure it is re-shipped also along with the new binaries.!!!!
     **!!!! Please make this note in the BUGDB along with your fix.!!!!
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   DESCRIPTION 
     This file is the PRIMARY file included by the C sources that 
     are generated as a result of native compilation of PL/SQL
     source programs.

     This file in turn includes a minimal number of other files
     such as (oratypes.h, pvm.h & pdtyp.h & pptyp.h). Be very cautious
     when making changes to pen.h or other files included by it. 
     Because these changes might require recompilation of generated C
     sources or introduce compatibility problems. The goal is to
     keep the dependency of the generated code on the PL/SQL
     run-time to a minimal. For instance, PERC structure should not
     be exposed in any pen.h/pvm.h/pdtyp.h. In the generated code
     the PERC will simply be a opaque context pointer.

     pen.h   -- defns used only by ncomp generated C modules.

     pn.h    -- defns used by ncomp generated C modules and native
                compiler.

     pvm.h   -- defns common to the ncomp generated C modules, native 
                run-time libraries & interpreted run-time libraries.

     pdtyp.h -- (PRIVATE) defns common to ncomp generated C modules,
                native run-time libraries, interpreted run-time libraries,
                and PL/SQL COG.

     pptyp.h -- (PUBLIC) stuff common to ncomp generated C modules,
                native run-time libraries, interpreted run-time libraries,
                PL/SQL COG, and external groups (RDBMS, ICD implementors).

     oratypes.h -- Oracle type defns.

     CAUTION:

     Do not put any interpreter specific definitions in pen.h (or files
     included by pen.h such as pvm.h/pdtyp.h/pptyp.h). Such definitions
     belong in pfrdef.h/pfmdef.h. Internal support functions not required
     by generated C code belongs to pet.h/pvm0.h.

   RELATED DOCUMENTS 
 
   INSPECTION STATUS 
     Inspection date: 
     Inspection status: 
     Estimated increasing cost defects per page: 
     Rule sets: 
 
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
   jmuller     11/06/03 - Fix bug 3178062: add cleanuplabel to _EXECS 
   astocks     11/25/03 - JMPBUF_ALLOC
   dbronnik    10/07/03 - 
   dbronnik    11/25/03 - Add pen_FIELDS
   dbronnik    11/20/03 - Move slgjmp business to spen0.h
   dbronnik    09/30/03 - Change exception handling
   rpang       08/20/03 - Added enter desc page number/offset to pen_PCLABELGET
   astocks     07/23/03 - Bug 2135852
   cwethere    07/08/03 - Remove old branch instructions.
   sylin       06/19/03 - Replace pen_CALL with pen_CALL_SETUP
   astocks     04/15/03 - Remove excess styles
   kmuthukk    01/13/03 - ncomp tuning
   astocks     01/23/03 - Lint
   astocks     01/10/03 - Ctl-C
   sylin       01/11/03 - 2711796: Remove is_sr_package from pen_INST
   mvemulap    10/19/02 - remove arrhdl from pen_BDCINI
   astocks     10/21/02 - Fix BDCINI
   dbronnik    10/07/02 - Add pen_BCTR
   sagrawal    09/27/02 - native support for sparse collections in bulk binds
   astocks     07/10/02 - Improve prototype for calls
   astocks     05/10/02 - More entries
   mvemulap    04/22/02 - remove const specifier in penlur_lib_unit_root
   mvemulap    01/04/02 - move scd to sga
   sylin       10/25/01 - 1863759: Implement ncomp tracing support
   sylin       10/18/01 - Add frame,preg and lnr to pen_PCLABELGET
   sylin       09/20/01 - remove pen_PIPE()
   sylin       09/18/01 - 1993492: use PE_PSUSPEND for ncomp pipelined function
   sylin       08/17/01 - 1864137: Pipelined function support for ncomp
   mvemulap    04/29/01 - remove const for eptvec_penlur decl
   kmuthukk    03/20/01 - fast reinit pkgs
   mvemulap    03/29/01 - compiler warnings
   mvemulap    01/31/01 - fix compiler warning
   dbronnik    12/06/00 - move CHK_INST to pvm.h
   kmuthukk    12/02/00 - penrun() moved to pen0.h
   kmuthukk    12/01/00 - remove s.h include
   dbronnik    11/29/00 - naming conventions
   dbronnik    11/21/00 - Ctrl-C support
   dbronnik    11/20/00 - add pen_PIPE
   mvemulap    11/07/00 - use const qualifier for penexc_parent
   mvemulap    11/01/00 - add const qual to entries in penexcdsc
   mvemulap    10/30/00 - move lnr to perc
   mvemulap    10/20/00 - change penrun prototype
   mvemulap    10/15/00 - modify penexcentry
   mvemulap    10/13/00 - add pen_INSTSR
   mvemulap    10/07/00 - add macro for GF
   mvemulap    09/23/00 -  
   mvemulap    08/24/00 - remove pen_RET
   mvemulap    08/14/00 - 
   mvemulap    07/30/00 -  
   mvemulap    07/25/00 - add rpc scd defn
   mvemulap    06/27/00 - tdo handle segment
   mvemulap    06/16/00 - PW -> PE
   sagrawal    07/03/00 - Dynamic dispatch
   kmuthukk    03/10/00 - more microkernels
   mvemulap    11/05/99 - 
   mvemulap    11/04/99 - 
   mvemulap    10/08/99 - add pvm_CVTNC
   mvemulap    09/14/99 - add pen_search_excp                                  
   kmuthukk    04/12/99 - return ub1 instead of perexc
   kmuthukk    03/24/99 - change dvoid * to void *
   mvemulap    03/12/99 - extra state arg to pen_ENTER                         
   kmuthukk    02/04/99 - DPF register                                         
   kmuthukk    02/03/99 - GF and DLO access                                    
   mvemulap    01/19/99 - add INSTNL and NCAL                                  
   kmuthukk    01/06/99 - fix comments                                         
   mvemulap    12/03/98 - add pen_XCAL                                         
   kmuthukk    11/25/98 - support for comparison/branch instructions           
   kmuthukk    11/04/98 - PL/SQL execute native interfaces                     
   kmuthukk    11/04/98 - Creation
*/

#ifndef PEN_ORACLE
# define PEN_ORACLE

# ifndef PN_ORACLE
#  include <pn.h>
# endif

# ifndef PVM_ORACLE
#  include <pvm.h>
# endif

# ifndef SPEN0_ORACLE
#  include <spen0.h>
# endif

#ifndef DISCARD
# define DISCARD (void)
#endif

/*---------------------------------------------------------------------------
                     PUBLIC TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/* type definition of an entry point function */
typedef pevm_excs (*pen_ept_fn_type)(void *ctx, void **argv);

/* type definition of the entry point vector */
typedef pen_ept_fn_type pen_ept_vec_type[];

/* type definition of a slot array initializer function */
typedef void (*pen_saif_type)(void **slot_array, void *frame);

/*
 * penlur_lib_unit_root: Is this root structure that leads to all
 * information about a native compiled library-unit.
 */
struct  penlur_lib_unit_root
{
  const struct pnpkd     *pkd_penlur;       /* package (lib-unit) definition */
  pen_ept_vec_type *eptvec_penlur;               /* entry point vector */
  pen_saif_type     saif_penlur;             /* slot array initializer */
};
typedef struct penlur_lib_unit_root penlur_lib_unit_root;

/* represenation of one entry in an exception descriptor in pnc-C files */
struct penexcentry
{
  ub4   penedoer;                                              /* OER number */
  ub2   peneddid;                                              /* did number */
  ub2   penedidn;                                    /* exception identifier */
  ub4   penealtern;                                 /* exception alternative */
  ub4   peneline;                     /* line number where exception handled */
};
typedef struct penexcentry penexcentry;

/* represenation of the exception descriptor in pnc-C files */
struct penexcdsc
{
  ub4          count;                                   /* number of entries */
  const struct penexcdsc  *penexc_parent;             /* parent excp handler */
  const penexcentry *entries;                                     /* entries */
};
typedef struct penexcdsc penexcdsc;

/* long jump exception handler buffer */
struct pen_buffer
{
  pevm_jmpbuf buffer_pen_buffer;
  pevm_jmpbuf *save_pen_buffer;
  boolean     Must_Free;
};
typedef struct pen_buffer pen_buffer;

#define PEN_EXENTRY(x) ((((x).peiebarexc)->entries)[(x).index])
#define PEN_IS_SPECIAL_HANDLER(x) (((x).penedoer == 0) && ((x).penedidn == 2))

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
                           PUBLIC FUNCTIONS
 ---------------------------------------------------------------------------*/
/* _EXEC: The instruction can only return PE_NONE */
#define _EXEC(instrn) DISCARD instrn

/* _EXECN: Jump to null label when the instruction returns 
 * PE_NUL */
#define _EXECN(instrn, null_lbl) \
  if ((psw = instrn) == PE_NUL) \
     goto null_lbl

/* Variation for PIPE */
#define _EXECS(ctx, instrn, plp, suspend_idx, cleanup_idx, ern, excp_range) \
plp##cleanup_idx:\
  ern = (excp_range);\
  if ((psw = instrn) == PE_PSUSPEND)\
  {\
    pen_PCLABELSET(ctx, (ub4)suspend_idx, (ub4)cleanup_idx);\
    return PE_PSUSPEND; \
  }\
plp##suspend_idx:

/* _RET: Return instrn */
#define _RET(instrn, excp_lbl) \
  if (instrn) \
      goto excp_lbl; \
  else \
      return PE_NONE

/* BRANCH instructions */

#define pen_BREQ(ctx, psw, target_label) \
  if (psw & PE_ZER) goto target_label; 

#define pen_BRLT(ctx, psw, target_label) \
  if (psw & PE_NEG) goto target_label;

#define pen_BRLE(ctx, psw, target_label) \
  if (psw & (PE_NEG | PE_ZER)) goto target_label;

#define pen_BRREINI(ctx, target_label) \
  if (pevm_BRREINI(ctx)) goto target_label;

/* Miscellaneous renames */
#define pen_INSTC3 pevm_INSTC2

/* Flavors of BIND */
#define pen_BIND(ctx, src1, position, tmpub2, src2, flags) \
  pevm_BIND((ctx), (src1), (position), (tmpub2), (src2), (flags), (void *)0, 0, BIND) 

#define pen_CBIND(ctx, src1, position, tmpub2, src2, flags) \
  pevm_BIND((ctx), (src1), (position), (tmpub2), (src2), (flags), (void *)0, 0, CBIND) 

#define pen_RBIND(ctx, src1, position, tmpub2, src2, flags, src3, attr_no) \
  pevm_BIND((ctx), (src1), (position), (tmpub2), (src2), (flags),          \
            (src3), (attr_no), RBIND) 

/* INST: Instantiate another libunit body (and spec if
 * it is a package or a type libunit)
 */
void pen_INST(void *ctx, ub2 did, ub1 instkind);

void pen_CALL_SETUP(dvoid *ctx, pemtshd **arg_block);

/* XCAL: Call an entrypoint in an eXternal libunit */
void pen_XCAL_i(void *ctx, ub2 did, ub2 ept, pemtshd **arg_block,
                boolean xcalp);
#define pen_XCAL(ctx, did, ept, arg_block) \
        pen_XCAL_i((ctx), (did), (ept), (arg_block), TRUE)
#define pen_SCAL(ctx, did, ept, arg_block) \
        pen_XCAL_i((ctx), (did), (ept), (arg_block), FALSE)

/* DCAL: Call an entrypoint in an eXternal dynamic libunit */
#define pen_DCAL(ctx, did, ept, vti,  arg_block) \
        DISCARD pevm_DCAL((ctx), (ept), (vti), (ub1 **)0, (void **)(arg_block))

/* RCAL: Remote call */
#define pen_RCAL(ctx, src, arg_block) \
        DISCARD pevm_RCAL((ctx), (src), (void **)(arg_block))

ub4 pen_search_excp(void *ctx, const struct penexcdsc *excdsc);

void pen_ICAL(void *ctx, ub2 did, ub2 indicator, ub2 loc, ub2 argc, 
              pemtshd **arg_block);

#define pen_BCAL(ctx, loc, argc, arg_block) \
   pevm_icd_call_common((ctx), 0, 0, (loc), (argc), TRUE, ((void **)(arg_block))+1)

#define pen_MOVA(ctx, dst, src) (*(dst)) = (src)

#define pen_BDCINI_COLL(ctx, src1, bdflags, arrhdl) \
        pevm_BDCINI_i((ctx), (src1), (bdflags), (arrhdl))
#define pen_BDCINI(ctx, src1, bdflags) \
        pevm_BDCINI_i((ctx), (src1), (bdflags), (void *) 0)
pevm_excs pen_UNHNDLD(void *ctx);

ub4 pen_PCLABELGET(void *ctx, ub2 entdesc_page_num, ub2 entdesc_page_off,
                   void *frame, ub1 ***out_reg, ub4 **lnr);

void pen_PCLABELSET(void *ctx, ub4 suspendlabel, ub4 cleanuplabel);

void pen_CTRLC(void *ctx);

boolean pen_BCTR(void const *src1, void const *src2);

#define pen_CHK_CTRL_BRK(ctx) \
do {if (--(((pvm_ctx_pub *)ctx)->ctlc_cnt) <= 0) pen_CTRLC(ctx); } while (0)

void pen_JMPBUF(void *ctx, pen_buffer *buffer);
void pen_JMPBUF_ALLOC(void *ctx, pen_buffer **buffer, size_t Buf_Size);

void pen_FIELDS(void *ctx, pevmea_enter_args *args);

/*---------------------------------------------------------------------------
                          PRIVATE FUNCTIONS
 ---------------------------------------------------------------------------*/

#endif                                                         /* PEN_ORACLE */
