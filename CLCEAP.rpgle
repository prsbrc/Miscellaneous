**FREE
//- Copyright (c) 2015-2018 Christian Brunner

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

CTL-OPT MAIN( Main ) DECEDIT( '0,' ) ALWNULL( *USRCTL ) DATFMT( *ISO- ) TIMFMT( *ISO. )
        AUT( *USE ) DFTACTGRP( *NO ) ACTGRP( *CALLER ) DEBUG( *YES ) USRPRF( *OWNER );

DCL-PR Main EXTPGM('CLCEAPRG');
 EAN CHAR(14);
END-PR;

DCL-C TRUE *ON;
DCL-C FALSE *OFF;


DCL-PROC Main;
DCL-PI Main;
 pEAN CHAR(14);
END-PI;

DCL-S i UNS(5) INZ;
DCL-S EAN PACKED(2 :0) DIM(13) INZ;
DCL-S Multi CHAR(14) INZ('13131313131313');
DCL-S Work UNS(3) INZ;

 Multi = %SubSt(Multi :%Len(Multi) - %Len(%Trim(pEAN)) + 1 :%Len(%Trim(pEAN)));
 For i = 1 To (%Len(%Trim(pEAN)));
   EAN(i) = %Dec(%SubSt(%Trim(pEAN) :i :1) :1 :0) * %Dec(%SubSt(Multi: i: 1) :1 :0);
 EndFor;
 Work = ((%Dec(%XFoot(EAN) / 10 :9 :0) * 10) + 10) - %XFoot(EAN);
 pEAN = %Trim(pEAN) + %Char(Work);

 Return;

END-PROC;
