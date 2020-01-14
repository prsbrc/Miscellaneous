**FREE
//- Copyright (c) 2015-2020 Christian Brunner

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

CTL-OPT MAIN(Main) DECEDIT('0,') ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.)
        AUT(*EXCLUDE) DFTACTGRP(*NO) ACTGRP(*NEW) DEBUG(*YES) USRPRF(*OWNER);

DCL-PR Main EXTPGM('CLCEAP');
 EAN CHAR(14) CONST;
END-PR;


DCL-PROC Main;
 DCL-PI Main;
  pEAN CHAR(14) CONST;
 END-PI;

 DCL-PR displayOSWindow EXTPGM('QUILNGTX');
  TextString CHAR(32765) CONST OPTIONS(*VARSIZE);
  TextLength INT(10) CONST;
  MessageID CHAR(7) CONST;
  MessageFile CHAR(20) CONST;
  ErrorArea CHAR(256);
 END-PR;

 DCL-S i UNS(5) INZ;
 DCL-S EAN PACKED(2 :0) DIM(13) INZ;
 DCL-S Multi CHAR(14) INZ('13131313131313');
 DCL-S Work UNS(3) INZ;
 DCL-S Result CHAR(64) INZ;
 DCL-S Error CHAR(256) INZ;

 *INLR = *ON;

 Multi = %SubSt(Multi :%Len(Multi) - %Len(%Trim(pEAN)) + 1 :%Len(%Trim(pEAN)));
 For i = 1 To (%Len(%Trim(pEAN)));
   EAN(i) = %Dec(%SubSt(%Trim(pEAN) :i :1) :1 :0) * %Dec(%SubSt(Multi: i: 1) :1 :0);
 EndFor;
 Work = ((%Dec(%XFoot(EAN) / 10 :9 :0) * 10) + 10) - %XFoot(EAN);
 Result = 'Result: ' + %Trim(pEAN) + %Char(Work);

 displayOSWindow(Result :%Len(%TrimR(Result)) :'' :'' :Error);

 Return;

END-PROC;
