             CMD        PROMPT('Encryption/decryption') +
                          TEXT('Encrypt or decrypt files') +
                          ALLOW(*ALL) MODE(*ALL) ALWLMTUSR(*NO) +
                          AUT(*EXCLUDE)
             PARM       KWD(MODE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(*ENCRYPT) SPCVAL(('*ENCRYPT' '1') +
                          (*DECRYPT '2') ('*ENCODE64' '3') +
                          (*DECODE64 '4')) PROMPT('Mode')
             PARM       KWD(FROMSTMF) TYPE(*PNAME) LEN(256) +
                          PROMPT('From streamfile')
             PARM       KWD(TOSTMF) TYPE(*PNAME) LEN(256) MAX(1) +
                          PROMPT('To streamfile')
             PARM       KWD(DELETE) TYPE(*LGL) RSTD(*YES) DFT(*NO) +
                          SPCVAL((*YES '1') (*NO '0')) +
                          PROMPT('Delete original file')
             PARM       KWD(PWD) TYPE(*CHAR) LEN(32) CASE(*MIXED) +
                          DSPINPUT(*NO) PMTCTL(CTLPWD) +
                          PROMPT('Password')

 CTLPWD:     PMTCTL     CTL(MODE) COND((*EQ '1') (*EQ '2')) +
                          NBRTRUE(*EQ 1) LGLREL(*OR)
