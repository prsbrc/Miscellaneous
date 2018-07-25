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

// Example for an SSL-client
//   Use the socketapi from scott klement - (c) Scott Klement

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) USRPRF(*OWNER) DEBUG(*YES) BNDDIR('SOCKAPI') MAIN(Main);


DCL-PR Main EXTPGM('ZSSLCLRG') END-PR;


/INCLUDE *LIBL/QRPGLECPY,SOCKET_H
/INCLUDE *LIBL/QRPGLECPY,GSKSSL_H
/INCLUDE *LIBL/QRPGLECPY,SOCKAPI_H


DCL-PR Sock_CleanUp END-PR;
DCL-PR Die;
  Messsage CHAR(256) CONST;
END-PR;
DCL-PR ChgCCSID CHAR(1024);
  Stream CHAR(1024) CONST;
  FromCCSID INT(10) CONST;
  ToCCSID INT(10) CONST;
END-PR;

DCL-C TRUE *ON;
DCL-C FALSE *OFF;
DCL-C LOCAL 0;
DCL-C UTF8 1208;

/INCLUDE *LIBL/QRPGLECPY,ERRNO_H
DCL-S Host CHAR(32) INZ('www.liferadio.tirol');
DCL-S GlobalSocket INT(10) INZ;
DCL-S GSKEnvironment POINTER;
DCL-S GSKSID POINTER;


//**************************************************************************
DCL-PROC Main;

