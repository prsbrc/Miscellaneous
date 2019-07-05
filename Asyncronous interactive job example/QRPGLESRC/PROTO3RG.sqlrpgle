**FREE
//- Copyright (c) 2019 Christian Brunner
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


// This program read the wanted data and hit this data back to the previous program

CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) MAIN(Main);


DCL-PR Main EXTPGM('PROTO3RG');
  Parameter LIKEDS(Parameters_Template);
END-PR;


DCL-DS Parameters_Template TEMPLATE QUALIFIED;
  InParameter CHAR(100) DIM(20);
  OutParameter CHAR(130) DIM(27);
END-DS;


DCL-PROC Main;
  DCL-PI *N;
    pParameters LIKEDS(Parameters_Template);
  END-PI;

  DCL-S CustomerNumber CHAR(10) INZ;
  DCL-S CustomerName CHAR(60) INZ;
  DCL-S AddressStreet CHAR(30) INZ;
  DCL-S AddressZIP CHAR(6) INZ;
  DCL-S AddressCity CHAR(30) INZ;
  DCL-S AddressCountry CHAR(3) INZ;
  DCL-S ItemNumber CHAR(10) INZ;
  DCL-S ItemDescription CHAR(30) INZ;
  DCL-S StockQuantity PACKED(9 :2) INZ;
//*----

  CustomerNumber = pParameters.InParameter(1);
  ItemNumber = pParameters.InParameter(2);
  Clear pParameters.OutParameter;

  pParameters.OutParameter(01) = 'Kundendaten ------------------------------------------';
  Exec SQL SELECT CUNO, CUNA1 CONCAT CUNA2, STREET, ZIP, CITY, COUNTRY
             INTO :CustomerNumber, :CustomerName, :AddressStreet,
                  :AddressZIP, :AddressCity, :AddressCountry
             FROM Schema.CustomerData
            WHERE CONO = 'BRC' AND CUNO = :CustomerNumber
            LIMIT 1;
  If ( SQLCode = 0 );
    pParameters.OutParameter(02) = 'Kundennummer.: ' + x'22' + %TrimR(CustomerNumber) + x'20';
    pParameters.OutParameter(03) = 'Kundenname...: ' + x'22' + %TrimR(CustomerName) + x'20';
    pParameters.OutParameter(04) = 'Strasse......: ' + x'22' + %TrimR(AddressStreet) + x'20';
    pParameters.OutParameter(05) = 'Plz/Ort......: ' + x'22' + AddressZIP + ' ' + 
                                 %TrimR(AddressCity) + x'20';
    pParameters.OutParameter(06) = 'Land.........: ' + x'22' + %TrimR(AddressCountry) + x'20';
  EndIf;

  pParameters.OutParameter(08) = 'Artikeldaten -----------------------------------------';
  If ( ItemNumber <> '' );
    Exec SQL SELECT A.ITNO, A.ITDS, IFNULL(B.QUTY, 0)
               INTO :ItemNumber, :ItemDescription, :StockQuantity
               FROM Schema.ItemBase A LEFT JOIN Schema.Stock B ON (B.CONO = A.CONO AND B.STNO = '01' AND B.ITNO = A.ITNO)
              WHERE A.CONO = 'BRC' AND A.ITNO = :ItemNumber;
    If ( SQLCode = 0 );
      pParameters.OutParameter(09) = 'Artikelnummer: ' + x'22' + %TrimR(ItemNumber) + x'20';
      pParameters.OutParameter(10) = 'Bezeichnung..: ' + x'22' + %TrimR(ItemDescription) + x'20';
      pParameters.OutParameter(11) = 'Bestand......: ' + x'22' + %Char(StockQuantity) + x'20';
    EndIf;
  EndIf;

  *INLR = *ON;
  Return;

End-Proc;
