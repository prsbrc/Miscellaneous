**FREE

// Triggerexample
//  Table IMPORT_H -> Trigger IMPORT (Update h_sts = 1) -> DTAQ -> IMPORTRG

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) MAIN(Main);

DCL-PR Main EXTPGM('IMPORTRG');
 WaitingTime CHAR(10) OPTIONS(*NOPASS) CONST;
END-PR;

/INCLUDE QRPGLECPY,QRCVDTAQ

//#############################################################################
DCL-PROC Main;
 DCL-PI *N;
  pWaitingTime CHAR(10) OPTIONS(*NOPASS) CONST;
 END-PI;

 DCL-S ImportID INT(20) INZ(-1);
 DCL-S WaitingTime INT(10) INZ(10);
 DCL-DS IncomingData QUALIFIED INZ;
  Length PACKED(5 :0);
  Data CHAR(80);
 END-DS;
 //----------------------------------------------------------------------------

 Exec SQL SET OPTION DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     CLOSQLCSR = *ENDACTGRP, USRPRF = *OWNER, DYNUSRPRF = *OWNER,
                     COMMIT = *NONE;

 *INLR = *ON;

 If ( %Parms() > 0 );
   Monitor;
     WaitingTime = %Int(%Trim(pWaitingTime));
     On-Error;
       Reset WaitingTime;
   EndMon;
 EndIf;

 DoW (1 = 1);

   // Waiting for imcoming ID to do some work
   receiveDataQueue('IMPORT_H' :'LIBRARY' :IncomingData.Length :IncomingData.Data :WaitingTime);

   If ( IncomingData.Data = '' );
     // Timeout
     Iter;
   EndIf;

   If ( IncomingData.Data = '*EXIT' );
     // Exit program
     Leave;
   Else;
     // Try to convert incoming data to integer
     Monitor;
       ImportID = %Int(%Trim(IncomingData.Data));
       On-Error;
         Reset ImportID;  // -1
     EndMon;
   EndIf;

   If ( ImportID > -1 );
     // Update import_h-record with given ID
     Exec SQL UPDATE library.import_h header
                 SET header.h_sts = 2,
                     header.h_ghp = CURRENT_TIMESTAMP,
                     header.h_usr = SESSION_USER
               WHERE header.h_id = :ImportID AND header.h_sts = 1;
   EndIf;

   Clear IncomingData;

 EndDo;

 Return;

END-PROC;


// Create dataqueue
//======================================================
//CRTDTAQ DTAQ(LIBRARY/IMPORT_H) MAXLEN(80)

// Tabledefinition
//======================================================
//CREATE OR REPLACE TABLE library.import_h (
//      h_id BIGINT GENERATED ALWAYS AS IDENTITY (
//        START WITH 0 INCREMENT BY 1
//        NO MINVALUE NO MAXVALUE
//        NO CYCLE NO ORDER
//        NO CACHE ),
//      h_knr CHAR(10) CCSID 1141 NOT NULL ,
//      h_sts SMALLINT DEFAULT NULL ,
//      h_dau TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//      h_ghp TIMESTAMP DEFAULT NULL ,
//      h_usr VARCHAR(128) ALLOCATE(6) CCSID 1141 DEFAULT USER )
//      RCDFMT import_h;


// Triggerdefinition
//======================================================
//CREATE OR REPLACE TRIGGER library.import
//        AFTER UPDATE OF h_sts ON library.import_h
//        REFERENCING OLD AS old_import NEW AS new_import
//         FOR EACH ROW MODE DB2SQL
//    WHEN (old_import.h_sts IS NULL AND new_import.h_sts = 1 )
// BEGIN ATOMIC
//   CALL QSYS2.SEND_DATA_QUEUE(MESSAGE_DATA => DIGITS(old_import.i_id),
//                               DATA_QUEUE => 'IMPORT_H',
//                               DATA_QUEUE_LIBRARY => 'LIBRARY');
// END;
