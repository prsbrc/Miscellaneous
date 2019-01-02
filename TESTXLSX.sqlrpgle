**FREE
// Example for libxlsx to create excel sheets direct from rpg

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('LIBXLSX/LIBXLSX') MAIN(Main);


DCL-PR Main EXTPGM('TESTXLSX') END-PR;


/INCLUDE LIBXLSX/QCPYSRC,XLSXWRITER


//------------------------------------------------------------------------------
DCL-PROC Main;

 DCL-S Column INT(10) INZ;

 DCL-DS ExcelOut QUALIFIED INZ;
   Workbook POINTER;
   Worksheet POINTER;
 END-DS;
 DCL-DS ExcelFormat QUALIFIED INZ;
   Numeric POINTER;
   NumericBold POINTER;
   Bold POINTER;
 END-DS;
 DCL-DS ResultDS QUALIFIED INZ;
   Month INT(3);
   Year INT(5);
   Exchange PACKED(9 :2);
 END-DS;

 Exec SQL SET OPTION USRPRF = *OWNER, DYNUSRPRF = *OWNER, CLOSQLCSR = *ENDMOD,
                     DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     COMMIT = *NONE;

 Reset This;

 ExcelOut.Workbook  = Workbook_New('/test/test.xlsx');
 ExcelOut.Worksheet = Workbook_Add_Worksheet(ExcelOut.Workbook :'Sheet1');

 ExcelFormat.Bold = Workbook_Add_Format(ExcelOut.Workbook);
 Format_Set_Bold(ExcelFormat.Bold);

 ExcelFormat.Numeric = Workbook_Add_Format(ExcelOut.Workbook);
 Format_Set_Num_Format(ExcelFormat.Numeric :'#,##0.00');

 ExcelFormat.NumericBold = Workbook_Add_Format(ExcelOut.Workbook);
 Format_Set_Num_Format(Excelformat.NumericBold :'#,##0.00');
 Format_Set_Bold(ExcelFormat.NumericBold);

 WorkSheet_Write_String(ExcelOut.Worksheet :0 :0 :'Month' :ExcelFormat.Bold);
 WorkSheet_Write_String(ExcelOut.Worksheet :0 :1 :'Year' :ExcelFormat.Bold);
 WorkSheet_Write_String(ExcelOut.Worksheet :0 :2 :'Exchange' :ExcelFormat.Bold);

 Exec SQL DECLARE C#MAIN CURSOR FOR
           SELECT MONTH(STAT_DATE), YEAR(STAT_DATE), SUM(STAT_SAPR) FROM STATISTICS
            WHERE YEAR(STAT_DATE) = YEAR(CURRENT DATE) AND STAT_DIVISION = '01'
            GROUP BY MONTH(STAT_DATE), YEAR(STAT_DATE) ORDER BY 1, 2;

 Exec SQL OPEN C#MAIN;

 DoW ( Loop );

   Exec SQL FETCH NEXT FROM C#MAIN INTO :ResultDS;
   If ( SQLCode <> 0 );
     Exec SQL CLOSE C#MAIN;
     Leave;
   EndIf;

   Column += 1;

   Worksheet_Write_Number(ExcelOut.Worksheet :Column :0 :ResultDS.Month :*Null);
   Worksheet_Write_Number(ExcelOut.Worksheet :Column :1 :ResultDS.Year :*Null);
   Worksheet_Write_Number(ExcelOut.Worksheet :Column :2 :ResultDS.Exchange :ExcelFormat.Numeric);

 EndDo;

 Worksheet_Write_String(ExcelOut.Worksheet :Column + 2 :1 :'Total:' :ExcelFormat.Bold);
 Worksheet_Write_Formula(ExcelOut.Worksheet :Column + 2 :2 :'=SUM(C2:C' + %Char(Column + 1) + ')'
                         :ExcelFormat.NumericBold);

 Workbook_Close(ExcelOut.Workbook);

 *INLR = *ON;
 Return;

END-PROC;




