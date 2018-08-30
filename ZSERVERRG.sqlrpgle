**FREE
//- Copyright (c) 2018 Christian Brunner
//-
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

// 00000000 BRC 25.07.2018

// Socketserver to recieve objects from another IBMi
//   Use the socketapi from scott klement - (c) Scott Klement


CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) USRPRF(*OWNER) DEBUG(*YES)
        BNDDIR('SOCKAPI') MAIN(Main);


DCL-PR Main EXTPGM('ZSERVERRG') END-PR;

/INCLUDE QRPGLECPY,SOCKET_H
/INCLUDE QRPGLECPY,SOCKAPI_H
DCL-PR System INT(10) EXTPROC('system');
  *N POINTER VALUE OPTIONS(*STRING);
END-PR;
DCL-PR Sleep INT(10) EXTPROC('sleep');
  *N INT(10) VALUE;
END-PR;


DCL-PR ChkShutDown END-PR;
DCL-PR MakeListener END-PR;
DCL-PR AcceptConn END-PR;
DCL-PR TalkToClient END-PR;
DCL-PR RtvCurUsr CHAR(10) END-PR;
DCL-PR CleanTemp END-PR;
DCL-PR Die;
  Message CHAR(256) CONST;
END-PR;


DCL-C P_SAVE '/QSYS.LIB/QTEMP.LIB/RCV.FILE';
DCL-C P_FILE '/tmp/rcv.file';
DCL-C TRUE *ON;
DCL-C FALSE *OFF;


/INCLUDE *LIBL/QRPGLECPY,ERRNO_H

DCL-S Loop IND INZ(TRUE);
DCL-S Length INT(10) INZ;
DCL-S BindTo POINTER;
DCL-S ConnFrom POINTER;
DCL-S Port UNS(5) INZ(19335);
DCL-S LSock INT(10) INZ;
DCL-S CSock INT(10) INZ;
DCL-S ErrNumber INT(10) INZ;
DCL-S ClientIP CHAR(17) INZ;

DCL-DS ErrorDS_Template QUALIFIED TEMPLATE;
  NbrBytesPrv INT(10) INZ(%SIZE(ErrorDS_Template));
  NbrBytesAvl INT(10);
  MsgID CHAR(7);
  Reserved1 CHAR(1);
  MsgData CHAR(512);
END-DS;


//#########################################################################
DCL-PROC Main;

 *INLR = TRUE;

 MakeListener();
 ChkShutDown();

 DoW ( Loop );

   AcceptConn();

   Monitor;
     TalkToClient();
     On-Error;
   EndMon;

   CleanTemp();
   Close_Socket(CSock);

 EndDo;

END-PROC;

//**************************************************************************
DCL-PROC ChkShutDown;

 If ( %ShtDn() );
   Loop = FALSE;
   Close_Socket(CSock);
 EndIf;

END-PROC;

//**************************************************************************
DCL-PROC MakeListener;

 // Allocate space for socket addresses
 Length   = %Size(SockAddr_In);
 BindTo   = %Alloc(Length);
 ConnFrom = %Alloc(Length);

 // Make a new socket
 LSock = Socket(AF_INET :SOCK_STREAM :IPPROTO_IP);
 If ( LSock < 0 );
   Die('socket():' + %Str(StrError(ErrNo)));
   Return;
 EndIf;

 // bind the socket to port, of any IP address
 p_SockAddr = BindTo;
 Sin_Family = AF_INET;
 Sin_Addr   = INADDR_ANY;
 Sin_Port   = Port;
 Sin_Zero   = *ALLx'00';

 If ( Bind(LSock :BindTo :Length) < 0 );
   ErrNumber = ErrNo;
   Close_Socket(LSock);
   Die('bind():' + %Str(StrError(ErrNumber)));
   Return;
 EndIf;

 // Indicate that we want to listen for connections
 If ( Listen(LSock :5) < 0 );
   ErrNumber = ErrNo;
   Close_Socket(LSock);
   Die('listen():' + %Str(StrError(ErrNumber)));
   Return;
 EndIf;

END-PROC;

