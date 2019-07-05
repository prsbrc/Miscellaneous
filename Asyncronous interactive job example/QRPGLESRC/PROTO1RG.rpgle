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


// This example program sends the data to the dataqueue

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) MAIN(Main);


DCL-F PROTO1DF WORKSTN EXTFILE('BRUNNER/PROTO1DF') USROPN;


DCL-PR Main EXTPGM('PROTO1RG') END-PR;


DCL-PROC Main;
  DCL-PI *N END-PI;

  /INCLUDE QRPGLECPY,SYSTEM
  /INCLUDE QRPGLECPY,QSNDDTAQ

  DCL-S OutParm CHAR(30) INZ;

//*----

  *INLR = *ON;

  If Not %Open(PROTO1DF);
    Open PROTO1DF;
  EndIf;

  system('CRTDTAQ DTAQ(BRUNNER/BRUNNER) MAXLEN(80)');

  DoW ( 1 = 1 );

    ExFmt PROTO1A0;

    If ( *INKC = *ON );
      Leave;
    EndIf;

    OutParm = 'PROTO3RG  ' + A01KNr + A01ANr;
    sendToDataQueue('BRUNNER' :'BRUNNER' :%Len(%TrimR(OutParm)) :OutParm);

  EndDo;

  system('DLTDTAQ DTAQ(BRUNNER/BRUNNER)');

  If %Open(PROTO1DF);
    Close PROTO1DF;
  EndIf;

  Return;

End-Proc;
