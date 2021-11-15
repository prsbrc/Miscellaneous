**FREE

//- Copyright (c) 2021 Christian Brunner

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

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES)
        USRPRF(*OWNER) MAIN(Main);

DCL-PR Main EXTPGM('PRTIFSPDFR');
  PathName CHAR(512) CONST;
  OutQueue LIKEDS(ObjectLibraryDS_T) CONST;
END-PR;

DCL-DS ObjectLibraryDS_T QUALIFIED TEMPLATE;
  Object CHAR(10);
  Library CHAR(10);
END-DS;


//#########################################################################
DCL-PROC Main;
  DCL-PI *N;
    pPathName CHAR(512) CONST;
    pObjectLibrary LIKEDS(ObjectLibraryDS_T) CONST;
  END-PI;
//-------------------------------------------------------------------------

  *INLR = *ON;

  printPDFToPrinter(pPathName :pObjectLibrary);

  Return;

END-PROC;

//#########################################################################
DCL-PROC printPDFToPrinter;
  DCL-PI *N;
    pPathName CHAR(512) CONST;
    pObjectLibrary LIKEDS(ObjectLibraryDS_T) CONST;
  END-PI;

  DCL-F QSYSPRT PRINTER(132) USAGE(*OUTPUT) USROPN;

  /INCLUDE QRPGLECPY,SYSTEM
  DCL-PR ifsOpen INT(10) EXTPROC('open');
    FileName POINTER VALUE OPTIONS(*STRING);
    OpenFlags INT(10) VALUE;
    Mode UNS(10) VALUE OPTIONS(*NOPASS);
    CCSID UNS(10) VALUE OPTIONS(*NOPASS);
    TextCreateID UNS(10) VALUE OPTIONS(*NOPASS);
  END-PR;
  DCL-PR ifsRead INT(10) EXTPROC('read');
    Handle INT(10) VALUE;
    Buffer POINTER VALUE;
    Bytes UNS(10) VALUE;
  END-PR;
  DCL-PR ifsClose INT(10) EXTPROC('close');
    Handle INT(10) VALUE;
  END-PR;

  DCL-C O_RDONLY 1;

  DCL-DS PrinterDS QUALIFIED INZ;
    Line CHAR(132);
  END-DS;

  DCL-S FileHandler INT(10) INZ;
  DCL-S Buffer CHAR(132) INZ;
//-------------------------------------------------------------------------

  If %Open(QSYSPRT);
    // Close printerfile when allready opened (due failure etc)
    Close QSYSPRT;
  EndIf;

  System('OVRPRTF FILE(QSYSPRT) DEVTYPE(*USERASCII) OUTQ(' +
         %TrimR(pObjectLibrary.Library) + '/' + %TrimR(pObjectLibrary.Object) +
         ') OVRSCOPE(*ACTGRPDFN)');

  If Not %Open(QSYSPRT);
    // Open printerfile with overrided values from above
    Open(E) QSYSPRT;
  EndIf;

  If Not %Error();

    FileHandler = ifsOpen(%TrimR(pPathName) :O_RDONLY );

    If ( FileHandler >= 0 );

      DoW ( ifsRead(FileHandler :%Addr(Buffer) :%Size(Buffer)) > 0 );
        PrinterDS.Line = Buffer;
        Write QSYSPRT PrinterDS;
        Clear Buffer;
      EndDo;

    EndIf;

  EndIf;


On-Exit;
  If ( FileHandler >= 0 );
    ifsClose(FileHandler);
  EndIf;

  If %Open(QSYSPRT);
    Close QSYSPRT;
  EndIf;

  System('DLTOVR FILE(QSYSPRT) LVL(*ACTGRPDFN)');

END-PROC;
