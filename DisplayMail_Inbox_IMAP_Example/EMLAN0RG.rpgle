**FREE
//- Copyright (c) 2019 Christian Brunner
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

// 00000000 BRC 08.08.2019


/INCLUDE QRPGLECPY,CPY2019
/INCLUDE QRPGLECPY,H_SPECS


DCL-F EMLAN0DF WORKSTN INDDS(WSDS) MAXDEV(*FILE) EXTFILE('EMLAN0DF') ALIAS
               SFILE(EMLAN0AS :RECNUM) USROPN;


/INCLUDE QRPGLECPY,PSDS
DCL-DS WSDS QUALIFIED;
 Exit IND POS(3);
 Refresh IND POS(5);
 CommandLine IND POS(9);
 Cancel IND POS(12);
 SubfileClear IND POS(20);
 SubfileDisplayControl IND POS(21);
 SubfileDisplay IND POS(22);
 SubfileMore IND POS(23);
END-DS;


DCL-PR Main EXTPGM('EMLAN0RG');
 Host CHAR(16) CONST;
 User CHAR(32) CONST;
 Password CHAR(32) CONST;
 Seconds PACKED(2 :0) CONST;
END-PR;


/INCLUDE QRPGLECPY,SOCKET_H
/INCLUDE QRPGLECPY,ERRNO_H
/INCLUDE QRPGLECPY,SYSTEM
/INCLUDE QRPGLECPY,F09


/INCLUDE QRPGLECPY,BOOLIC
/INCLUDE QRPGLECPY,HEX_COLORS
DCL-C FM_A 'A';
DCL-C FM_END '*';
DCL-C DEFAULT_PORT 143;
DCL-C MAX_ROWS_TO_FETCH 60;
DCL-C LOCAL 0;
DCL-C UTF8 1208;
DCL-C CRLF X'0D25';


DCL-S RecNum UNS(10) INZ;
DCL-DS This QUALIFIED;
 PictureControl CHAR(1) INZ(FM_A);
 RefreshSeconds PACKED(2 :0) INZ;
 GlobalMessage CHAR(130) INZ;
 RecordsFound UNS(10) INZ;
 Connected IND INZ(FALSE);
 LoginDataDS LIKEDS(LogInDataDS_T) INZ;
 SocketDS LIKEDS(SocketDS_T) INZ;
END-DS;

DCL-DS LogInDataDS_T QUALIFIED TEMPLATE;
 Host CHAR(16);
 User CHAR(32);
 Password CHAR(32);
END-DS;
DCL-DS SocketDS_T QUALIFIED TEMPLATE;
 ConnectTo POINTER;
 SocketHandler INT(10);
 Address UNS(10);
 AddressLength INT(10);
END-DS;
DCL-DS MailDS_T QUALIFIED TEMPLATE;
 Sender CHAR(128);
 SendDate CHAR(25);
 Subject CHAR(1024);
 UnseenFlag IND;
END-DS;


//#########################################################################
// Main-Loop
//#########################################################################
DCL-PROC Main;
 DCL-PI *N;
  pHost CHAR(16) CONST;
  pUser CHAR(32) CONST;
  pPassword CHAR(32) CONST;
  pSeconds PACKED(2 :0) CONST;
 END-PI;
 //------------------------------------------------------------------------

 Reset This;

 system('CRTDTAQ DTAQ(QTEMP/EMLAN0) MAXLEN(80)');
 system('OVRDSPF FILE(EMLAN0DF) OVRSCOPE(*ACTGRPDFN) DTAQ(QTEMP/EMLAN0)');

 If Not %Open(EMLAN0DF);
   Open EMLAN0DF;
 EndIf;

 DoU ( This.PictureControl = FM_END );
   Select;
     When ( This.PictureControl = FM_A );
       loopFM_A(pHost :pUser :pPassword :pSeconds);
     Other;
       This.PictureControl = FM_END;
   EndSl;
 EndDo;

 If %Open(EMLAN0DF);
   Close EMLAN0DF;
 EndIf;

 system('DLTOVR FILE(EMLAN0DF) LVL(*ACTGRPDFN)');
 system('DLTDTAQ DTAQ(QTEMP/EMLAN0)');

 Return;

END-PROC;


