             CMD        PROMPT('Change object attributes') +
                          TEXT(*SRCMBRTXT) ALLOW(*ALL) MODE(*ALL) +
                          ALWLMTUSR(*NO) THDSAFE(*NO) AUT(*EXCLUDE)

             PARM       KWD(OBJ) TYPE(OBJLIB) MIN(1) MAX(1) +
                          PROMPT('Objectname')

             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          VALUES(*ALRTBL *BNDDIR *CHTFMT *CLD *CLS +
                          *CMD *CRG *CRQD *CSI *CSPMAP *CSPTBL +
                          *DTAARA *DTAQ *EDTD *EXITRG *FCT *FILE +
                          *FNTRSC *FNTTBL *FORMDF *FTR *GSS *IGCDCT +
                          *IGCSRT *IGCTBL *IMGCLG *JOBD *JOBQ +
                          *JOBSCD *JRN *JRNRCV *LIB *LOCALE *MEDDFN +
                          *MENU *MGTCOL *MODULE *MSGF *MSGQ *NODGRP +
                          *NODL *NWSCFG *OUTQ *OVL *PAGDFN *PAGSEG +
                          *PDFMAP *PDG *PGM *PNLGRP *PRDAVL *PRDDFN +
                          *PRDLOD *PSFCFG *QMFORM *QMQRY *QRYDFN +
                          *RCT *SBSD *SCHIDX *SPADCT *SQLPKG +
                          *SQLUDT *SQLXSR *SRVPGM *SSND *SVRSTG +
                          *S36 *TBL *TIMZON *USRIDX *USRQ *USRSPC +
                          *VLDL *WSCST) MIN(1) CHOICE('Type') +
                          PROMPT('Objecttype')

             PARM       KWD(SYSNAME) TYPE(*CHAR) LEN(8) DFT(*SAME) +
                          CASE(*MIXED) CHOICE('Character') +
                          PROMPT('New systemname')

             PARM       KWD(USRPRF) TYPE(*CHAR) LEN(10) DFT(*SAME) +
                          CASE(*MIXED) CHOICE('Character') +
                          PROMPT('New userprofile')

             PARM       KWD(CRTDATE) TYPE(*CHAR) LEN(13) DFT(*SAME) +
                          SPCVAL((*SAME *SAME)) FULL(*YES) +
                          CASE(*MIXED) CHOICE('1YYMMTThhmmss') +
                          PROMPT('New stamp')

             PARM       KWD(NEWOWN) TYPE(*NAME) LEN(10) DFT(*SAME) +
                          SPCVAL((*SAME *SAME)) PROMPT('New +
                          objectowner')

 OBJLIB:     QUAL       TYPE(*SNAME)
             QUAL       TYPE(*SNAME) DFT(*LIBL) SPCVAL((*LIBL +
                          *LIBL)) PROMPT('Library')
