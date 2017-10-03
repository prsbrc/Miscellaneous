     D CLOB_File       S                   SQLTYPE(CLOB_FILE) CCSID(1208)
     D Message         S          32000A   VARYING INZ 
     D MailAdress      S            256A   VARYING INZ
      *-------------------------------------------------------------------------

	  Message = 'This is a easy simple text';
	  
      // create streamfile - UTF8
      CLOB_File_NAME = '/tmp/sample.txt';
      CLOB_File_NL = %Len(%Trim(CLOB_File_NAME));
      CLOB_File_FO = SQFOVR;
      Exec SQL SET :CLOB_File = TRIM(CAST(:Message AS CHAR(32000) CCSID 1208));

      // read mailadress and send
      Exec SQL SELECT STRIP(SMTPUID) CONCAT '@' CONCAT STRIP(DOMROUTE)
                 INTO :MailAdress
                 FROM QUSRSYS.QATMSMTPA A JOIN QUSRSYS.QAOKL02A B
                   ON (B.WOS1USRP = USER AND B.WOS1DDEN = A.USERID AND
                       B.WOS1DDGN = A.ADDRESS)
                FETCH FIRST 1 ROW ONLY;
      System('SNDSMTPEMM RCP(('+''''+%Trim(MailAdress)+''''+')) '+
             'SUBJECT(''Text for subject'') '+
             'ATTACH(''/tmp/sample.txt'') CHARSET(*UTF8)');
