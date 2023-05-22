**FREE
CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES)
        USRPRF(*OWNER) MAIN(Main);


DCL-PR Main EXTPGM('TESTTRGRG');
 TriggerParm1 LIKEDS(TriggerParm1_T);
 TriggerParm2 LIKEDS(TriggerParm2_T);
END-PR;


DCL-DS TriggerParm1_T QUALIFIED TEMPLATE;
 FileName CHAR(10);
 LibraryName CHAR(10);
 MemberName CHAR(10);
 Event CHAR(1);
 TriggerTime CHAR(1);
 CommitLockLevel CHAR(1);
 *N CHAR(3);
 TriggerCCSID INT(10);
 *N INT(10);
 *N CHAR(4);
 BeforeRecordOffset INT(10);
 BeforeRecordLength INT(10);
 BeforeNullOffset INT(10);
 BeforeNullLength INT(10);
 AfterRecordOffset INT(10);
 AfterRecordLength INT(10);
 AfterNullOffset INT(10);
 AfterNullLength INT(10);
END-DS;

DCL-DS TriggerParm2_T QUALIFIED TEMPLATE;
 ParameterLength INT(10);
END-DS;

DCL-C EVENT_INSERT '1';
DCL-C EVENT_DELETE '2';
DCL-C EVENT_UPDATE '3';
DCL-C EVENT_READ '4';

DCL-C TIME_AFTER '1';
DCL-C TIME_BEFORE '2';

DCL-C COMMIT_NONE '0';
DCL-C COMMIT_CHANGE '1';
DCL-C COMMIT_CS '2';
DCL-C COMMIT_ALL '3';


//--------------------------------------
DCL-PROC Main;
 DCL-PI *N;
  pTriggerParm1 LIKEDS(TriggerParm1_T);
  pTriggerParm2 LIKEDS(TriggerParm2_T);
 END-PI;

 DCL-S BeforeBufferPointer POINTER INZ;
 DCL-S AfterBufferPointer POINTER INZ;
 DCL-DS BeforeRecord EXTNAME('TESTTRG') QUALIFIED BASED(BeforeBufferPointer) END-DS;
 DCL-DS AfterRecord EXTNAME('TESTTRG') QUALIFIED BASED(AfterBufferPointer) END-DS;

 BeforeBufferPointer = %Addr(pTriggerParm1) + pTriggerParm1.BeforeRecordOffset;
 AfterBufferPointer = %Addr(pTriggerParm1) + pTriggerParm1.AfterRecordOffset;

 Return;

END-PROC;