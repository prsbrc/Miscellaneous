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


// This example read the dataqueue, calls the program to read wanted data and write this one to the display file

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) MAIN(Main);


DCL-F PROTO2DF WORKSTN MAXDEV(*FILE) EXTFILE('BRUNNER/PROTO2DF') USROPN;


DCL-PR Main EXTPGM('PROTO2RG') END-PR;


DCL-PROC Main;
  DcL-PI *N END-PI;

  /INCLUDE QRPGLECPY,SYSTEM
  /INCLUDE QRPGLECPY,QRCVDTAQ

  DCL-PR dynamicCall EXTPGM(DynamicCallDS.ProgramName);
    Parameters LIKEDS(Parameters_Template);
  END-PR;

  DCL-S Success IND INZ(*ON);
  DCL-DS Incoming_Data QUALIFIED INZ;
    Data CHAR(80);
    Length PACKED(5 :0);
  End-DS;

  DCL-DS Parameters_Template TEMPLATE QUALIFIED;
    InParameter CHAR(100) DIM(20);
    OutParameter CHAR(130) DIM(27);
  END-DS;

  DCL-DS DynamicCallDS QUALIFIED INZ;
    ProgramName CHAR(10);
    Parameters LIKEDS(Parameters_Template);
  END-DS;
//*----


  system('CRTDTAQ DTAQ(BRUNNER/BRUNNER) MAXLEN(80)');
  system('OVRDSPF FILE(PROTO2DF) OVRSCOPE(*JOB) DTAQ(BRUNNER/BRUNNER)');
  
  If Not %Open(PROTO2DF);
    Open PROTO2DF;
  EndIf;

  Reset Success;

  DoW ( 1 = 1 );

    Reset Incoming_Data;
    Monitor;
      recieveDataQueue('BRUNNER' :'BRUNNER' :Incoming_Data.Length :Incoming_Data.Data :60);
      On-Error;
        Success = *OFF;
    EndMon;

    If ( Incoming_Data.Length = 0 );
      Iter;
    ElseIf ( %SubSt(Incoming_Data.Data :1 :5) = '*DSPF' );
      Read(E) PROTO2A0;
      If ( *INKC = *ON );
        Leave;
      EndIf;
    Else;
      DynamicCallDS.ProgramName = %SubSt(Incoming_Data.Data :1 :10);
      DynamicCallDS.Parameters.InParameter(1) = %SubSt(Incoming_Data.Data :11 :10);
      DynamicCallDS.Parameters.InParameter(2) = %SubSt(Incoming_Data.Data :21 :10);
      Monitor;
        dynamicCall(DynamicCallDS.Parameters);
        On-Error;
          Success = *OFF;
      EndMon;
      
      If Success;
        A02Line01 = DynamicCallDS.Parameters.OutParameter(01);
        A02Line02 = DynamicCallDS.Parameters.OutParameter(02);
        A02Line03 = DynamicCallDS.Parameters.OutParameter(03);
        A02Line04 = DynamicCallDS.Parameters.OutParameter(04);
        A02Line05 = DynamicCallDS.Parameters.OutParameter(05);
        A02Line06 = DynamicCallDS.Parameters.OutParameter(06);
        A02Line07 = DynamicCallDS.Parameters.OutParameter(07);
        A02Line08 = DynamicCallDS.Parameters.OutParameter(08);
        A02Line09 = DynamicCallDS.Parameters.OutParameter(09);
        A02Line10 = DynamicCallDS.Parameters.OutParameter(10);
        A02Line11 = DynamicCallDS.Parameters.OutParameter(11);
        A02Line12 = DynamicCallDS.Parameters.OutParameter(12);
      EndIf;
    EndIf;
    
    Write PROTO2A0;

  EndDo;

  If %Open(PROTO2DF);
    Close PROTO2DF;
  EndIf;
  
  system('DLTOVR FILE(PROTO2DF) LVL(*JOB) ');

  *INLR = *ON;
  Return;

End-Proc;
