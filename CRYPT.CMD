             CMD        PROMPT('Encryption/decryption') +
                          TEXT('Encrypt or decrypt files') +
                          ALLOW(*ALL) MODE(*ALL) ALWLMTUSR(*NO) +
                          AUT(*EXCLUDE)
             PARM       KWD(MODE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*ENC) VALUES(*ENC *DEC *B64) +
                          PROMPT('Mode')
             PARM       KWD(FROMSTMF) TYPE(*PNAME) LEN(128) +
                          PROMPT('From streamfile')
             PARM       KWD(TOSTMF) TYPE(*PNAME) LEN(128) MAX(1) +
                          PROMPT('To streamfile')
             PARM       KWD(PWD) TYPE(*CHAR) LEN(128) CASE(*MIXED) +
                          DSPINPUT(*NO) PROMPT('Password')
             PARM       KWD(DELETE) TYPE(*LGL) RSTD(*YES) DFT(*NO) +
                          SPCVAL((*YES '1') (*NO '0')) +
                          PROMPT('Delete original')
