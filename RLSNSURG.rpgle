**FREE
//- Copyright (c) 2017 Christian Brunner

//- Permission is hereby granted, free of charge, to any person obtaining a copy
//- of this software and associated documentation files (the "Software"), to deal
//- in the Software without restriction, including without limitation the rights
//- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//- copies of the Software, and to permit persons to whom the Software is
//- furnished to do so, subject to the following conditions:

//- The above copyright notice and this permission notice shall be included in all
//- copies or substantial portions of the Software.

//- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//- SOFTWARE.

CTL-OPT MAIN( Main ) ALWNULL( *USRCTL ) AUT( *EXCLUDE )
        DATFMT( *ISO- ) TIMFMT( *ISO. ) DECEDIT( '0,' )
        DFTACTGRP( *NO ) ACTGRP( *NEW ) DEBUG( *YES ) USRPRF( *OWNER );


// Program prototype
DCL-PR Main EXTPGM( 'RLSNSURG' ) END-PR;


// Prototypes
/INCLUDE *LIBL/QRPGLECPY,SLEEP



//#########################################################################
//- MAIN-Procedure
//#########################################################################

DCL-PROC Main;

DCL-PR LstSvrInf EXTPGM( 'QZLSOLST' );
 RcvVar CHAR(32767) OPTIONS( *VARSIZE );
 RcvVarLen INT(10) CONST;
 LstInf CHAR(64);
 FmtNam CHAR(10) CONST;
 InfQual CHAR(15) CONST;
 Error CHAR(32767) OPTIONS( *VARSIZE );
 SsnUsr CHAR(10) CONST OPTIONS( *NOPASS );
 SsnId INT(20) CONST OPTIONS( *NOPASS );
END-PR;

DCL-PR ChgSvrInf EXTPGM( 'QZLSCHSI' );
 CsRqsVar CHAR(32767) CONST OPTIONS( *VARSIZE );
 CsRqsVarLen INT(10) CONST;
 CsFmtNam  CHAR(10) CONST;
 CsError CHAR(32767) OPTIONS( *VARSIZE );
END-PR;

DCL-PR RtvJobInf EXTPGM( 'QUSRJOBI' );
 RcvVar CHAR(32767) OPTIONS( *VARSIZE );
 RcvVarLen INT(10) CONST;
 FmtNam CHAR(8) CONST;
 JobNamQ CHAR(26) CONST;
 JobIntId CHAR(16) CONST;
 Error CHAR(32767) OPTIONS( *NOPASS :*VARSIZE );
END-PR;

DCL-PR SndPgmMsg EXTPGM( 'QMHSNDPM' );
 MsgId CHAR(7) CONST;
 MsgFile CHAR(20) CONST;
 MsgDta CHAR(128) CONST;
 MsgDtaLen INT(10) CONST;
 MsgTyp CHAR(10) CONST;
 CallStkE CHAR(10) CONST OPTIONS( *VARSIZE );
 CallStkCtr INT(10) CONST;
 MsgKey CHAR(4);
 Error CHAR(32767) OPTIONS( *VARSIZE );
END-PR;

/INCLUDE *LIBL/QRPGLECPY,CONSTANTS
DCL-C Msg ' >> Enable Userprofile: ';

DCL-S Loop IND INZ( TRUE );
DCL-S i INT(10) INZ;
DCL-S MsgKey CHAR(4) INZ;

DCL-DS API_ErrorDS QUALIFIED INZ;
 BytesPrv INT(10) INZ( %SIZE(API_ErrorDS) );
 BytesAvail INT(10);
 MsgID CHAR(7);
 Reserved CHAR(1);
 MsgDta CHAR(256);
END-DS;

DCL-DS ZLSS0200  QUALIFIED INZ;
 NbrSvrUser INT(10);
 NetSvrUser CHAR(10) DIM(1);
END-DS;

DCL-DS ZLSL0900 QUALIFIED INZ;
 DsaNetUser CHAR(10) DIM(128);
END-DS;

DCL-DS JOBI0400 QUALIFIED INZ;
 BytReturn INT(10);
 BytAvail INT(10);
 JobName CHAR(10);
 UserName CHAR(10);
 JobNumber CHAR(6);
 JobIntID CHAR(16);
 JobSts CHAR(10);
 JobTyp CHAR(1);
 JobSubTyp CHAR(1);
END-DS;

DCL-DS LstInf QUALIFIED INZ;
 RcdNbrTotal INT(10);
 RcdNbrRtn INT(10);
 RcdLen INT(10);
 InfLenRtn INT(10);
 InfCmp CHAR(1);
 Dts CHAR(13);
 Filler CHAR(34);
END-DS;
//-------------------------------------------------------------------------

  RtvJobInf(JOBI0400 :%Size(JOBI0400) :'JOBI0400' :'*' :'' :API_ErrorDS);

  DoW ( Loop );
  // Enable disabled userprofiles
    LstSvrInf(ZLSL0900: %Size(ZLSL0900) :LstInf :'ZLSL0900' :'' :API_ErrorDS);
    If ( API_ErrorDS.BytesAvail=0 );
      For i=1 To LstInf.RcdNbrTotal;
        ZLSS0200.NbrSvrUser = 1;
        ZLSS0200.NetSvrUser(1)=ZLSL0900.DsaNetUser(i);
        ChgSvrInf(ZLSS0200 :%Size(ZLSS0200) :'ZLSS0200' :API_ErrorDS);
        SndPgmMsg('CPF9897' :'QCPFMSG   *LIBL' :Msg+ZLSL0900.DsaNetUser(i)
                  :%Len(Msg+ZLSL0900.DsaNetUser(i)) :'*DIAG' :'*PGMBDY' :1
                  :MsgKey :API_ErrorDS);
      EndFor;
    EndIf;

    // if batch than loop else end
    If ( JOBI0400.JobTyp='I' );
      Leave;
    Else;
      Sleep(60);
    EndIf;
  EndDo;

  Return;

END-PROC;