//#########################################################################
// Picture A loop
//#########################################################################
DCL-PROC loopFM_A;
 DCL-PI *N;
  pHost CHAR(16) CONST;
  pUser CHAR(32) CONST;
  pPassword CHAR(32) CONST;
  pSeconds PACKED(2 :0) CONST;
 END-PI;

 /INCLUDE QRPGLECPY,QRCVDTAQ

 DCL-S Success IND INZ(TRUE);

 DCL-DS IncomingData QUALIFIED INZ;
  Data CHAR(80);
  Length PACKED(5 :0);
 END-DS;

 DCL-DS FMA LIKEREC(EMLAN0AC :*ALL) INZ;
 //------------------------------------------------------------------------

 Success = initFM_A(pHost :pUser :pPassword :pSeconds);

 fetchRecordsFM_A();

 DoW ( This.PictureControl = FM_A );


   AFLin01 = 'Autorefresh: ' + %Char(This.RefreshSeconds) + 's';
   AC_Refresh = This.RefreshSeconds;

   Write EMLAN0AF;
   Write EMLAN0AC;

   RecieveDataQueue('EMLAN0' :'QTEMP' :IncomingData.Length :IncomingData.Data
                    :This.RefreshSeconds);

   If ( IncomingData.Data = '' );
     fetchRecordsFM_A();
     Iter;
   EndIf;

   Clear IncomingData;

   Read(E) EMLAN0AC FMA;
   This.RefreshSeconds = FMA.AC_Refresh;

   Select;

     When ( WSDS.Exit );
       This.PictureControl = FM_END;
       If This.Connected;
         disconnectFromHost();
       EndIf;

     When ( WSDS.Refresh );
       fetchRecordsFM_A();

     When ( WSDS.CommandLine = TRUE );
       pmtCmdLin();

     Other;
       fetchRecordsFM_A();

   EndSl;

 EndDo;


END-PROC;
//#########################################################################
// Initialize and fill values for picture A
//#########################################################################
DCL-PROC initFM_A;
 DCL-PI *N IND;
  pHost CHAR(16) CONST;
  pUser CHAR(32) CONST;
  pPassword CHAR(32) CONST;
  pSeconds PACKED(2 :0) CONST;
 END-PI;

 DCL-S Success IND INZ(TRUE);
 //------------------------------------------------------------------------

 Reset RecNum;
 Clear EMLAN0AC;
 Clear EMLAN0AS;

 ACDevice = PSDS.JobName;

 If ( pHost <> '' );
   This.LogInDataDS.Host = pHost;
 EndIf;
 If ( pUser <> '' );
   This.LogInDataDS.User = pUser;
 EndIf;
 If ( pPassword <> '' );
   This.LogInDataDS.Password = pPassword;
 EndIf;
 If ( pSeconds > 0 );
   This.RefreshSeconds = pSeconds;
 Else;
   This.RefreshSeconds = 10;
 EndIf;

 If ( This.LogInDataDS.Host = '' ) Or ( This.LogInDataDS.User = '' )
  Or ( This.LogInDataDS.Password = '' );
   Success = askForLogInData();
 EndIf;

 If Success;
   This.Connected = connectToHost();
   Success = This.Connected;
 EndIf;

 AC_Mail = This.LogInDataDS.User;

 Return Success;

END-PROC;
//#########################################################################
// Fetch data for picture A
//#########################################################################
DCL-PROC fetchRecordsFM_A;

 DCL-S Success IND INZ(TRUE);
 DCL-S i UNS(3) INZ;

 DCL-DS MailDS LIKEDS(MailDS_T) DIM(MAX_ROWS_TO_FETCH);
 DCL-DS SubfileDS QUALIFIED INZ;
  Color1 CHAR(1);
  Sender CHAR(40);
  Color2 CHAR(3);
  SendDate CHAR(25);
  Color3 CHAR(3);
  Subject CHAR(50);
 END-DS;
 //------------------------------------------------------------------------

 Reset RecNum;

 WSDS.SubfileClear = TRUE;
 WSDS.SubfileDisplayControl = TRUE;
 WSDS.SubfileDisplay = FALSE;
 WSDS.SubfileMore = FALSE;
 Write(E) EMLAN0AC;

 If This.Connected;
   Success = readMailsFromInbox(MailDS);
 EndIf;

 WSDS.SubfileClear = FALSE;
 WSDS.SubfileDisplayControl = TRUE;
 WSDS.SubfileDisplay = TRUE;
 WSDS.SubfileMore = TRUE;

 If ( This.RecordsFound > 0 ) And This.Connected;

   For i = 1 To This.RecordsFound;

     If ( MailDS(i).UnSeenFlag );
       SubfileDS.Color1 = COLOR_YLW_RI;
     Else;
       SubfileDS.Color1 = COLOR_GRN;
     EndIf;

     SubfileDS.Sender = MailDS(i).Sender;
     SubfileDS.Color2 = ' | ';
     SubfileDS.SendDate = MailDS(i).SendDate;
     SubfileDS.Color3 = ' | ';
     SubfileDS.Subject = MailDS(i).Subject;

     RecNum += 1;
     ASLine = SubfileDS;
     ASRecN = RecNum;
     Write EMLAN0AS;

   EndFor;

   If ( CurCur > 0 ) And ( CurCur <= RecNum );
     RecNum = CurCur;
   Else;
     RecNum = 1;
   EndIf;

 Else;

   RecNum = 1;
   ASRecN = RecNum;
   ASLine = This.GlobalMessage;
   Write EMLAN0AS;

 EndIf;

