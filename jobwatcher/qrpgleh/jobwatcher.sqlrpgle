**FREE
//- Copyright (c) 2021 Christian Brunner
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


// Header for JOBWATCHER


/IF DEFINED (JOBWATCHER_H)
/EOF
/ENDIF

/DEFINE JOBWATCHER_H


CTL-OPT MAIN(Main) ALWNULL(*USRCTL) USRPRF(*OWNER)
         DATFMT(*ISO-) TIMFMT(*ISO.) DECEDIT('0.') AUT(*EXCLUDE)
         OPTION(*NODEBUGIO :*SRCSTMT :*NOUNREF)
         DFTACTGRP(*NO) ACTGRP(*NEW);

/INCLUDE QRPGLECPY,BOOLIC
/INCLUDE QRPGLECPY,ERRORDS_H

DCL-PR Main EXTPGM('JOBWATCHER') END-PR;

DCL-DS MSGWJobs_T QUALIFIED TEMPLATE;
 Jobname VARCHAR(28);
 MessageID CHAR(7);
 MessageKey CHAR(10);
END-DS;