//**************************************************************************
DCL-PROC AcceptConn;

 DoU ( Length = %Size(SockAddr_In) );

   // Accept the next connection.
   Length = %Size(SockAddr_In);
   CSock  = Accept(LSock :ConnFrom :Length);
   If ( CSock < 0 );
     ErrNumber = ErrNo;
     Close_Socket(LSock);
     Die('accept():' + %Str(StrError(ErrNumber)));
     Return;
   EndIf;

   If ( Length <> %Size(SockAddr_In));
     Close_Socket(CSock);
   EndIf;

 EndDo;

 P_SockAddr = ConnFrom;
 ClientIP   = %Str(INet_NTOA(Sin_Addr));

END-PROC;

//**************************************************************************
DCL-PROC TalkToClient;

 DCL-PR IFS_Open INT(10) EXTPROC('open');
   Filename  POINTER VALUE OPTIONS(*STRING);
   Openflags INT(10) VALUE;
   Mode      UNS(10) VALUE OPTIONS(*NOPASS);
   Codepage  UNS(10) VALUE OPTIONS(*NOPASS);
 END-PR;

 DCL-PR IFS_Write INT(10) EXTPROC('write');
   Handle INT(10) VALUE;
   Buffer POINTER VALUE;
   Bytes  UNS(10) VALUE;
 END-PR;

 DCL-PR IFS_Close INT(10) EXTPROC('close');
   Handle INT(10)  VALUE;
 END-PR;

 DCL-PR EC#QSYGETPH EXTPGM('QSYGETPH');
   User     CHAR(10) CONST;
   Password CHAR(10) CONST;
   pHandler CHAR(12);
   Error    CHAR(32766) OPTIONS(*VARSIZE :*NOPASS);
   Length   INT(10) CONST OPTIONS(*NOPASS);
   pCCSID   INT(10) CONST OPTIONS(*NOPASS);
 END-PR;

 DCL-PR EC#QWTSETP EXTPGM('QWTSETP');
   pHandler CHAR(12);
   Error CHAR(32766) OPTIONS(*VARSIZE);
 END-PR;

 DCL-PR EC#ZSERVER EXTPGM('ZSERVERCL');
   Save CHAR(64) CONST;
   File CHAR(64) CONST;
 END-PR;


DCL-S KEY CHAR(10) INZ('6wO1w3CjCc');


DCl-C O_WRONLY 2;
DCL-C O_CREAT 8;
DCL-C O_TRUNC 64;
DCL-C O_TEXTDATA 16777216;
DCL-C O_CODEPAGE 8388608;
DCL-C O_LARGEFILE 536870912;
DCL-C S_IRWXU 448;
DCL-C S_IRWXG 56;
DCL-C S_IRWXO 7;


DCL-S fd INT(10) INZ;
DCL-S rc INT(10) INZ;
DCL-S sr INT(10) INZ;
DCL-S Data CHAR(1024) INZ;
DCL-S Work CHAR(1024) INZ;
DCL-S Restore CHAR(1024) INZ;
DCL-S File CHAR(32766) INZ;
DCL-S User CHAR(10) INZ;
DCL-S Password CHAR(10) INZ;
DCL-S aH CHAR(12) INZ;
DCL-S OldUser CHAR(10) INZ;
DCL-S lLength INT(10) INZ(10);
DCL-S iCCSID INT(10) INZ(37);

DCL-DS ErrorDS LIKEDS(ErrorDS_Template);
//-------------------------------------------------------------------------

 // User and password recieve and check / change to called user
 sr = Recv(CSock :%Addr(Data) :%Size(Data) :0);
 If ( sr <= 0 ) Or ( Data = '' );
   Data = '*NOLOGINDATA>';
   Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);
   Return;
 EndIf;

 User = %SubSt(Data :1 :10);
 Work = %SubSt(Data :11 :1000);
 Exec SQL Set :Password = DECRYPT_BIT(BINARY(:Work), :KEY);
 If ( SQLCode <> 0 );
   Data = '*NOPWD>' + %Char(SQLCode);
   Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);
   Return;
 EndIf;

 OldUser = RtvCurUsr();
 EC#QSYGETPH(User :Password :aH :ErrorDS :lLength :iCCSID);
 If ( ErrorDS.NbrBytesAvl > 0 );
   Data = '*NOACCESS>' + ErrorDS.MsgID;
   Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);
   Return;
 EndIf;

 EC#QWTSETP(aH :ErrorDS);
 If ( ErrorDS.NbrBytesAvl > 0 );
   Data = '*NOACCESS>' + ErrorDS.MsgID;
   Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);
   Return;
 EndIf;

 // Login completed
 Data = '*OK>';
 Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);

 // handle incomming file- and restore informations
 sr = Recv(CSock :%Addr(Restore) :%Size(Restore) :0);

 // handle incomming data
 fd = IFS_Open(P_FILE :O_WRONLY + O_TRUNC + O_CREAT + O_CODEPAGE + O_LARGEFILE
               :S_IRWXU + S_IRWXG + S_IRWXO :1141);

 DoW ( Loop ) And ( fd >= 0 );
   sr = Recv(CSock :%Addr(File) :%Size(File) :0);
   If ( sr <= 0 ) Or ( File = '*EOF>' );
     IFS_Close(fd);
     Leave;
   EndIf;
   rc = IFS_Write(fd :%Addr(File) :sr);
   Clear File;
 EndDo;

 Monitor;
   Data = '*OK>';
   EC#ZSERVER(P_SAVE :P_FILE);
   On-Error;
     Data = '*ERROR_RESTORE>';
 EndMon;
 If ( System(Restore) <> 0 );
   Data = '*ERROR_RESTORE> ' + %Str(StrError(ErrNo));
 EndIf;
 Send(CSock :%Addr(Data) :%Len(%Trim(Data)) :0);

 EC#QSYGETPH(OldUser :'*NOPWD' :aH :ErrorDS);
 EC#QWTSETP(aH :ErrorDS);

 Return;

