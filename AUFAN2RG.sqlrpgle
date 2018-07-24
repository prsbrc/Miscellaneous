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

// 00000000 BRC 24.07.2018


/INCLUDE QRPGLECPY,CPY2018
/INCLUDE QRPGLECPY,H_SPECS

// Dateien
DCL-F AUFAN2DF WORKSTN INFDS(WSDS) INDDS(INDDS) MAXDEV(*FILE) SFILE(AUFAN2AS :RECNUM) USROPN;


// Programmstatusdatenstruktur
/INCLUDE QRPGLECPY,PSDS
/INCLUDE QRPGLECPY,WSDS
DCL-DS INDDS QUALIFIED;
  SubfileClear IND POS(20);
  SubfileDisplayControl IND POS(21);
  SubfileDisplay IND POS(22);
  SubfileMore IND POS(23);
END-DS;


// Prototypes
DCL-PR Main EXTPGM('AUFAN2RG');
  Seconds PACKED(2 :0) CONST;
END-PR;

DCL-PR LoopFM_A;
  Seconds PACKED(2 :0) CONST;
END-PR;
DCL-PR FetchRecords END-PR;


// Inportierted prototypes
/INCLUDE QRPGLECPY,SYSTEM


// Global contants
/INCLUDE QRPGLECPY,CONSTKEYS
/INCLUDE QRPGLECPY,BOOLIC
/INCLUDE QRPGLECPY,SQLDEF
DCL-C FM_A   'A';
DCL-C FM_End '*';
DCL-C MAXROWS 60;
DCL-C COLOR_RED x'28';
DCL-C COLOR_YELLOW x'32';
DCL-C COLOR_GREEN x'20';


// Global variables
DCL-S RecNum UNS(10) INZ;
DCL-DS This QUALIFIED;
  PictureControl CHAR(1) INZ(FM_A);
  RecordsFound   UNS(3)  INZ;
END-DS;


//#########################################################################
// Main-Loop
//#########################################################################
DCL-PROC Main;
 DCL-PI *N;
   pSeconds PACKED(2 :0) CONST;
 END-PI;

 Reset This;
 Reset RecNum;
 System('CRTDTAQ DTAQ(QTEMP/AUFAN2) MAXLEN(80)');
 System('OVRDSPF FILE(AUFAN2DF) OVRSCOPE(*ACTGRPDFN) DTAQ(QTEMP/AUFAN2)');

 If Not %Open(AUFAN2DF);
   Open AUFAN2DF;
 EndIf;

 DoU ( This.PictureControl = FM_End );
   Select;
     When ( This.PictureControl = FM_A );
       LoopFM_A(pSeconds);
     Other;
       This.PictureControl = FM_End;
   EndSl;
 EndDo;

 If %Open(AUFAN2DF);
   Close AUFAN2DF;
 EndIf;

 System('DLTOVR FILE(AUFAN2DF) LVL(*ACTGRPDFN)');
 System('DLTDTAQ DTAQ(QTEMP/AUFAN2)');

 Return;

END-PROC;


//#########################################################################
// Picture A Loop
//#########################################################################
DCL-PROC LoopFM_A;
 DCL-PI *N;
   pSeconds PACKED(2 :0) CONST;
 END-PI;

 /INCLUDE QRPGLECPY,QRCVDTAQ

 DCL-S QueueData CHAR(80) INZ;
//-------------------------------------------------------------------------

 ACCRow  = 4;
 ACCCol  = 2;
 AFLin01 = 'Autorefresh: ' + %Char(pSeconds);

 FetchRecords();

 DoU ( This.PictureControl = FM_End );

   Write AUFAN2AF;
   Write AUFAN2AC;

   RecieveDataQueue('AUFAN2' :'QTEMP' :%Len(QueueData) :QueueData :pSeconds);

   If ( QueueData = '' );
     FetchRecords();
     Iter;
   EndIf;

   Clear QueueData;

   Read(E) AUFAN2DF;

   Select;
     When ( WSDS.KeyPressed = KeyF03 );
       This.PictureControl  = FM_End;
     When ( WSDS.KeyPressed = KeyF05 );
       FetchRecords();
   EndSl;

 EndDo;


END-PROC;

//#########################################################################
// Read data
//#########################################################################
DCL-PROC FetchRecords;

 DCL-S i UNS(3) INZ;
 DCL-S Percent PACKED(5 :2) INZ;

 DCL-DS FetchDS QUALIFIED DIM(MAXROWS) INZ;
   Customernumber CHAR(10);
   Customername   CHAR(30);
   Customercity   CHAR(30);
   Ordernumber    PACKED(5 :0);
   Stockdate      PACKED(8 :0);
   Tour           CHAR(4);
   Box            CHAR(3);
   AllItems       INT(5);
   Finished       INT(5);
   OpenItems      INT(5);
   WorkUser       CHAR(10);
 END-DS;
 DCL-DS DisplayLine QUALIFIED INZ;
   Customernumber CHAR(10) POS( 1);
   Customername   CHAR(30) POS(11);
   Customercity   CHAR(20) POS(43);
   Ordernumber    CHAR(5)  POS(67);
   Stockdate      CHAR(10) POS(74);
   Tour           CHAR(4)  POS(86);
   Box            CHAR(2)  POS(91);
   AllItems       CHAR(5)  POS(96);
   Finished       CHAR(5)  POS(106);
   Colorcontrol   CHAR(1)  POS(114);
   OpenItems      CHAR(5)  POS(115);
   Colorreset     CHAR(1)  POS(120);
   WorkUser       CHAR(10) POS(121);
 END-DS;
