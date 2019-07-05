**FREE
// Example to show how it can be done
//  Import template, replace vars and create new file with clobs

// Program prototype
DCL-PR Main EXTPGM('CLOB_HTML');
  Company CHAR(3) CONST;
  Division CHAR(3) CONST;
  OrderType CHAR(1) CONST;
  OrderNumber PACKED(5 :0) CONST;
END-PR;

// Prototypes
DCL-PR SendConfirmationMail;
  Company CHAR(3) CONST;
  Division CHAR(3) CONST;
  OrderType CHAR(1) CONST;
  OrderNumber PACKED(5 :0) CONST;
END-PR;

/INCLUDE QRPGLECPY,SYSTEM

// Global constants
DCL-C TMP_PATH '/tmp/';

// Global variables
DCL-S WorkData SQLTYPE(CLOB :32766) CCSID(*JOB) INZ;

// Templates
DCL-DS CustomerInformation_Template QUALIFIED TEMPLATE;
  CustomerNumber CHAR(10);
  Name1 CHAR(30);
  Name2 CHAR(30);
  Street CHAR(30);
  ZipCode CHAR(5);
  City CHAR(30);
  MailAddress CHAR(60);
END-DS;
DCL-DS PositionInformation_Template QUALIFIED TEMPLATE;
  ItemNumber CHAR(10);
  ItemDescription CHAR(30);
  SalesUnit CHAR(3);
  Content PACKED(5 :2);
  DetailUnit CHAR(3);
  Quantity PACKED(9 :2);
END-DS;
DCL-DS CompanyInformation_Template QUALIFIED TEMPLATE;
  Name1 CHAR(30);
  Name2 CHAR(30);
  Street CHAR(30);
  ZipCodeCity CHAR(30);
  Phone CHAR(30);
  OriginType CHAR(3);
  User CHAR(10);
  CreationDate DATE;
END-DS;


//*************************************************************************
DCL-PROC Main;
 DCL-PI *N;
   pCompany CHAR(3) CONST;
   pDivision CHAR(3) CONST;
   pOrderType CHAR(1) CONST;
   pOrderNumber PACKED(5 :0) CONST;
 END-PI;

 Exec SQL SET OPTION USRPRF = *OWNER, DYNUSRPRF = *OWNER, CLOSQLCSR = *ENDMOD,
                     DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     COMMIT = *CS;
 Reset This;

 SendConfirmationMail(pCompany :pDivision :pOrderType :pOrderNumber);
 Exec SQL COMMIT;

 *INLR = TRUE;
 Return;

END-PROC;

//*************************************************************************
DCL-PROC SendConfirmationMail;
 DCL-PI *N;
   pCompany CHAR(3) CONST;
   pDivision CHAR(3) CONST;
   pOrderType CHAR(1) CONST;
   pOrderNumber PACKED(5 :0) CONST;
 END-PI;

 DCL-PR SendMail EXTPGM('SENDPGM');
   MailAccount CHAR(20) CONST;
   Subject CHAR(60) CONST;
   FilePath CHAR(128) CONST;
   MailAddress CHAR(60) CONST;
   Success IND;
 END-PR;

 DCL-S Success IND INZ(FALSE);
 DCL-S MailAccount CHAR(20) INZ;
 DCL-S Subject CHAR(60) INZ;
 DCL-S Template_Path CHAR(128) INZ;
 DCL-S Confirmation_Path CHAR(128) INZ;
 DCL-S ItemLines VARCHAR(32766) INZ;
 DCL-S ConfirmationFile SQLTYPE(CLOB_FILE) CCSID(*UTF8) INZ;

 DCL-DS CustomerInformation LIKEDS(CustomerInformation_Template) INZ;
 DCL-DS CompanyInformation LIKEDS(CompanyInformation_Template) INZ;
 DCL-DS PositionInformation LIKEDS(PositionInformation_Template) INZ;

 DCL-C BEGIN '<tr><td align="center">';
 DCL-C END '</td></tr>';
 DCL-C CELL_CENTER '</td><td align="center">';
 DCL-C CELL_LEFT '</td><td align="left">';
 DCL-C CELL_RIGHT '</td><td align="right">';
 DCL-C FONT_BEGIN '<font face="Arial" size="3">';
 DCL-C FONT_END '</font>';
 DCL-C SPACE ' ';
