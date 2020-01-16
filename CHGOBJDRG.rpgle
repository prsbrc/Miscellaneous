**FREE
//- Copyright (c) 2020 Christian Brunner

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


// This source is a example for the api QLICOBJD
//  For further informations look at the following link:
//    -> https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/apis/qlicobjd.htm


CTL-OPT MAIN(Main) ALWNULL(*USRCTL) AUT(*EXCLUDE) DATFMT(*ISO-) TIMFMT(*ISO.) DECEDIT('0,')
        DFTACTGRP(*NO) ACTGRP(*NEW) DEBUG(*YES) USRPRF(*OWNER);


// Program prototype
DCL-PR Main EXTPGM('CHGOBJDRG') END-PR;


//#########################################################################
//- MAIN-Procedure
//#########################################################################
DCL-PROC Main;

 DCL-PR changeObjectDescription EXTPGM('QLICOBJD');
  ReturnedLibrary CHAR(10);
  ObjectLibrary CHAR(20) CONST;
  ObjectType CHAR(10) CONST;
  Data LIKEDS(DataDS) CONST;
  Error CHAR(128) OPTIONS(*VARSIZE);
 END-PR;

 DCL-S Lib CHAR(10) INZ;
 DCL-S Error CHAR(128) INZ;
 DCL-C ObjLib 'T         BRUNNER';
 DCL-C ObjType '*PGM';
 DCL-C NewStamp '1501231010101';

 DCL-DS DataDS QUALIFIED INZ;
  Num INT(10);
  Key INT(10);
  Length INT(10);
  Data CHAR(20);
 END-DS;
//-------------------------------------------------------------------------

 *INLR = *ON;

 DataDS.Num = 1;
 DataDS.Length = %Len(DataDS.Data);

 // Change systemname
 DataDS.Key = 18;
 DataDS.Data = 'brunner';
 changeObjectDescription(Lib :ObjLib :ObjType :DataDS :Error);

 // Change userprofile (created by)
 DataDS.Key = 19;
 DataDS.Data = 'brc';
 changeObjectDescription(Lib :ObjLib :ObjType :DataDS :Error);

 // Change date/time (created on)
 DataDS.Key = 20;
 DataDS.Data = NewStamp;
 changeObjectDescription(Lib :ObjLib :ObjType :DataDS :Error);

 Return;

END-PROC;
