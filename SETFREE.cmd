             CMD        PROMPT('Set Sourcecolor') ALWLMTUSR(*NO) +
                          AUT(*EXCLUDE)

             PARM       KWD(SRCFILE) TYPE(QUALOBJ) MIN(1) +
                          PROMPT('Sourcefile')
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Sourcemember')

 QUALOBJ:    QUAL       TYPE(*NAME) MIN(0)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL *LIBL)) +
                          MIN(0) PROMPT('Library')