//-------------------------------------------------------------------------

 // Type here your sql-statement to fetch your information and the customers one

 If ( SQLCode = 0 ) And ( CustomerInformation.MailAddress <> '' );

   Template_Path = '/Templates/OrderConfirmationTemplate.html';
   Exec SQL SET :WorkData = GET_CLOB_FROM_FILE(TRIM(:Template_Path));
   If ( SQLCode = 0 );
     // Replace your data
     WorkData_Data = %ScanRpl('&&HEAD1;' :%TrimR(CompanyInformation.Name1) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&HEAD2;' :%TrimR(CompanyInformation.Name2) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&HEAD3;' :%TrimR(CompanyInformation.Street) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&HEAD4;' :%TrimR(CompanyInformation.ZipCodeCity) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&HEAD5;' :%TrimR(CompanyInformation.Phone) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&DATE;' :%Char(CompanyInformation.CreationDate :*EUR.)
                                        :WorkData_Data);
     WorkData_Data = %ScanRpl('&&USER;' :%TrimR(CompanyInformation.User) :WorkData_Data);

     // Replace customerdata
     WorkData_Data = %ScanRpl('&&COMPANY;' :%TrimR(pCompany) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&DIVISION;' :%TrimR(pDivision) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&CUSTOMERNUMBER;' :%TrimR(CustomerInformation.CustomerNumber)
                                                  :WorkData_Data);
     WorkData_Data = %ScanRpl('&&NAME1;' :%TrimR(CustomerInformation.Name1) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&NAME2;' :%TrimR(CustomerInformation.Name2) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&STREET;' :%TrimR(CustomerInformation.Street) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&ZIP;' :%TrimR(CustomerInformation.ZipCode) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&CITY;' :%TrimR(CustomerInformation.City) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&ORDERNUMBER;' :%Char(pOrderNumber) :WorkData_Data);

     // Replace date and time
     WorkData_Data = %ScanRpl('&&SNDDATE;' :%Char(%Date() :*EUR.) :WorkData_Data);
     WorkData_Data = %ScanRpl('&&TIME;' :%Char(%Time() :*HMS:) :WorkData_Data);

     // Positions
     Clear ItemLines;
     Exec SQL DECLARE C#POSITIONS SCROLL CURSOR FOR
               // Type here to fetch your positions
     Exec SQL OPEN C#POSITIONS;
     DoW ( Loop );
       Exec SQL FETCH NEXT FROM C#POSITIONS INTO :PositionInformation;
       If ( SQLCode <> stsOK );
         Exec SQL CLOSE C#POSITIONS;
         Leave;
       EndIf;
       ItemLines = %TrimR(ItemLines) + BEGIN +
                   FONT_BEGIN + %TrimR(PositionInformation.ItemNumber) + FONT_END + CELL_LEFT +
                   FONT_BEGIN + %TrimR(PositionInformation.ItemDescription) + FONT_END +
                   CELL_CENTER +
                   FONT_BEGIN + %TrimR(PositionInformation.SalesUnit) + SPACE +
                                %Char(PositionInformation.Content) + SPACE +
                                %TrimR(PositionInformation.DetailUnit) + FONT_END + CELL_RIGHT +
                   FONT_BEGIN + %Char(PositionInformation.Quantity) + FONT_END + END;
     EndDo;

     WorkData_Data = %ScanRpl('&&ITEMS;' :%TrimR(ItemLines) :WorkData_Data);

     If ( ItemLines <> '' );
       // HTML-like style
       WorkData_Data = %ScanRpl('&' :'&amp;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ä' :'&auml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('Ä' :'&Auml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ö' :'&ouml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('Ö' :'&Ouml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ü' :'&uuml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('Ü' :'&Uuml;' :WorkData_Data);
       WorkData_Data = %ScanRpl('à' :'&agrave;' :WorkData_Data);
       WorkData_Data = %ScanRpl('á' :'&aacute;' :WorkData_Data);
       WorkData_Data = %ScanRpl('è' :'&egrave;' :WorkData_Data);
       WorkData_Data = %ScanRpl('é' :'&eacute;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ò' :'&ograve;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ó' :'&oacute;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ù' :'&ugrave;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ú' :'&uacute;' :WorkData_Data);
       WorkData_Data = %ScanRpl('ß' :'&szlig;' :WorkData_Data);

       // Create file and send it
       Confirmation_Path = TMP_PATH + %TrimR(pCompany) + '_' + %TrimR(pDivision) + '_' +
                           %Char(pOrderNumber) + '.html';
       ConfirmationFile_Name = Confirmation_Path;
       ConfirmationFile_NL   = %Len(%TrimR(Confirmation_Path));
       ConfirmationFile_FO   = SQFOVR;
       WorkData_Len = %Len(%TrimR(WorkData_Data));
       Exec SQL SET :ConfirmationFile = CAST(:WorkData AS CLOB(32766) CCSID 1208);
       If ( SQLCode = 0 );
         MailAccount = 'xxxx' + 'yyyyyy';
         Subject = 'Orderconfirmation - ' + CompanyInformation.Name1;
         SendMail(MailAccount :Subject :Confirmation_Path 
		          :CustomerInformation.MailAddress :Success);
       EndIf;
     EndIf;
   EndIf;
 EndIf;

END-PROC;