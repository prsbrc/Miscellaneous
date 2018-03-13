**FREE
DCL-PROC Procedure;

 DCL-F FILENAME USROPN USAGE(*INPUT) EXTDESC(FILENAME) EXTMBR(Member);

 DCL-DS RecordDS LIKEREC(FILEREC :*ALL) INZ;
 DCL-S Member CHAR(10) INZ;
//-------------------------------------------------------------------------

 Member = 'Member1';
 
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
