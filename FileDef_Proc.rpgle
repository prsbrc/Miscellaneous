    P PROC            B
    D PROC            PI

     FFILE      IF   E           K DISK    USROPN

     D dsFile          DS                  LIKEREC( FILE_REC )
     *-------------------------------------------------------------------------

       Open FILE;
       SetLL ('R' :'5') FILE;
       DoW Not %EoF( FILE );
         ReadE ('R' :'5') FILE_REC dsFile;
         If %EoF ( FILE );
           Leave;
         EndIf;
         Dsply dsFile.Field1
       EndDo;
       Close FILE;

    P                 E
