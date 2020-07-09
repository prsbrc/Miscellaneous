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
DCL-PR Main EXTPGM('CHGOBJARG');
 ObjectLibrary LIKEDS(QualifiedObjectName_T) CONST;
 ObjectType CHAR(10) CONST;
 SystemName CHAR(8) CONST;
 CreatedBy CHAR(10) CONST;
 CreatedOnDate CHAR(13) CONST;
 NewOwner CHAR(10) CONST;
END-PR;

DCL-DS QualifiedObjectName_T QUALIFIED TEMPLATE;
 Name CHAR(10);
 Library CHAR(10);
END-DS;


//#########################################################################
//- MAIN-Procedure
//#########################################################################
DCL-PROC Main;
 DCL-PI *N;
  pObject LIKEDS(QualifiedObjectName_T) CONST;
  pObjectType CHAR(10) CONST;
  pSystemName CHAR(8) CONST;
  pCreatedBy CHAR(10) CONST;
  pCreatedOnDate CHAR(13) CONST;
  pNewOwner CHAR(10) CONST;
 END-PI;

 DCL-PR changeObjectAttribute EXTPGM('QLICOBJD');
  ReturnedLibrary CHAR(10);
  ObjectLibrary CHAR(20) CONST;
  ObjectType CHAR(10) CONST;
  Data LIKEDS(DataDS) CONST;
  Error CHAR(128) OPTIONS(*VARSIZE);
 END-PR;

 DCL-PR system INT(10) EXTPROC('system');
  *N POINTER VALUE OPTIONS(*STRING);
 END-PR;

 DCL-S Lib CHAR(10) INZ;
 DCL-S Error CHAR(128) INZ;
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
 If ( pSystemName <> '*SAME' );
   DataDS.Key = 18;
   DataDS.Data = pSystemName;
   changeObjectAttribute(Lib :pObject.Name + pObject.Library :pObjectType :DataDS :Error);
 EndIf;

 // Change userprofile (created by)
 If ( pCreatedBy <> '*SAME' );
   DataDS.Key = 19;
   DataDS.Data = pCreatedBy;
   changeObjectAttribute(Lib :pObject.Name + pObject.Library :pObjectType :DataDS :Error);
 EndIf;

 // Change date/time (created on)
 If ( pCreatedOnDate <> '*SAME' );
   DataDS.Key = 20;
   DataDS.Data = pCreatedOnDate;
   changeObjectAttribute(Lib :pObject.Name + pObject.Library :pObjectType :DataDS :Error);
 EndIf;

 If ( pNewOwner <> '*SAME' );
   system('CHGOBJOWN OBJ(' + %TrimR(pObject.Library) + '/' + %TrimR(pObject.Name) +
          ') OBJTYPE(' + %TrimR(pObjectType) + ') ASPDEV(*) NEWOWN(' + %TrimR(pNewOwner) +
          ') CUROWNAUT(*REVOKE)');
 EndIf;

 Return;

END-PROC;
