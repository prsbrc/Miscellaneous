**free
/if defined (rtvsplfarg_h)
/eof
/endif

/define rtvsplfarg_h

CTL-OPT ALWNULL(*USRCTL) DATFMT(*ISO-) TIMFMT(*ISO.) DEBUG(*YES) NOMAIN;

DCL-C CALL_OPEN -1;
DCL-C CALL_FETCH 0;
DCL-C CALL_CLOSE 1;
DCL-C PARM_NULL -1;
DCL-C PARM_NOTNULL 0;

DCL-PR QUSRSPLA EXTPGM('QUSRSPLA');
 Receiver CHAR(32767) OPTIONS(*VARSIZE);
 LengthReceiver INT(10) CONST;
 Format CHAR(8) CONST;
 JobName LIKEDS(APIJobNameDS) CONST;
 InternalJob CHAR(16) CONST;
 InternalSpoolFileNumber CHAR(16) CONST;
 SpooledFileName CHAR(10) CONST;
 FileNumber INT(10) CONST;
 ErrorCode CHAR(32767) OPTIONS(*VARSIZE);
END-PR;

DCL-DS F_SPLA0100 QUALIFIED INZ;
 Filler CHAR(1156) POS(1);
 UserDefinedData CHAR(255) POS(1157);
END-DS;
