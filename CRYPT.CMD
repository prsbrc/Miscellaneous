             CMD        PROMPT('TDES en-/decryption') ALWLMTUSR(*NO) +
                          VLDCKR(CRYPTIFSC1) AUT(*EXCLUDE)
             PARM       KWD(MODE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*ENC) VALUES(*ENC *DEC *B64) MIN(0) +
                          MAX(1) PROMPT('Mode')
             PARM       KWD(FROMSTMF) TYPE(*PNAME) LEN(128) MIN(1) +
                          MAX(1) PROMPT('From streamfile')
             PARM       KWD(TOSTMF) TYPE(*PNAME) LEN(128) MIN(1) +
                          MAX(1) PROMPT('To streamfile')
             PARM       KWD(KEY) TYPE(*CHAR) LEN(32) CASE(*MIXED) +
                          DSPINPUT(*NO) PROMPT('Key')
             PARM       KWD(DELETE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Delete +
                          original')