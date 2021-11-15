             CMD        PROMPT('Print pdf from ifs') +
                          TEXT(*SRCMBRTXT) ALLOW(*ALL) MODE(*ALL) +
                          ALWLMTUSR(*NO) THDSAFE(*NO) AUT(*EXCLUDE)

             PARM       KWD(PATH) TYPE(*PNAME) LEN(512) MIN(1) +
                          MAX(1) INLPMTLEN(32) PROMPT('IFS-Path to +
                          PDF')
             PARM       KWD(OUTQ) TYPE(OBJLIB) MIN(1) +
                          PROMPT('Outqueue')

 OBJLIB:     QUAL       TYPE(*SNAME)
             QUAL       TYPE(*SNAME) DFT(*LIBL) SPCVAL((*LIBL +
                          *LIBL)) PROMPT('Library')