END-PROC;

//#########################################################################
// Check for login data
//#########################################################################
DCL-PROC askForLoginData;
 DCL-PI *N IND END-PI;

 DCL-S Success IND INZ(TRUE);
 //------------------------------------------------------------------------

 W0_Host = This.LogInDataDS.Host;
 W0_User = This.LogInDataDS.User;
 W0_Password = This.LogInDataDS.Password;

 DoU ( WSDS.Exit = TRUE );

   Write EMLAN0W0;
   ExFmt EMLAN0W0;

   If ( WSDS.Exit );
     Clear EMLAN0W0;
     Success = FALSE;
     Leave;
   Else;
     If ( W0_Host = '' );
       W0CRow = 3;
       W0CCol = 12;
       Iter;
     ElseIf ( W0_User = '' );
       W0CRow = 4;
       W0CCol = 12;
       Iter;
     ElseIf ( W0_Password = '' );
       W0CRow = 5;
       W0CCol = 12;
       Iter;
     Else;
       This.LogInDataDS.Host = W0_Host;
       This.LogInDataDS.User = W0_User;
       This.LogInDataDS.Password = W0_Password;
       Leave;
     EndIf;
   EndIf;

 EndDo;

 Return Success;

END-PROC;


//#########################################################################
// Connect to the selected host
//#########################################################################
DCL-PROC connectToHost;
 DCL-PI *N IND END-PI;

 DCL-S Success IND INZ(TRUE);
 DCL-S RC INT(10) INZ;
 DCL-S ErrorNumber INT(10) INZ;
 DCL-S Data CHAR(128) INZ;
 //------------------------------------------------------------------------

 // Search adress via hostname
 This.SocketDS.Address = inet_Addr(%TrimR(This.LogInDataDS.Host));
 If ( This.SocketDS.Address = INADDR_NONE );
   P_HostEnt = getHostByName(%TrimR(This.LogInDataDS.Host));
   If ( P_HostEnt = *NULL );
     This.GlobalMessage = %Str(strError(ErrNo));
     Success = FALSE;
   EndIf;
   This.SocketDS.Address = H_Addr;
 EndIf;

 // Create socket
 If Success;
   This.SocketDS.SocketHandler = socket(AF_INET :SOCK_STREAM :IPPROTO_IP);
   If ( This.SocketDS.SocketHandler < 0 );
     This.GlobalMessage = %Str(strError(ErrNo));
     cleanUp_Socket(This.SocketDS.SocketHandler);
     Success = FALSE;
   EndIf;
 EndIf;

 If Success;
   This.SocketDS.AddressLength = %Size(SockAddr);
   This.SocketDS.ConnectTo = %Alloc(This.SocketDS.AddressLength);

   P_SockAddr = This.SocketDS.ConnectTo;
   Sin_Family = AF_INET;
   Sin_Addr = This.SocketDS.Address;
   Sin_Port = DEFAULT_PORT;
   Sin_Zero = *ALLx'00';

   // Connect to host
   If ( Connect(This.SocketDS.SocketHandler :This.SocketDS.ConnectTo
                :This.SocketDS.AddressLength) < 0 );
     This.GlobalMessage = %Str(strError(ErrNo));
     cleanUp_Socket(This.SocketDS.SocketHandler);
     Success = FALSE;
   EndIf;
 EndIf;

 If Success;
   RC = recieveData(This.SocketDS.SocketHandler :%Addr(Data) :%Size(Data));
   Data = translateData(Data :UTF8 :LOCAL);
   Success = ( %Scan('OK' :Data) > 0 );
   If Success;
     Data = '* login ' + %TrimR(This.LogInDataDS.User) + ' ' +
            %TrimR(This.LogInDataDS.Password) + CRLF;
     Data = translateData(Data :LOCAL :UTF8);
     sendData(This.SocketDS.SocketHandler :%Addr(Data) :%Len(%TrimR(Data)));
     RC = recieveData(This.SocketDS.SocketHandler :%Addr(Data) :%Size(Data));
     If ( RC <= 0 );
       This.GlobalMessage = %Str(strError(ErrNo));
       disconnectFromHost();
       Success = This.Connected;
     Else;
       Data = translateData(Data :UTF8 :LOCAL);
       This.Connected = ( %Scan('OK' :Data) > 0 );
       If Not This.Connected;
         This.GlobalMessage = 'Wrong login data';
         disconnectFromHost();
         Success = This.Connected;
       EndIf;
     EndIf;
   Else;
     This.GlobalMessage = %Str(strError(ErrNo));
     disconnectFromHost();
     Success = This.Connected;
   EndIf;
 EndIf;

 Return Success;

