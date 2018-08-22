DCL-PROC DynamicCallExample;
 DCL-PI *N IND;
   pProgramName CHAR(10) CONST;
   pParameters  CHAR(30) CONST;
 END-PI;

 DCL-PR CallProgram EXTPGM(CallDS.ExternalProgram);
   Parameters CHAR(30) CONST OPTIONS(*NOPASS);
 END-PR;
 
 DCL-DS CallDS QUALIFIED INZ;
   ExternalProgram CHAR(10);
 END-DS;

 Reset CallDS;

 CallDS.ExternalProgram = pProgramName;

 Monitor;
   CallProgram(pParameters);
   On-Error;
   // Errorhandling
 EndMon;

END-PROC;