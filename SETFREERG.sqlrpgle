     H DFTACTGRP(*NO) ACTGRP(*NEW) USRPRF(*USER) DEBUG(*NO) BNDDIR('QC2LE')
     H MAIN( Main ) DATFMT( *ISO- ) TIMFMT( *ISO. ) AUT( *EXCLUDE )

     * program prototype
     D Main            PR                  EXTPGM( 'SETFREERG' )
     D  QualFile                            CONST LIKEDS( Parm_Struct )
     D  Member                       10A    CONST

     * imported prototypes
      /INCLUDE QRPGLECPY,SYSTEM

     * constants
      /INCLUDE QRPGLECPY,CONSTANTS
      /INCLUDE QRPGLECPY,SQLDEF

     * global variables
     D Parm_Struct     DS                  QUALIFIED
     D  File                         10A    INZ
     D  Library                      10A    INZ


     ** Main ******************************************************************
     *- MAIN-Procedure
     *-
     *- Input:    Qualified Name, Member
     **************************************************************************
    P Main            B
     D Main            PI
     D  QualFile                           CONST LIKEDS( Parm_Struct )
     D  Member                       10A   CONST

     D Source          DS                  QUALIFIED
     D  Hex                    1      1A
     D  Data                   1    100A
     D Data            S            100A
     *-------------------------------------------------------------------------

      If %Parms()<2;
         Return;
      EndIf;

       Exec SQL SET OPTION DATFMT=*ISO, DATSEP='-', TIMFMT=*ISO, TIMSEP='.',
                            CLOSQLCSR=*ENDMOD, USRPRF=*USER, DYNUSRPRF=*USER,
                            COMMIT=*NONE;

      // OVR to member
       System('OVRDBF FILE(QRPGLETMP) TOFILE('+%Trim(QualFile.Library)+'/'+
              %Trim(QualFile.File)+') MBR('+%Trim(Member)+')');

       Exec SQL DECLARE C0 SCROLL CURSOR FOR
                 SELECT SRCDTA FROM QRPGLETMP
                  ORDER BY SRCSEQ FOR UPDATE OF SRCDTA WITH NC;
       Exec SQL OPEN C0;

      DoW ( Loop );
         Exec SQL FETCH NEXT FROM C0 INTO :Source.Data;
        If ( SQLCode<>stsOK );
           Exec SQL CLOSE C0;
           Leave;
        EndIf;
         Exec SQL SET :Data=UPPER(:Data);
        Select;
          When ( %SubSt(Source.Data:6:4)=' *##' );
             Source.Hex=X'3A';
          When ( %SubSt(Source.Data:6:4)=' ***' );
             Source.Hex=X'3A';
          When ( %SubSt(Source.Data:6:4)=' *--' );
             Source.Hex=X'3A';
          When ( %SubSt(Source.Data:6:4)=' *- ' );
             Source.Hex=X'22';
          When ( %SubSt(Source.Data:6:4)=' *+ ' );
             Source.Hex=X'28';
          When ( %SubSt(Source.Data:6:3)=' * ' );
             Source.Hex=X'3A';
          When ( %SubSt(Source.Data:6:2)='P ' ) And
               ( %SubSt(Source.Data:24:6)='B     ' );
             Source.Hex=X'38';
          When ( %SubSt(Source.Data:6:2)='P ' ) And
               ( %SubSt(Source.Data:24:6)='E     ' );
             Source.Hex=X'38';
          When ( %Scan('  IF ':Data)>0 And %SubSt(Data:6:1)='' ) Or
               ( %Scan('  DO':Data)>0 ) Or
               ( %Scan('  FOR ':Data)>0 ) Or
               ( %Scan('  ELSE;':Data)>0 ) Or
               ( %Scan('  SELECT;':Data)>0 ) Or
               ( %Scan('  MONITOR;':Data)>0 ) Or
               ( %Scan('  WHEN ':Data)>0 ) Or
               ( %Scan('  OTHER;':Data)>0 ) Or
               ( %Scan('  ON-ERROR;':Data)>0 ) Or
               ( %Scan('  ENDIF;':Data)>0 ) Or
               ( %Scan('  ENDDO;':Data)>0 ) Or
               ( %Scan('  ENDFOR;':Data)>0 ) Or
               ( %Scan('  ENDMON;':Data)>0 ) Or
               ( %Scan('  ENDSL;':Data)>0 );
             Source.Hex=X'22';
          When ( %Scan(' // ':Data)>0 );
             Source.Hex=X'3A';
        EndSl;
         Exec SQL UPDATE QRPGLETMP SET SRCDTA=:Source.Data
                   WHERE CURRENT OF C0;
      EndDo;

       System('DLTOVR FILE(QRPGLETMP)');

       Return;

    P                 E