END-PROC;


//#########################################################################
// Disconnect from host
//#########################################################################
DCL-PROC disconnectFromHost;

 DCL-S Data CHAR(32) INZ;
 //------------------------------------------------------------------------

 Data = '* logout' + CRLF;
 translateData(Data :LOCAL :UTF8);
 sendData(This.SocketDS.SocketHandler :%Addr(Data) :%Len(%TrimR(Data)));
 This.Connected = FALSE;
 cleanUp_Socket(This.SocketDS.SocketHandler);

END-PROC;


//#########################################################################
// Read mails from the selected inbox
//#########################################################################
DCL-PROC readMailsFromInbox;
 DCL-PI *N IND;
  pMailDS LIKEDS(MailDS_T) DIM(MAX_ROWS_TO_FETCH);
 END-PI;

 DCL-S Success IND INZ(TRUE);
 DCL-S a UNS(10) INZ;
 DCL-S b UNS(10) INZ;
 DCL-S RC INT(10) INZ;
 DCL-S ErrorNumber INT(10) INZ;
 DCL-S Data CHAR(16384) INZ;
 //------------------------------------------------------------------------

 Data = '* examine inbox' + CRLF;
 Data = translateData(Data :LOCAL :UTF8);
 sendData(This.SocketDS.SocketHandler :%Addr(Data) :%Len(%TrimR(Data)));
 RC = recieveData(This.SocketDS.SocketHandler :%Addr(Data) :%Size(Data));
 If ( RC <= 0 );
   This.GlobalMessage = %Str(strError(ErrNo));
   Success = FALSE;
 Else;
   Data = translateData(Data :UTF8 :LOCAL);
   If ( %Scan('NO EXAMINE' :Data) > 0 );
     This.GlobalMessage = 'Mailbox not found';
     Success = FALSE;
   Else;
     Monitor;
       This.RecordsFound = %Uns(%SubSt(Data :3 :%Scan('EXISTS' :Data) - 4));
       On-Error;
         Clear This.RecordsFound;
     EndMon;
   EndIf;
 EndIf;

 If Success And ( This.RecordsFound > 0 );
   For a = This.RecordsFound DownTo 1;
     Data = '* fetch ' + %Char(a) + ' (FLAGS BODY[HEADER.FIELDS (FROM DATE SUBJECT)])' + CRLF;
     Data = translateData(Data :LOCAL :UTF8);
     sendData(This.SocketDS.SocketHandler :%Addr(Data) :%Len(%TrimR(Data)));
     RC = recieveData(This.SocketDS.SocketHandler :%Addr(Data) :%Size(Data));
     If ( RC > 0 );
       Data = translateData(Data :UTF8 :LOCAL);
       If ( %Scan('* OK FETCH' :Data) > 0 );
         If ( b = MAX_ROWS_TO_FETCH );
           Leave;
         EndIf;
         b += 1;
         pMailDS(b) = extractFieldsFromStream(Data);
       EndIf;
     EndIf;
   EndFor;
 EndIf;

 This.RecordsFound = b;

 Return Success;

END-PROC;


//#########################################################################
// Extract single values from stream
//#########################################################################
DCL-PROC extractFieldsFromStream;
 DCL-PI *N LIKEDS(MailDS_T);
  pData CHAR(16384) CONST;
 END-PI;

 DCL-S s UNS(10) INZ;
 DCL-S e UNS(10) INZ;

 DCL-DS MailDS LIKEDS(MailDS_T) INZ;
 //------------------------------------------------------------------------

 s = %Scan('From:' :pData) + 6;
 e = %Scan(CRLF :pData :s) - 1;
 If ( s > 0 ) And ( e > s );
   MailDS.Sender = %SubSt(pData :s :(e - s) + 1);
   If ( %Scan('@' :MailDS.Sender) = 0 );
     Clear MailDS.Sender;
   EndIf;
 EndIf;

 s = %Scan('Date:' :pData) + 6;
 e = %Scan(CRLF :pData :s) - 1;
 If ( s > 0 ) And ( e > s );
   MailDS.SendDate = %SubSt(pData :s :(e - s) + 1);
 EndIf;

 s = %Scan('Subject:' :pData) + 9;
 e = %Scan(CRLF :pData :s) - 1;
 If ( s > 0 ) And ( e > s );
   MailDS.Subject = %SubSt(pData :s :(e - s) + 1);
   If ( %SubSt(MailDS.Subject :1 :2) = '=?' );
     MailDS.Subject = 'Undefined subject';
   EndIf;
 EndIf;

 MailDS.UnseenFlag = ( %Scan('\Seen' :pData) = 0 );

 Return MailDS;

