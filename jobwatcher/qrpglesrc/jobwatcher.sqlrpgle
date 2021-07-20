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


/INCLUDE QRPGLEH,JOBWATCHER


//#########################################################################
DCL-PROC Main;

 /INCLUDE QRPGLECPY,SLEEP
//------------------------------------------------------------------------

 /INCLUDE QRPGLECPY,SQLOPTIONS

 *INLR = TRUE;

 DoW Not %ShtDn();
   watchJobsAndAnswerMessagewaits();
   sleep(30);
 EndDo;

 Return;

END-PROC;


//#########################################################################
DCL-PROC watchJobsAndAnswerMessagewaits;

 DCL-DS MessageWaitJobsDS LIKEDS(MSGWJobs_T) INZ;
//------------------------------------------------------------------------

 Exec SQL DECLARE messagewait_reader CURSOR FOR

          WITH message_queue_entries
            (job_name, message_timestamp, message_key) AS
            -- get all inquery messages from qsysopr-message-queue
          (SELECT mq.from_job,
                  mq.message_timestamp,
                  CAST(mq.message_key AS CHAR(4))
             FROM qsys2.message_queue_info mq
            WHERE mq.message_queue_name = 'QSYSOPR'
              AND mq.message_type = 'INQUIRY')

           SELECT jobs.job_name,

                  IFNULL((SELECT joblog.message_id
                              -- get message id from joblog
                            FROM TABLE(qsys2.joblog_info(jobs.job_name)) AS joblog
                           WHERE joblog.message_type = 'SENDER'
                           ORDER BY joblog.ordinal_position DESC LIMIT 1), ''),

                  IFNULL((SELECT msgq.message_key
                              -- get message key for waiting message
                            FROM message_queue_entries msgq
                           WHERE msgq.job_name = jobs.job_name
                           ORDER BY msgq.message_timestamp DESC LIMIT 1), '')

             FROM TABLE(qsys2.active_job_info()) AS jobs

            WHERE jobs.job_status = 'MSGW';

 Exec SQL OPEN messagewait_reader;

 DoW ( 1 = 1 );
   Exec SQL FETCH NEXT FROM messagewait_reader INTO :MessageWaitJobsDS;
   If ( SQLCode <> 0 );
     Exec SQL CLOSE messagewait_reader;
     Leave;
   EndIf;

   If ( MessageWaitJobsDS.MessageKey <> '' );
     answerWithReply(MessageWaitJobsDS);
   EndIf;

 EndDo;

END-PROC;

//#########################################################################
DCL-PROC answerWithReply;
 DCL-PI *N;
  pMessageWaitJobsDS LIKEDS(MSGWJobs_T) CONST;
 END-PI;

 /INCLUDE QRPGLECPY,QMHSNDRM
 /INCLUDE QRPGLECPY,SYSTEM

 DCL-C MESSAGEQUEUE 'QSYSOPR   QSYS';

 DCL-DS ErrorDS LIKEDS(ErrorDS_T);
 DCL-S Reply VARCHAR(10) INZ;
//------------------------------------------------------------------------

 Select;
   When ( pMessageWaitJobsDS.MessageID = 'CPA404D' );
     Reply = 'R';
   When ( pMessageWaitJobsDS.MessageID = 'MSG9900' )
    And ( %Scan('EDIDF2' :pMessageWaitJobsDS.JobName) > 0 );
     Reply = 'R';
 EndSl;

 If ( Reply <> '' );
   sendReplyMessage(%SubSt(pMessageWaitJobsDS.MessageKey :1 :4)
                    :MESSAGEQUEUE
                    :%TrimR(Reply)
                    :%Len(%TrimR(Reply))
                    :'*NO'
                    :ErrorDS);

    If ( ErrorDS.BytesAvailable = 0 );
      sendJobLog('Sending reply "' + %TrimR(Reply) + '" to job "' +
                 %TrimR(pMessageWaitJobsDS.JobName) + '".');
    Else;
      sendJobLog('Error occured while sending reply to job "' +
                 %TrimR(pMessageWaitJobsDS.Jobname) + '".');
    EndIf;

 EndIf;

END-PROC;

//**************************************************************************
DCL-PROC sendJobLog;
 DCL-PI *N;
   pMessage CHAR(256) CONST;
 END-PI;

/INCLUDE QRPGLECPY,QMHSNDPM

 DCL-DS Message LIKEDS(MessageHandling_T) INZ;
 //-------------------------------------------------------------------------

 Message.Length = %Len(%TrimR(pMessage));
 If ( Message.Length >= 0 );
   sendProgramMessage('CPF9897' :CPFMSG :pMessage: Message.Length
                      :'*DIAG'  :'*PGMBDY' :1 :Message.Key :Message.Error);
 EndIf;

END-PROC;

