**FREE
CTL-OPT Main(Main);

DCL-PR Main EXTPGM('TEST3RG') END-PR;

DCL-PROC Main;

 DCL-PR DspWdwTxt EXTPGM('QUILNGTX');
   ParmText    CHAR(32765) CONST OPTIONS(*VARSIZE);
   ParmLenText INT(10)     CONST;
   ParmMsgId   CHAR(7)     CONST;
   ParmMsgF    CHAR(20)    CONST;
   ParmError   CHAR(256);
 END-PR;

 DCL-S VarText VARCHAR(32765) INZ;
 DCL-S Error   CHAR(256) INZ;
 //-------------------------------------------------------------------------

 VarText = 'This is a sample text to show how it works';

 DspWdwTxt(%TrimR(VarText) :%Len(%TrimR(VarText)) :'' :'' :Error);

 Return;

END-PROC;
