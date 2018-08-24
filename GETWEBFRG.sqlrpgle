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

//  00000000                        BRC      24.08.2018

CTL-OPT MAIN(Main) ALWNULL(*USRCTL) AUT(*EXCLUDE)
        DATFMT(*ISO-) TIMFMT(*ISO.) DECEDIT('0,') ALLOC(*TERASPACE)
        DFTACTGRP(*NO) ACTGRP(*NEW) DEBUG(*YES) USRPRF(*OWNER);


// Program prototype ------------------------------------------------------
DCL-PR Main EXTPGM('GETWEBFRG');
  TargetURL CHAR(128) CONST;
  TargetIFS CHAR(128) CONST;
END-PR;


// Global constants -------------------------------------------------------
/INCLUDE GHP3MOD/QRPGLECPY,CONSTANTS


//#########################################################################
//- MAIN-Procedure
//#########################################################################
DCL-PROC Main;
 DCL-PI *N;
   pTargetURL CHAR(128) CONST;
   pTargetIFS CHAR(128) CONST;
 END-PI;

 DCL-S TargetFile SQLTYPE(BLOB_FILE);
 DCL-S URL VARCHAR(128) INZ;
 //------------------------------------------------------------------------

 Exec SQL SET OPTION DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     CLOSQLCSR = *ENDMOD, USRPRF = *OWNER, DYNUSRPRF = *OWNER,
                     COMMIT = *NONE;

 URL = %TrimR(pTargetURL);

 TargetFile_Name = %TrimR(pTargetIFS);
 TargetFile_NL   = %Len(%TrimR(pTargetIFS));
 TargetFile_FO   = SQFOVR;

 Exec SQL SELECT SYSTOOLS.HTTPGETBLOB(:URL, '') INTO :TargetFile
            FROM SYSIBM.SYSDUMMY1;

 *INLR = TRUE;
 Return;

END-PROC;
