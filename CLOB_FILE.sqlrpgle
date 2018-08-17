DCL-S CLOB_File SQLTYPE(CLOB_FILE) CCSID(1208);
DCL-S MailAdress VARCHAR(128) INZ;
DCL-S Message VARCHAR(128) INZ;
//-------------------------------------------------------------------------

 Message = 'This is a easy simple text';

 // create streamfile - UTF8
 CLOB_File_NAME = '/tmp/sample.txt';
 CLOB_File_NL = %Len(%Trim(CLOB_File_NAME));
 CLOB_File_FO = SQFOVR;
 Exec SQL SET :CLOB_File = TRIM(CAST(:Message AS CLOB(128) CCSID 1208));
