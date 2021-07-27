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

// CRTSRVPGM SRVPGM(BRUNNER/CUSTOMERS) MODULE(BRUNNER/CUSTOMERS) EXPORT(*ALL)

CTL-OPT ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES) NOMAIN;


//---
DCL-PROC cust EXPORT;
 DCL-PI *N;
  CustomerNumber CHAR(10) CONST;
  CustomerName1 VARCHAR(30);
  CustomerName2 VARCHAR(30);
  n_CustomerNumber INT(5);
  n_CustomerName1 INT(5);
  n_CustomerName2 INT(5);
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

 DCL-S InternalCustomerNumber CHAR(10) INZ;

 Exec SQL SET OPTION DATFMT = *ISO, DATSEP = '-', TIMFMT = *ISO, TIMSEP = '.',
                     CLOSQLCSR = *ENDACTGRP, USRPRF = *OWNER, DYNUSRPRF = *OWNER,
                     COMMIT = *NONE;

 If ( n_CustomerNumber = PARM_NULL );
   Reset InternalCustomerNumber;
 Else;
   InternalCustomerNumber = CustomerNumber;
 EndIf;

 Select;
   When ( CallType = CALL_OPEN );
     openReader(InternalCustomerNumber);

   When ( CallType = CALL_FETCH );
     fetchNextFromReader(CustomerName1 :CustomerName2 :State :ErrorMsg);

   When ( CallType = CALL_CLOSE );
     closeReader();

 EndSl;

 Return;

END-PROC;

//---
DCL-PROC openReader;
 DCL-PI *N;
  CustomerNumber CHAR(10) CONST;
 END-PI;

 Exec SQL DECLARE customer_fetcher CURSOR FOR
           SELECT custname1, custname2 FROM tst_customers
            WHERE custcompany = 'WED' AND custdivision = '03' AND custdelcode = ''
              AND custnumber = CASE WHEN :CustomerNumber = '' THEN custnumber
                                    ELSE :CustomerNumber END;

 Exec SQL OPEN customer_fetcher;

END-PROC;

//---
DCL-PROC fetchNextFromReader;
 DCL-PI *N;
  CustomerName1 VARCHAR(30);
  CustomerName2 VARCHAR(30);
  State CHAR(5);
  ErrorMsg VARCHAR(1000);
 END-PI;

 Exec SQL FETCH NEXT FROM customer_fetcher INTO :CustomerName1, :CustomerName2;
 If ( SQLCode = 100 );
   State = '02000';
 ElseIf ( SQLCode <> 0 ) And ( SQLCode <> 100 );
   State = '38998';
   Exec SQL GET DIAGNOSTICS CONDITION 1 :ErrorMsg = MESSAGE_TEXT;
 EndIf;

END-PROC;

//---
DCL-PROC closeReader;

 Exec SQL CLOSE customer_fetcher;

END-PROC;
