**FREE
DCL-PR Main EXTPGM('LISTSAMPLE')
  List CONST LIKEDS(List_Template);
END-PR;

DCL-C TRUE *ON;
DCL-C FALSE *OFF;

DCL-DS List_Template QUALIFIED TEMPLATE;
  Count UNS(5);
  Customers CHAR(10) DIM(16);
END-DS;


// #########################################################################
DCL-PROC Main;
 DCL-PI *N;
   pList CONST LIKEDS(List_Template);
 END-PI;

 DCL-S i UNS(5) INZ;
 //-------------------------------------------------------------------------

 For i = 1 To pList.Count;
   // Do something with pList.Customers(i)
 EndFor;

 Return;

END-PROC;