END-PROC;


//#########################################################################
// Send data to socket
//#########################################################################
DCL-PROC sendData;
 DCL-PI *N INT(10);
   pSocketHandler INT(10) CONST;
   pData POINTER VALUE;
   pLength INT(10) CONST;
 END-PI;

 DCL-S RC INT(10) INZ;
 DCL-S Buffer CHAR(32766) BASED(pData);
 //-------------------------------------------------------------------------

 RC = send(pSocketHandler :%Addr(Buffer) :pLength :0);

 Return RC;

END-PROC;


//#########################################################################
// Retrieve data from socket
//#########################################################################
DCL-PROC recieveData;
 DCL-PI *N INT(10);
   pSocketHandler INT(10) CONST;
   pData POINTER VALUE;
   pLength INT(10) VALUE;
 END-PI;

 DCL-S RC INT(10) INZ;
 DCL-S Buffer CHAR(32766) BASED(pData);
 //-------------------------------------------------------------------------

 RC = recv(pSocketHandler :%Addr(Buffer) :pLength :0);

 Return RC;

END-PROC;


//#########################################################################
// Close socket
//#########################################################################
DCL-PROC cleanUp_Socket;
 DCL-PI *N;
  pSocketHandler INT(10) CONST;
 END-PI;
 //-------------------------------------------------------------------------

 close_Socket(pSocketHandler);

END-PROC;


//#########################################################################
// Translate data between ccsids
//#########################################################################
DCL-PROC translateData;
 DCL-PI *N CHAR(1024);
  pStream CHAR(1024) CONST;
  pFromCCSID INT(10) CONST;
  pToCCSID INT(10) CONST;
 END-PI;

 DCL-PR iConv_Open LIKE(ToASCII) EXTPROC('QtqIconvOpen');
  ToCode LIKE(FromDS);
  FromCode LIKE(ToDS);
 END-PR;

 DCL-PR iConv INT(10) EXTPROC('iconv');
  Descriptor LIKE(ToASCII) VALUE;
  InBuff POINTER;
  InLeft UNS(10);
  OutBuffer POINTER;
  OutLeft UNS(10);
 END-PR;

 DCL-PR iConv_Close INT(10) EXTPROC('iconv_close');
  Descriptor LIKE(ToASCII) VALUE;
 END-PR;

 DCL-S ConvHandler POINTER;
 DCL-S Length UNS(10) INZ;
 DCL-S Result CHAR(1024) INZ;

 DCL-DS ToASCII QUALIFIED INZ;
  ICORV_A INT(10);
  ICOC_A INT(10) DIM(12);
 END-DS;

 DCL-DS FromDS QUALIFIED;
  FromCCSID INT(10) INZ;
  CA INT(10) INZ;
  SA INT(10) INZ;
  SS INT(10) INZ;
  IL INT(10) INZ;
  EO INT(10) INZ;
  R CHAR(8) INZ(*ALLX'00');
 END-DS;

 DCL-DS ToDS QUALIFIED;
  ToCCSID INT(10) INZ;
  CA INT(10) INZ;
  SA INT(10) INZ;
  SS INT(10) INZ;
  IL INT(10) INZ;
  EO INT(10) INZ;
  R CHAR(8) INZ(*ALLX'00');
 END-DS;
 //-------------------------------------------------------------------------

 Result = %TrimR(pStream);
 ConvHandler = %Addr(Result);
 Length = %Len(%TrimR(Result));
 FromDS.FromCCSID = pFromCCSID;
 ToDS.ToCCSID = pToCCSID;
 ToASCII = iConv_Open(ToDS :FromDS);
 If ( ToASCII.ICORV_A >= 0 );
   iConv(ToASCII  :ConvHandler :Length  :ConvHandler :Length);
 EndIf;
 iConv_Close(ToASCII);

 Return Result;

END-PROC;


/DEFINE LOAD_ERRNO_PROCEDURE
/INCLUDE QRPGLECPY,ERRNO_H
