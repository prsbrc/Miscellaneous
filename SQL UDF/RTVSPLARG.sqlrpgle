**FREE
//- Copyright (c) 2022 Christian Brunner

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

// CRTSRVPGM SRVPGM(LIBRARY/RTVSPLFARG) MODULE(LIBRARY/RTVSPLFARG) EXPORT(*ALL)


/include library/qrpgleh,rtvsplfarg


//#########################################################################
DCL-PROC rtvdspooledfileattributes EXPORT;
 DCL-PI *N;
  OutputQueueNameIn VARCHAR(10) CONST;
  OutputQueueNameLibraryIn VARCHAR(10) CONST;
  SpooledfileNameIn VARCHAR(10) CONST;
  JobNameIn VARCHAR(28) CONST;
  SpooledFileNumberIn INT(10) CONST;

  OutputQueueName VARCHAR(10);
  OutputQueueNameLibrary VARCHAR(10);
  CreateTimestamp TIMESTAMP;
  SpooledFileName VARCHAR(10);
  UserName VARCHAR(10);
  UserData VARCHAR(10);
  Status VARCHAR(15);
  TotalPages INT(10);
  FormType VARCHAR(10);
  JobName VARCHAR(28);
  DeviceType VARCHAR(10);
  OutputPriority INT(5);
  FileNumber INT(10);
  UserDefinedData VARCHAR(255);

  n_OutputQueueNameIn INT(5);
  n_OutputQueueNameLibraryIn INT(5);
  n_SpooledfileNameIn INT(5);
  n_JobNameIn INT(5);
  n_SpooledFileNumberIn INT(5);

  n_OutputQueueName INT(5);
  n_OutputQueueNameLibrary INT(5);
  n_CreateTimestamp INT(5);
  n_SpooledFileName INT(5);
  n_UserName INT(5);
  n_UserData INT(5);
  n_Status INT(5);
  n_TotalPages INT(5);
  n_FormType INT(5);
  n_JobName INT(5);
  n_DeviceType INT(5);
  n_OutputPriority INT(5);
  n_FileNumber INT(5);
  n_UserDefinedData INT(5);

  State CHAR(5);
  Function VARCHAR(517) CONST;
  Specific VARCHAR(128) CONST;
  ErrorMsg VARCHAR(1000);
  CallType INT(10) CONST;
 END-PI;

 DCL-S InternalOutputQueueName CHAR(10) INZ;
 DCL-S InternalOutputQueueNameLibrary CHAR(10) INZ;
 DCL-S InternalSpooledFileName CHAR(10) INZ;
 DCL-S InternalJobName CHAR(28) INZ;
 DCL-S InternalSpooledFileNumber INT(10) INZ;
 //------------------------------------------------------------------------

  Exec SQL SET OPTION DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     CLOSQLCSR = *ENDACTGRP, USRPRF = *OWNER, DYNUSRPRF = *OWNER,
                     COMMIT = *NONE;

  If ( n_OutputQueueNameIn = PARM_NULL );
    Reset InternalOutputQueueName;
  Else;
    InternalOutputQueueName = OutputQueueNameIN;
  EndIf;

  If ( n_OutputQueueNameLibraryIn = PARM_NULL );
    Reset InternalOutputQueueNameLibrary;
  Else;
    InternalOutputQueueNameLibrary = OutputQueueNameLibraryIn;
  EndIf;

  If ( n_SpooledfileNameIn = PARM_NULL );
    Reset InternalSpooledFileName;
  Else;
    InternalSpooledFileName = SpooledfileNameIn;
  EndIf;

  If ( n_JobNameIn = PARM_NULL );
    Reset InternalJobName;
  Else;
    InternalJobName = JobNameIn;
  EndIf;

  If ( n_SpooledFileNumberIn = PARM_NULL );
    Reset InternalSpooledFileNumber;
  Else;
    InternalSpooledFileNumber = SpooledFileNumberIn;
  EndIf;

  Select;
    When ( CallType = CALL_OPEN );
      openReader(InternalOutputQueueName :InternalOutputQueueNameLibrary
          :InternalSpooledFileName :InternalJobName :InternalSpooledFileNumber);

    When ( CallType = CALL_FETCH );
      fetchNextFromReader(OutputQueueName :OutputQueueNameLibrary :CreateTimestamp
          :SpooledFileName :UserName :UserData :Status :TotalPages :FormType
          :JobName :DeviceType :OutputPriority :FileNumber :UserDefinedData
          :n_OutputQueueName :n_OutputQueueNameLibrary :n_CreateTimestamp
          :n_SpooledFileName :n_UserName :n_UserData :n_Status :n_TotalPages
          :n_FormType :n_JobName :n_DeviceType :n_OutputPriority :n_FileNumber
          :n_UserDefinedData :State :ErrorMsg);

    When ( CallType = CALL_CLOSE );
      closeReader();

  EndSl;

  Return;

END-PROC;

