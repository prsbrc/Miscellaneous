**FREE
DCL-PROC Procedure;

 DCL-F FILENAME USROPN USAGE(*INPUT) EXTFILE(File) EXTDESC(LIB/FILE) EXTMBR(Member);

 // Define all fields from table(record)
 DCL-DS RecordDS LIKEREC(FILEREC :*ALL) INZ;

 DCL-S File   CHAR(20) INZ;
 DCL-S Member CHAR(10) INZ;
//-------------------------------------------------------------------------

 File   = 'LIB/FILE';
 Member = 'MEMBER1';
 
 If Not %Open(FileName);
   Open FileName;
 EndIf;

 SetLL ('R' :'5') FileRec;
 DoW Not %EoF( FileName );
   ReadE ('R') FileRec RecordDS;
   If %EoF ( FileName );
     Leave;
   EndIf;
   Dsply RecordDS.Field1
 EndDo;
       
 If %Open(FileName);
   Close FileName;
 EndIf;

END-PROC;