END-PROC;

//**************************************************************************
DCL-PROC RtvCurUsr;
 DCL-PI RtvCurUsr CHAR(10) END-PI;

 DCL-PR RtvJobInf EXTPGM('QUSRJOBI');
   RcvVar     CHAR(32767) OPTIONS(*VARSIZE);
   RcvVarLen  INT(10)  CONST;
   FormatName CHAR(8)  CONST;
   JobNamQ    CHAR(26) CONST;
   JobIntId   CHAR(16) CONST;
   Error      CHAR(32767) OPTIONS(*NOPASS :*VARSIZE);
 END-PR;

 DCL-DS ErrorDS LIKEDS(ErrorDS_Template);

 DCL-DS JOBI0400 QUALIFIED INZ;
   BytRtn INT(10);
   BytAvl INT(10);
   JobNam CHAR(10);
   UsrNam CHAR(10);
   JobNbr CHAR(6);
   JobIntId CHAR(16);
   JobSts CHAR(10);
   JobTyp CHAR(1);
   JobSubTyp CHAR(1);
 END-DS;
//-------------------------------------------------------------------------

 RtvJobInf(JOBI0400 :%Size(JOBI0400) :'JOBI0400' :'*' :'' :ErrorDS);
 Return JOBI0400.UsrNam;

END-PROC;

//**************************************************************************
DCL-PROC CleanTemp;

 DCL-PR IFS_Unlink INT(10) EXTPROC('unlink');
   Path POINTER VALUE OPTIONS(*STRING);
 END-PR;
//-------------------------------------------------------------------------

 IFS_Unlink(P_FILE);
 System('DLTF FILE(QTEMP/RCV)');

END-PROC;

//**************************************************************************
DCL-PROC Die;
 DCL-PI Die;
   pMessage CHAR(256) CONST;
 END-PI;

 DCL-PR SndPgmMsg EXTPGM('QMHSNDPM');
   MessageID CHAR(7) CONST;
   MessageFile CHAR(20) CONST;
   MessageData CHAR(256) CONST;
   MessageDataLength INT(10) CONST;
   MessageType CHAR(10) CONST;
   CallStkEntry CHAR(10) CONST;
   CallStkCounter INT(10) CONST;
   MessageKey CHAR(4);
   Error CHAR(32766) OPTIONS(*NOPASS :*VARSIZE);
 END-PR;

 DCL-DS ErrorDS LIKEDS(ErrorDS_Template);

 DCL-S MsgLength INT(10) INZ;
 DCL-S MessageKey CHAR(4) INZ;
//-------------------------------------------------------------------------

 MsgLength = %Len(%TrimR(pMessage));
 If ( MsgLength < 1 );
   Return;
 EndIf;

 SndPgmMsg('CPF9897' :'QCPFMSG   *LIBL' :pMessage: MsgLength 
           :'*ESCAPE' :'*PGMBDY' :1 :MessageKey :ErrorDS);

 Return;

END-PROC;


//#########################################################################
/DEFINE ERRNO_LOAD_PROCEDURE
/INCLUDE QRPGLECPY,ERRNO_H
