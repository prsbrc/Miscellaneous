     *- Copyright (c) 2017 Christian Brunner
     *-
     *- Permission is hereby granted, free of charge, to any person obtaining a copy
     *- of this software and associated documentation files (the "Software"), to deal
     *- in the Software without restriction, including without limitation the rights
     *- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     *- copies of the Software, and to permit persons to whom the Software is
     *- furnished to do so, subject to the following conditions:
     *-
     *- The above copyright notice and this permission notice shall be included in all
     *- copies or substantial portions of the Software.
     *-
     *- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     *- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     *- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     *- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     *- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     *- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     *- SOFTWARE.

     *  00000000                        BRC      19.09.2017

     H MAIN( Main ) ALWNULL( *USRCTL ) AUT( *EXCLUDE )
     H DATFMT( *ISO- ) TIMFMT( *ISO. ) DECEDIT( '0,' )
     H DFTACTGRP( *NO ) ACTGRP( *NEW ) DEBUG( *YES ) USRPRF( *OWNER )

     * Prototypes
      /INCLUDE *LIBL/QRPGLECPY,SLEEP

     * Program prototype
     D Main            PR                  EXTPGM( 'RLSNSURG' )


     *#########################################################################
     *- MAIN-Procedure
     *#########################################################################

    P Main            B
     D Main            PI

     D LstSvrInf       PR                  EXTPGM( 'QZLSOLST' )
     D  RcvVar                    32767A    OPTIONS( *VARSIZE )
     D  RcvVarLen                    10I 0  CONST
     D  LstInf                       64A
     D  FmtNam                       10A    CONST
     D  InfQual                      15A    CONST
     D  Error                     32767A    OPTIONS( *VARSIZE )
     D  SsnUsr                       10A    CONST OPTIONS( *NOPASS )
     D  SsnId                        20I 0  CONST OPTIONS( *NOPASS )

     D ChgSvrInf       PR                  EXTPGM( 'QZLSCHSI' )
     D  CsRqsVar                  32767A    CONST OPTIONS( *VARSIZE )
     D  CsRqsVarLen                  10I 0  CONST
     D  CsFmtNam                     10A    CONST
     D  CsError                   32767A    OPTIONS( *VARSIZE )

     D RtvJobInf       PR                  EXTPGM( 'QUSRJOBI' )
     D  RcvVar                    32767A    OPTIONS( *VARSIZE )
     D  RcvVarLen                    10I 0  CONST
     D  FmtNam                        8A    CONST
     D  JobNamQ                      26A    CONST
     D  JobIntId                     16A    CONST
     D  Error                     32767A    OPTIONS( *NOPASS :*VARSIZE )

     D SndPgmMsg       PR                  EXTPGM( 'QMHSNDPM' )
     D  MsgId                         7A    CONST
     D  MsgFq                        20A    CONST
     D  MsgDta                      128A    CONST
     D  MsgDtaLen                    10I 0  CONST
     D  MsgTyp                       10A    CONST
     D  CalStkE                      10A    CONST OPTIONS( *VARSIZE )
     D  CalStkCtr                    10I 0  CONST
     D  MsgKey                        4A
     D  Error                     32767A    OPTIONS( *VARSIZE )

      /INCLUDE *LIBL/QRPGLECPY,CONSTANTS

     D Loop            S               N   INZ( TRUE )
     D i               S             10I 0 INZ
     D MsgKey          S              4A   INZ
     D Msg             C                   ' >> Enable Userprofile: '
     D API_ErrorDS     DS                  QUALIFIED
     D  BytesPrv                     10I 0  INZ( %SIZE(API_ErrorDS) )
     D  BytesAvl                     10I 0
     D  MsgID                         7A
     D  Reserved                      1A
     D  MsgDta                      256A

     D ZLSS0200        DS                  QUALIFIED INZ
     D  NbrSvrUsr                    10I 0
     D  NetSvrUsr                    10A    DIM(1)

     D ZLSL0900        DS                  QUALIFIED INZ
     D  DsaNetUsr                    10A    DIM(128)

     D JOBI0400        DS                  QUALIFIED INZ
     D  BytRtn                       10I 0
     D  BytAvl                       10I 0
     D  JobNam                       10A
     D  UsrNam                       10A
     D  JobNbr                        6A
     D  JobIntId                     16A
     D  JobSts                       10A
     D  JobTyp                        1A
     D  JobSubTyp                     1A

     D LstInf          DS                  QUALIFIED INZ
     D  RcdNbrTotal                  10I 0
     D  RcdNbrRtn                    10I 0
     D  RcdLen                       10I 0
     D  InfLenRtn                    10I 0
     D  InfCmp                        1A
     D  Dts                          13A
     D                               34A
     *-------------------------------------------------------------------------

       RtvJobInf(JOBI0400 :%Size(JOBI0400) :'JOBI0400' :'*' :'' :API_ErrorDS);

      DoW ( Loop );
      // Enable disabled userprofiles
         LstSvrInf(ZLSL0900: %Size(ZLSL0900) :LstInf :'ZLSL0900' :''
                   :API_ErrorDS);
        If ( API_ErrorDS.BytesAvl=0 );
          For i=1 To LstInf.RcdNbrTotal;
             ZLSS0200.NbrSvrUsr=1;
             ZLSS0200.NetSvrUsr(1)=ZLSL0900.DsaNetUsr(i);
             ChgSvrInf(ZLSS0200 :%Size(ZLSS0200) :'ZLSS0200' :API_ErrorDS);
             SndPgmMsg('CPF9897' :'QCPFMSG   *LIBL' :Msg+ZLSL0900.DsaNetUsr(i)
                       :%Len(Msg+ZLSL0900.DsaNetUsr(i)) :'*DIAG' :'*PGMBDY' :1
                       :MsgKey :API_ErrorDS);
          EndFor;
        EndIf;

      // if batch than loop else end
        If ( JOBI0400.JobTyp='I' );
           Leave;
        Else;
           Sleep(60);
        EndIf;
      EndDo;

       Return;

    P                 E
