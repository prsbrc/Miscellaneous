**FREE

// 00000000 BRC 15.11.2018

// This is a example to show how an tls client can be on the IBMi
//   Using IBM's GSK and based on the socketapi from Scott Klement - (c) Scott Klement


CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) USRPRF(*OWNER) DEBUG(*YES) MAIN(Main);


DCL-PR Main EXTPGM('ZTLSCLRG') END-PR;


/INCLUDE QRPGLECPY,SOCKET_H
/INCLUDE QRPGLECPY,GSKSSL_H


DCL-PR Sock_CleanUp END-PR;
DCL-PR SendDie;
  Messsage CHAR(256) CONST;
END-PR;
DCL-PR ChangeCCSID EXTPGM('QDCXLATE');
  Length PACKED(5 :0) CONST;
  Buffer CHAR(32766) OPTIONS(*VARSIZE);
  Table CHAR(10) CONST;
END-PR;

DCL-C TRUE *ON;
DCL-C FALSE *OFF;
DCL-C CRLF x'0D25';

/INCLUDE QRPGLECPY,ERRNO_H

DCL-DS This QUALIFIED;
  Host CHAR(128) INZ('www.github.com');
  GlobalSocket INT(10) INZ;
  GSKEnvironment POINTER;
  GSKSID POINTER;
END-DS;


//**************************************************************************
DCL-PROC Main;

DCL-S RC INT(10) INZ;
DCL-S Data CHAR(1024) INZ;
DCL-S ConnectTo POINTER;
DCL-S Address UNS(10) INZ;
DCL-S Port UNS(5) INZ;
DCL-S AddressLength INT(10) INZ;
DCL-S Err INT(10) INZ;
DCL-S GSKLength INT(10) INZ;
//-------------------------------------------------------------------------

 *INLR = TRUE;
 Reset This;

 // Search port
 P_ServEnt = GetServByName('https' :'tcp');
 If ( P_ServEnt = *NULL );
   SendDie('Can''t find the selected service');
   Return;
 EndIf;
 Port = s_Port;

 // Search networkadress for host
 Address = INet_Addr(%Trim(This.Host));
 If ( Address = INADDR_NONE );
   P_HostEnt = GetHostByName(%TrimR(This.Host));
   If ( P_HostEnt = *NULL );
     SendDie('Unable to find your selected host');
     Return;
   EndIf;
   Address = H_Addr;
 EndIf;

 // Open GSK environment
 RC = GSK_Environment_Open(This.GSKEnvironment);
 If ( RC <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_environment_open(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 // Set keystore to *SYSTEM
 GSK_Attribute_Set_Buffer(This.GSKEnvironment :GSK_KEYRING_FILE :'*SYSTEM' :0);

 // Tell GSK that we are a client
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_SESSION_TYPE :GSK_CLIENT_SESSION);

 // Tell GSK to accept every certificate
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_SERVER_AUTH_TYPE :GSK_SERVER_AUTH_PASSTHRU);
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_CLIENT_AUTH_TYPE :GSK_CLIENT_AUTH_PASSTHRU);

 // Set protocols on or off
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_PROTOCOL_SSLV2 :GSK_PROTOCOL_SSLV2_ON);
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_PROTOCOL_SSLV3 :GSK_PROTOCOL_SSLV3_ON);
 GSK_Attribute_Set_eNum(This.GSKEnvironment :GSK_PROTOCOL_TLSV1 :GSK_PROTOCOL_TLSV1_ON );

 // Init GSK environment
 RC = GSK_Environment_Init(This.GSKEnvironment);
 If ( RC <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_environment_init(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 // Create socket
 This.GlobalSocket = Socket(AF_INET :SOCK_STREAM :IPPROTO_IP);
 If ( This.GlobalSocket < 0 );
   SendDie('socket(): ' + %Str(StrError(ErrNo)));
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
 If ( Connect(This.GlobalSocket :ConnectTo :AddressLength) < 0 );
   Err = ErrNo;
   Close_Socket(This.GlobalSocket);
   SendDie('connect(): ' + %Str(StrError(Err)));
   Return;
 EndIf;

 // Open GSK socket
 RC = GSK_Secure_Soc_Open(This.GSKEnvironment :This.GSKSID);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_secure_soc_open(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 // Bind GSK to tcp socket
 RC = GSK_Attribute_Set_Numeric_Value(This.GSKSID :GSK_FD :This.GlobalSocket);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_attribute_set_numeric_value(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 // Set timeout
 RC = GSK_Attribute_Set_Numeric_Value(This.GSKSID :GSK_HANDSHAKE_TIMEOUT :10);
 If ( RC <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_attribute_set_numeric_value(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 // Init GSK socket
 RC = GSK_Secure_Soc_Init(This.GSKSID);
 If ( rc <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_secure_soc_init(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 Data = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
 ChangeCCSID(%Len(%TrimR(Data)) :Data :'QTCPASC');
 RC = GSK_Secure_Soc_Write(This.GSKSID :%Addr(Data) :%Size(Data) :GSKLength);
 If ( RC <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_secure_soc_write(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;

 RC = GSK_Secure_Soc_Read(This.GSKSID :%Addr(Data) :%Size(Data) :GSKLength);
 If ( RC <> GSK_OK );
   Sock_CleanUp();
   SendDie('gsk_secure_soc_read(): ' + %Str(GSK_StrError(RC)));
   Return;
 EndIf;
 ChangeCCSID(%Len(%TrimR(Data)) :Data :'QTCPEBC');

 // To something like follow redirections etc

 // Close GSK and sockets
 Sock_CleanUp();
 Return;

END-PROC;


//**************************************************************************
DCL-PROC Sock_CleanUp;

 GSK_Secure_Soc_Close(This.GSKSID);
 GSK_Environment_Close(This.GSKEnvironment);
 Close_Socket(This.GlobalSocket);

END-PROC;

//**************************************************************************
DCL-PROC SendDie;
 DCL-PI SendDie;
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

END-PROC;

/DEFINE ERRNO_LOAD_PROCEDURE
/INCLUDE QRPGLECPY,ERRNO_H
