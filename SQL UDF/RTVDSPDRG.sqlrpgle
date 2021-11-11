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

// CRTSRVPGM SRVPGM(BRUNNER/RTVDSPDRG) MODULE(BRUNNER/RTVDSPDRG) EXPORT(*ALL)


CTL-OPT ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES) NOMAIN;


//#########################################################################
DCL-PROC rtvdspvrtdevd EXPORT;
 DCL-PI *N;
  DeviceNameIn VARCHAR(10) CONST;
  DeviceNameOut VARCHAR(10);
  DeviceCategory VARCHAR(10);
  TextDescription VARCHAR(50);
  LastActivityDate DATE;
  n_DeviceNameIn INT(5);
  n_DeviceNameOut INT(5);
  n_DeviceCategory INT(5);
  n_TextDescription INT(5);
  n_LastActivityDate INT(5);
  State CHAR(5);
  Function VARCHAR(517) CONST;
  Specific VARCHAR(128) CONST;
  ErrorMsg VARCHAR(1000);
  CallType INT(10) CONST;
 END-PI;

 DCL-C CALL_OPEN -1;
 DCL-C CALL_FETCH 0;
 DCL-C CALL_CLOSE 1;
 DCL-C PARM_NULL -1;
 DCL-C PARM_NOTNULL 0;

 DCL-S InternalDeviceName CHAR(10) INZ;
 //------------------------------------------------------------------------

 Exec SQL SET OPTION DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     CLOSQLCSR = *ENDACTGRP, USRPRF = *OWNER, DYNUSRPRF = *OWNER,
                     COMMIT = *NONE;

 If ( n_DeviceNameIn = PARM_NULL );
   Reset InternalDeviceName;
 Else;
   InternalDeviceName = DeviceNameIn;
 EndIf;

 Select;
   When ( CallType = CALL_OPEN );
     openReader(InternalDeviceName);

   When ( CallType = CALL_FETCH );
     fetchNextFromReader(DeviceNameOut :DeviceCategory :TextDescription
                         :LastActivityDate :State :ErrorMsg);

   When ( CallType = CALL_CLOSE );
     closeReader();

 EndSl;

 Return;

END-PROC;

//#########################################################################
DCL-PROC openReader;
 DCL-PI *N;
  DeviceName VARCHAR(10) CONST;
 END-PI;
 //------------------------------------------------------------------------

 Exec SQL DECLARE display_device_description_reader CURSOR FOR
           SELECT RTRIM(devd.objname),
                  RTRIM(devd.objattribute, ''),
                  RTRIM(IFNULL(CAST(devd.text as CHAR(50)), ''))
             FROM TABLE(qsys2.object_statistics
                         (object_schema => 'QSYS', objtypelist => '*DEVD')) AS devd
            WHERE devd.objattribute = 'DSPVRT'
              AND devd.objname =
                   CASE WHEN :DeviceName = '' THEN devd.objname
                        ELSE :DeviceName END;

 Exec SQL OPEN display_device_description_reader;

END-PROC;

//#########################################################################
DCL-PROC fetchNextFromReader;
 DCL-PI *N;
  DeviceName VARCHAR(10);
  DeviceCategory VARCHAR(10);
  TextDescription VARCHAR(50);
  LastActivityDate DATE;
  State CHAR(5);
  ErrorMsg VARCHAR(1000);
 END-PI;

 DCL-PR QDCRDEVD EXTPGM('QDCRDEVD');
  Receiver CHAR(32767) OPTIONS(*VARSIZE);
  LengthReceiver INT(10) CONST;
  Format CHAR(8) CONST;
  DeviceName CHAR(10) CONST;
  ErrorCode CHAR(32767) OPTIONS(*VARSIZE);
 END-PR;

 DCL-DS F_DEVD0600_DS QUALIFIED;
  TextDescription CHAR(50) POS(52);
  LastActivityDate CHAR(7) POS(973);
 END-DS;

 DCL-S ErrorValue CHAR(512) INZ;
 //------------------------------------------------------------------------

 Exec SQL FETCH NEXT FROM display_device_description_reader
           INTO :DeviceName, :DeviceCategory, :TextDescription;

 If ( SQLCode = 100 );
   // Set state for eof
   State = '02000';

 ElseIf ( SQLCode <> 0 ) And ( SQLCode <> 100 );
   // Set stae for error, all of them
   State = '38998';
   Exec SQL GET DIAGNOSTICS CONDITION 1 :ErrorMsg = MESSAGE_TEXT;

 Else;
   // Everything is okay, lets get the devd-informations
   QDCRDEVD(F_DEVD0600_DS :%Size(F_DEVD0600_DS) :'DEVD0600'
            :DeviceName :ErrorValue);

   If ( TextDescription = '' );
     TextDescription = %TrimR(F_DEVD0600_DS.TextDescription);
   EndIf;

   If ( F_DEVD0600_DS.LastActivityDate <> '' );
     LastActivityDate = translateDate(F_DEVD0600_DS.LastActivityDate);
   EndIf;

 EndIf;

END-PROC;

//#########################################################################
DCL-PROC closeReader;

 Exec SQL CLOSE display_device_description_reader;

END-PROC;

//#########################################################################
DCL-PROC translateDate;
 // Translate system date to real date
 //  Use first digit to determine century (0=19, 1=20)
 DCL-PI *N DATE;
  pDateIn CHAR(7) CONST;
 END-PI;

 DCL-S WorkDate DATE INZ;
 DCL-S WorkChar CHAR(8) INZ;
 //------------------------------------------------------------------------

 Select;
   When ( %SubSt(pDateIn :1 :1) = '0' );
     WorkChar = '19' + %SubSt(pDateIn :2 :6);

   When ( %SubSt(pDateIn :1 :1) = '1' );
     WorkChar = '20' + %SubSt(pDateIn :2 :6);

 EndSl;

 Exec SQL SET :WorkDate = DATE(TO_DATE(:WorkChar, 'YYYYMMDD'));
 If ( SQLCode <> 0 );
   Reset WorkDate;
 EndIf;

 Return WorkDate;

END-PROC;
