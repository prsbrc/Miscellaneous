DCL-S CLOB_File SQLTYPE(CLOB_FILE) CCSID(1208);
DCL-S MailAdress VARCHAR(128) INZ;
DCL-S Message VARCHAR(128) INZ;
//-------------------------------------------------------------------------

 Message = 'This is a easy simple text';

 // create streamfile - UTF8
 CLOB_File_NAME = '/tmp/sample.txt';
 CLOB_File_NL = %Len(%Trim(CLOB_File_NAME));
 CLOB_File_FO = SQFOVR;
 Exec SQL SET :CLOB_File = TRIM(CAST(:Message AS CLOB(16K) CCSID 1208));

 // read mailadress and send message
 Exec SQL SELECT STRIP(A.SMTPUID) CONCAT '@' CONCAT STRIP(A.DOMROUTE)
            INTO :MailAdress
            FROM QUSRSYS.QATMSMTPA A JOIN QUSRSYS.QAOKL02A B
              ON (B.WOS1USRP = USER AND B.WOS1DDEN = A.USERID AND
                  B.WOS1DDGN = A.ADDRESS)
           FETCH FIRST 1 ROW ONLY;
 System('SNDSMTPEMM RCP(('+''''+%Trim(MailAdress)+''''+')) '+
        'SUBJECT(''Sample'') '+
        'NOTE('+''''+%Char(%TimeStamp())+''''+') '+
'ATTACH(''/tmp/sample.txt'') CHARSET(*UTF8)');