//-------------------------------------------------------------------------

 Reset RecNum;

 INDDS.SubfileClear = TRUE;
 INDDS.SubfileDisplayControl = TRUE;
 INDDS.SubfileDisplay = FALSE;
 INDDS.SubfileMore = FALSE;
 Write(E) AUFAN2AC;

 Exec SQL DECLARE C#MAIN CURSOR FOR
            WITH POS AS
                 (SELECT AA0FAK, AA0AUA, AA0KNR, AA0AUN, COUNT(*) GESAMT,
                         SUM(CASE WHEN AA0ST4 = 'N' THEN 1 ELSE 0 END) ERLEDIGT,
                         SUM(CASE WHEN AA0ST4 = ''  THEN 1 ELSE 0 END) OFFEN,
                         MAX(CASE WHEN LEFT(AA0USR, 2) = 'FK' THEN AA0USR ELSE '' END) FK_USER
                    FROM AA0 WHERE AA0AUA = 'K' AND AA0AUZ > 0 AND AA0AUP = 'A'
                   GROUP BY AA0FAK, AA0AUA, AA0KNR, AA0AUN)
          SELECT H.AA0KNR, K.K00NA2, K.K00ORT, H.AA0AUN, H.AA0DA2,
                 H.AA0TO1, H.AA0BOX, P.GESAMT, P.ERLEDIGT, P.OFFEN, P.FK_USER
            FROM AA0 H
            JOIN POS P ON (P.AA0FAK = H.AA0FAK AND P.AA0AUA = H.AA0AUA AND
                           P.AA0AUN = H.AA0AUN AND P.AA0KNR = H.AA0KNR)
            JOIN K00 K ON (K.K00FAK = H.AA0FAK AND K.K00KNR = H.AA0KNR)
           WHERE H.AA0AUA = 'K' AND H.AA0AUZ = 0 AND H.AA0AUP = 'A' AND H.AA0ST7 = '1'
           ORDER BY CASE WHEN P.GESAMT = 0 THEN 100 WHEN P.GESAMT = P.ERLEDIGT THEN 100
                         WHEN P.ERLEDIGT = 0 THEN 0
                         ELSE ROUND(DEC(P.ERLEDIGT, 35, 5) / (DEC(P.GESAMT, 35, 5) / 100), 2)
                     END, P.GESAMT DESC, P.OFFEN, P.ERLEDIGT, H.AA0KNR
           FETCH FIRST 60 ROWS ONLY;

 Exec SQL OPEN C#MAIN;

 Exec SQL FETCH FROM C#MAIN FOR 60 ROWS INTO :FetchDS;
 This.RecordsFound = SQLEr3;

 Exec SQL CLOSE C#MAIN;

 INDDS.SubfileClear = FALSE;
 INDDS.SubfileDisplayControl = TRUE;
 INDDS.SubfileDisplay = TRUE;
 INDDS.SubfileMore = TRUE;

 If ( This.RecordsFound > 0 );

   For i = 1 To This.RecordsFound;

     DisplayLine.Customernumber = FetchDS(i).Customernumber;
     DisplayLine.Customername = FetchDS(i).Customername;
     DisplayLine.Customercity = FetchDS(i).Customercity;
     EvalR DisplayLine.Ordernumber = %Char(FetchDS(i).Ordernumber);
     DisplayLine.Stockdate = %EditW(FetchDS(i).Stockdate :'    .  .  ');
     DisplayLine.Tour = FetchDS(i).Tour;
     DisplayLine.Box = FetchDS(i).Box;
     EvalR DisplayLine.AllItems = %Char(FetchDS(i).AllItems);
     EvalR DisplayLine.Finished = %Char(FetchDS(i).Finished);
     EvalR DisplayLine.OpenItems = %Char(FetchDS(i).OpenItems);
     DisplayLine.WorkUser = FetchDS(i).WorkUser;

     If ( FetchDS(i).Finished = 0 );
       DisplayLine.Colorcontrol = COLOR_RED;
     ElseIf ( FetchDS(i).AllItems = FetchDS(i).Finished );
       DisplayLine.Colorcontrol = COLOR_GREEN;
     Else;
       Percent = %DecH(FetchDS(i).Finished / (FetchDS(i).AllItems / 100) :5 :2);
       If ( Percent <= 10 );
         DisplayLine.Colorcontrol = COLOR_RED;
       ElseIf ( Percent > 10 ) And ( Percent <= 70 );
         DisplayLine.Colorcontrol = COLOR_YELLOW;
       Else;
         DisplayLine.Colorcontrol = COLOR_GREEN;
       EndIf;
     EndIf;

     DisplayLine.Colorreset = COLOR_GREEN;

     RecNum += 1;
     ASLine =  DisplayLine;
     ASRecN =  RecNum;
     Write AUFAN2AS;

   EndFor;

   If ( CurCur > 0 ) And ( CurCur <= RecNum );
     RecNum = CurCur;
   Else;
     RecNum = 1;
   EndIf;

 Else;

   RecNum = 1;
   ASRecN = RecNum;
   ASLine = '';
   Write AUFAN2AS;

 EndIf;

END-PROC;