DCL-S rc INT(10) INZ;
DCL-S Data CHAR(1024) INZ;
DCL-S ConnectTo POINTER;
DCL-S Address UNS(10) INZ;
DCL-S Port UNS(5) INZ;
DCL-S AddressLength INT(10) INZ;
DCL-S Err INT(10) INZ;
DCL-S GSKLength INT(10) INZ;
//-------------------------------------------------------------------------

 *INLR = TRUE;

 // Search port
 P_ServEnt=GetServByName('https' :'tcp');
 If ( P_ServEnt=*NULL );
   Die('Can''t find the HTTP service!');
   Return;
 EndIf;
 Port = s_Port;

 // Search networkadress for host
 Address = INet_Addr(%Trim(Host));
 If ( Address = INADDR_NONE );
   P_HostEnt = GetHostByName(%Trim(Host));
   If ( P_HostEnt = *NULL );
     Die('Unable to find that host!');
     Return;
   EndIf;
   Address = H_Addr;
 EndIf;

 // Open gsk environment
 rc = GSK_Environment_Open(GSKEnvironment);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_environment_open(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 rc = GSK_Attribute_Set_Buffer(GSKEnvironment :GSK_KEYRING_FILE :'*SYSTEM' :0);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_SESSION_TYPE :GSK_CLIENT_SESSION);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_SERVER_AUTH_TYPE :GSK_SERVER_AUTH_PASSTHRU);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_CLIENT_AUTH_TYPE :GSK_CLIENT_AUTH_PASSTHRU);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_PROTOCOL_SSLV2 :GSK_PROTOCOL_SSLV2_ON);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_PROTOCOL_SSLV3 :GSK_PROTOCOL_SSLV3_ON);

 rc = GSK_Attribute_Set_eNum(GSKEnvironment :GSK_PROTOCOL_TLSV1 :GSK_PROTOCOL_TLSV1_ON );

 // Init gsk environment
 rc = GSK_Environment_Init(GSKEnvironment);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_environment_init(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 // Create socket
 GlobalSocket = Socket(AF_INET :SOCK_STREAM :IPPROTO_IP);
 If ( GlobalSocket < 0 );
   Die('socket(): ' + %Str(StrError(ErrNo)));
   Return;
 EndIf;

 // Create socketstructure
 AddressLength = %Size(SockAddr);
 ConnectTo     = %Alloc(AddressLength);

 P_SockAddr = ConnectTo;
 Sin_Family = AF_INET;
 Sin_Addr   = Address;
 Sin_Port   = Port;
 Sin_Zero   = *ALLx'00';

 // Connect to host
 If ( Connect(GlobalSocket :ConnectTo :AddressLength) < 0 );
   Err = ErrNo;
   Close_Socket(GlobalSocket);
   Die('connect(): ' + %Str(StrError(Err)));
   Return;
 EndIf;

 // Open gsk socket
 rc = GSK_Secure_Soc_Open(GSKEnvironment :GSKSID);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_secure_soc_open(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 // Bind gsk socket to tcp socket
 rc = GSK_Attribute_Set_Numeric_Value(GSKSID :GSK_FD :GlobalSocket);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_attribute_set_numeric_value(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 // Set timeout
 rc = GSK_Attribute_Set_Numeric_Value(GSKSID :GSK_HANDSHAKE_TIMEOUT :10);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_attribute_set_numeric_value(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 // Init gsk socket
 rc = GSK_Secure_Soc_Init(GSKSID);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_secure_soc_init(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 Data = 'GET /webcam/Studio1 HTTP/1.1';
 Data = ChgCCSID(Data :LOCAL :UTF8);
 rc   = GSK_Secure_Soc_Write(GSKSID :%Addr(Data) :%Size(Data) :GSKLength);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   Die('gsk_secure_soc_write(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;

 rc = GSK_Secure_Soc_Read(GSKSID :%Addr(Data) :%Size(Data) :GSKLength);
 If ( rc<>GSK_OK );
   Sock_CleanUp();
   Die('gsk_secure_soc_read(): ' + %Str(GSK_StrError(rc)));
   Return;
 EndIf;
 Data = ChgCCSID(Data :UTF8 :LOCAL);

 // Close gsk and sockets
 Sock_CleanUp();
 Return;

END-PROC;


//**************************************************************************
DCL-PROC Sock_CleanUp;

 GSK_Secure_Soc_Close(GSKSID);
 GSK_Environment_Close(GSKEnvironment);
 Close_Socket(GlobalSocket);

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

 DCL-DS ErrorDS QUALIFIED;
   NbrBytesPrv INT(10) INZ(%SIZE(ErrorDS));
   NbrBytesAvl INT(10);
   MsgID CHAR(7);
   Reserved1 CHAR(1);
   MsgData CHAR(512);
 END-DS;

 DCL-S MsgLength INT(10) INZ;
 DCL-S MessageKey CHAR(4) INZ;
//-------------------------------------------------------------------------

 MsgLength = %Len(%TrimR(pMessage));
 If ( MsgLength < 1 );
   Return;
 EndIf;

 SndPgmMsg('CPF9897' :'QCPFMSG   *LIBL' :pMessage: MsgLength :'*ESCAPE'
           :'*PGMBDY' :1 :MessageKey :ErrorDS);

 Return;

END-PROC;

//**************************************************************************
DCL-PROC ChgCCSID;
 DCL-PI ChgCCSID CHAR(1024);
   pStream CHAR(1024) CONST;
   pFromCCSID INT(10) CONST;
   pToCCSID INT(10) CONST;
 END-PI;

 DCL-PR iConv_Open LIKEDS(ToASCII) EXTPROC('QtqIconvOpen');
   ToCode LIKEDS(dsFrom);
   FromCode LIKEDS(dsTo);
 END-PR;

 DCL-PR iConv UNS(10) EXTPROC('iconv');
   Descriptor LIKE(ToASCII) VALUE;
   InBuff POINTER;
   InLeft UNS(10);
   OutBuff POINTER;
   OutLeft UNS(10);
 END-PR;

 DCL-PR iConv_Close INT(10) EXTPROC('iconv_close');
   CD LIKEDS(ToASCII) VALUE;
 END-PR;

 DCL-S ConvHandler POINTER;
 DCL-S Length UNS(10) INZ;
 DCL-S Result CHAR(1024) INZ;

 DCL-DS ToASCII;
   ICORV_A INT(10);
   ICOC_A  INT(10) DIM( 12 );
 END-DS;

 DCL-DS dsFROM QUALIFIED;
   From_CCSID INT(10);
   From_CA INT(10) INZ;
   From_SA INT(10) INZ;
   From_SS INT(10) INZ;
   From_IL INT(10) INZ;
   From_EO INT(10) INZ;
   From_R  CHAR(8) INZ(*ALLX'00');
 END-DS;

 DCL-DS dsTO QUALIFIED;
   To_CCSID INT(10);
   To_CA INT(10) INZ;
   To_SA INT(10) INZ;
   To_SS INT(10) INZ;
   To_IL INT(10) INZ;
   To_EO INT(10) INZ;
   To_R  CHAR(8) INZ(*ALLX'00');
 END-DS;
//-------------------------------------------------------------------------

 Result      = %Trim(pStream);
 ConvHandler = %Addr(Result);
 Length      = %Len(%TrimR(Result));
 dsFrom.From_CCSID = pFromCCSID;
 dsTo.To_CCSID     = pToCCSID;

 ToASCII = iConv_Open(dsTo :dsFrom);
 If ( ICORV_A >= 0 );
   iConv(ToASCII :ConvHandler :Length :ConvHandler :Length );
 EndIf;
 iConv_Close(ToASCII);
 Return Result;

END-PROC;

/DEFINE ERRNO_LOAD_PROCEDURE
/INCLUDE *LIBL/QRPGLECPY,ERRNO_H