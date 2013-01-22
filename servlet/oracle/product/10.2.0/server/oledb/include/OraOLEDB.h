
/* Copyright (c) 1999, 2005, Oracle. All rights reserved.  */
/*
**  NAME
**    OraOLEDB.h -- Include file for Oracle Provider for OLE DB
**
**  DESCRIPTION
**
**
**  RELATED DOCUMENTS
**
**  INSPECTION STATUS
**    Inspection date:
**    Inspection status:
**    Estimated increasing cost defects per page:
**    Rule sets:
**
**  ACCEPTANCE REVIEW STATUS
**    Review date:
**    Review status:
**    Reviewers:
**
**  PUBLIC FUNCTIONS
**
**  PRIVATE FUNCTIONS
**
**    NOTE: If any
**
**  MODIFIED   (MM/DD/YY)
**   ssomanat   04/21/05  - Added Statement Caching feature
**   smushran   07/19/00  - Custom property set
**   smushran   09/10/99  - Creation
*/

#ifndef __ORAOLEDB_H__
#define __ORAOLEDB_H__

#ifndef EXTERN_C
# ifdef __cplusplus
#  define EXTERN_C extern "C"
# else
#  define EXTERN_C extern
# endif
#endif

#ifdef DBINITCONSTANTS

EXTERN_C const CLSID CLSID_OraOLEDB = \
    {0x3F63C36E,0x51A3,0x11D2,{0xBB,0x7D,0x00,0xC0,0x4F,0xA3,0x00,0x80}};

EXTERN_C const CLSID CLSID_OraOLEDBErrorLookup = \
    {0x3FC8E6E4,0x53FF,0x11D2,{0xBB,0x7D,0x00,0xC0,0x4F,0xA3,0x00,0x80}};

EXTERN_C const IID LIBID_ORAOLEDBLib = \
    {0x0BB9AFD1,0x51A1,0x11D2,{0xBB,0x7D,0x00,0xC0,0x4F,0xA3,0x00,0x80}};

EXTERN_C const GUID ORAPROPSET_COMMANDS = \
    {0x8B92E3F1,0x4C70,0x11D4,{0x91,0x1B,0x00,0xC0,0x4F,0x4C,0x7E,0x26}};

#else /* DBINITCONSTANTS */

EXTERN_C const CLSID CLSID_OraOLEDB;
EXTERN_C const CLSID CLSID_OraOLEDBErrorLookup;
EXTERN_C const IID   LIBID_ORAOLEDBLib;
EXTERN_C const GUID  ORAPROPSET_COMMANDS;

#endif /* DBINITCONSTANTS */


/*
** Property Ids
*/
#define ORAPROP_PLSQLRSet	      1
#define ORAPROP_SPPrmsLOB	      2
#define ORAPROP_NDatatype	      3
#define ORAPROP_AddToStmtCache	4


#ifdef __cplusplus

class DECLSPEC_UUID("3F63C36E-51A3-11D2-BB7D-00C04FA30080")
OraOLEDB;

class DECLSPEC_UUID("3FC8E6E4-53FF-11D2-BB7D-00C04FA30080")
OraOLEDBErrorLookup;

#endif

#endif /* __ORAOLEDB_H__ */
