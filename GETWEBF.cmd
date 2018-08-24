             CMD        PROMPT('Download file onto ifs') +
                          TEXT('Download file onto ifs') +
                          ALLOW(*ALL) MODE(*ALL) ALWLMTUSR(*NO) +
                          AUT(*EXCLUDE)

             PARM       KWD(URL) TYPE(*CHAR) LEN(128) MIN(1) +
                          CHOICE('Valid http-url') PROMPT('URL')
             PARM       KWD(PATH) TYPE(*PNAME) LEN(128) MIN(1) +
                          PROMPT('IFS-path')