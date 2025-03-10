**FREE
//- Copyright (c) 2025 Christian Brunner

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

// This example shows you how to handle jobs controlled by another messagequeue

// CRTMSGQ MSGQ(YOURLIB/YOURMSGQ)
// CHGUSRPRF USRPRF(USER) MSGQ(YOURLIB/YOURMSGQ)
// CHGMSGQ MSGQ(YOURLIB/YOURMSGQ) DLVRY(*BREAK) PGM(YOURLIB/TESTMSGRG)
// SNDMSG MSG(HI) TOMSGQ(YOURLIB/YOURMSGQ)

CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES)
        USRPRF(*OWNER) MAIN(Main);


DCL-PR Main EXTPGM('TESTMSGRG');
 MessageQueue CHAR(10) CONST;
 MessageQueueLibrary CHAR(10) CONST;
 Messagekey CHAR(4) CONST;
END-PR;

//--------------------------------------
DCL-PROC Main;
 DCL-PI *N;
  pMessageQueue CHAR(10) CONST;
  pMessageQueueLibrary CHAR(10) CONST;
  pMessageKey CHAR(4) CONST;
 END-PI;

 DCL-PR receiveMessage EXTPGM('QMHRCVM');
  MessageText CHAR(32767) OPTIONS(*VARSIZE);
  MessageTextLength INT(10) CONST;
  MessageFormat CHAR(8) CONST;
  MessageQueue CHAR(20) CONST;
  MessageType CHAR(10) CONST;
  MessageKey CHAR(4) CONST;
  MessageWait INT(10) CONST;
  MessageAction CHAR(10) CONST;
  Error CHAR(100);
 END-PR;

 DCL-DS MessageData QUALIFIED INZ;
  Text CHAR(100) POS(49);
 END-DS;

 DCL-S MessageDataLength INT(10) INZ(%LEN(MessageData));
 DCL-S MessageQueue CHAR(20) INZ;
 DCL-S APIError CHAR(100) INZ;
//--------------------------------------

 receiveMessage(MessageData :MessageDataLength :'RCVM0100'
                  :pMessageQueue + pMessageQueueLibrary :'*ANY'
                  :pMessageKey :0 :'*REMOVE' :APIError);

 // Do something with MessageData.Text

 Return;

END-PROC;