//#########################################################################
DCL-PROC openReader;
 DCL-PI *N;
  OutputQueueName CHAR(10) CONST;
  OutputQueueNameLibrary CHAR(10) CONST;
  SpooledFileName CHAR(10) CONST;
  JobName CHAR(28) CONST;
  SpooledFileNumber INT(10) CONST;
 END-PI;

 DCL-S InternalJobName CHAR(28) INZ;
 //------------------------------------------------------------------------

  Exec SQL DECLARE display_outputqueue_entries_reader CURSOR FOR

           SELECT RTRIM(splf.output_queue_name),
                  RTRIM(splf.output_queue_library_name),
                  splf.create_timestamp,
                  RTRIM(splf.spooled_file_name),
                  RTRIM(splf.user_name),
                  RTRIM(splf.user_data),
                  RTRIM(splf.status),
                  splf.total_pages,
                  RTRIM(splf.form_type),
                  RTRIM(splf.job_name),
                  RTRIM(splf.device_type),
                  splf.output_priority,
                  splf.file_number,
                  IFNULL(jobinf.job_name, ''),
                  IFNULL(jobinf.job_user, ''),
                  DIGITS(CAST(IFNULL(jobinf.job_number, 0) AS DEC(6, 0)))

             FROM qsys2.output_queue_entries splf

             CROSS JOIN TABLE(library.normalize_job_name
                                (in_job => splf.job_name)) as jobinf

            WHERE splf.output_queue_name =
                   CASE WHEN :OutputQueueName = ''
                        THEN splf.output_queue_name
                        ELSE :OutputQueueName END
              AND splf.output_queue_library_name =
                   CASE WHEN :OutputQueueNameLibrary = ''
                        THEN splf.output_queue_library_name
                        ELSE :OutputQueueNameLibrary END
              AND splf.spooled_file_name =
                   CASE WHEN :SpooledFileName = ''
                        THEN splf.spooled_file_name
                        ELSE :SpooledFileName END
              AND splf.output_queue_library_name =
                   CASE WHEN :OutputQueueNameLibrary = ''
                        THEN splf.output_queue_library_name
                        ELSE :OutputQueueNameLibrary END
              AND splf.job_Name =
                   CASE WHEN :JobName = ''
                        THEN splf.job_name
                        ELSE :JobName END
              AND splf.file_number =
                   CASE WHEN :SpooledFileNumber = 0
                        THEN splf.file_number
                        ELSE :SpooledFileNumber END;

  Exec SQL OPEN display_outputqueue_entries_reader;

END-PROC;

//#########################################################################
DCL-PROC fetchNextFromReader;
 DCL-PI *N;
  OutputQueueName VARCHAR(10);
  OutputQueueNameLibrary VARCHAR(10);
  CreateTimestamp TIMESTAMP;
  SpooledFileName VARCHAR(10);
  UserName VARCHAR(10);
  UserData VARCHAR(10);
  Status VARCHAR(15);
  TotalPages INT(10);
  FormType VARCHAR(10);
  JobName VARCHAR(28);
  DeviceType VARCHAR(10);
  OutputPriority INT(5);
  FileNumber INT(10);
  UserDefinedData VARCHAR(255);

  n_OutputQueueName INT(5);
  n_OutputQueueNameLibrary INT(5);
  n_CreateTimestamp INT(5);
  n_SpooledFileName INT(5);
  n_UserName INT(5);
  n_UserData INT(5);
  n_Status INT(5);
  n_TotalPages INT(5);
  n_FormType INT(5);
  n_JobName INT(5);
  n_DeviceType INT(5);
  n_OutputPriority INT(5);
  n_FileNumber INT(5);
  n_UserDefinedData INT(5);

  State CHAR(5);
  ErrorMsg VARCHAR(1000);
 END-PI;

 DCL-DS APIJobNameDS QUALIFIED INZ;
  JobName CHAR(10);
  JobUser CHAR(10);
  JobNumber CHAR(6);
 END-DS;

 DCL-S ErrorValue CHAR(512) INZ;
 //------------------------------------------------------------------------

  Exec SQL FETCH NEXT FROM display_outputqueue_entries_reader
           INTO :OutputQueueName :n_OutputQueueName,
                :OutputQueueNameLibrary :n_OutputQueueNameLibrary,
                :CreateTimestamp :n_CreateTimestamp,
                :SpooledFileName :n_SpooledFileName,
                :UserName :n_UserName, :UserData :n_UserData, :Status :n_Status,
                :TotalPages :n_TotalPages, :FormType :n_FormType,
                :JobName :n_JobName, :DeviceType :n_DeviceType,
                :OutputPriority :n_OutputPriority, :FileNumber :n_FileNumber,
                :APIJobNameDS;

  If ( SQLCode = 100 );
    // Set state for eof
    State = '02000';

  ElseIf ( SQLCode <> 0 ) And ( SQLCode <> 100 );
    // Set stae for error, all of them
    State = '38998';
    Exec SQL GET DIAGNOSTICS CONDITION 1 :ErrorMsg = MESSAGE_TEXT;

  Else;
    // Everything is okay, lets get the spooled file attribute user-defined-data

    QUSRSPLA(F_SPLA0100 :%Size(F_SPLA0100) :'SPLA0100' :APIJobNameDS
        :'' :'' :SpooledFileName :FileNumber :ErrorValue);

    If ( F_SPLA0100.UserDefinedData = '' ) Or ( F_SPLA0100.UserDefinedData = '*NONE' );
      n_UserDefinedData = PARM_NULL;
    Else;
      UserDefinedData = %TrimR(F_SPLA0100.UserDefinedData);
    EndIf;

  EndIf;

END-PROC;

//#########################################################################
DCL-PROC closeReader;

  Exec SQL CLOSE display_outputqueue_entries_reader;

END-PROC;
