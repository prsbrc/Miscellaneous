CREATE OR REPLACE FUNCTION BRUNNER.COPY_SPOOLEDFILE_TO_PDF
( 
    PARM_SPOOL_NAME VARCHAR(10),
    PARM_JOB_NAME VARCHAR(28),
    PARM_FILE_NUMBER INTEGER,
    PARM_TO_PATH VARCHAR(1024)
)

RETURNS INTEGER

LANGUAGE SQL
SPECIFIC BRUNNER.CPYSPLFPDF
DETERMINISTIC
MODIFIES SQL DATA
CALLED ON NULL INPUT

SET OPTION
 COMMIT = *NONE,
 DBGVIEW = *SOURCE,
 DYNUSRPRF = *OWNER

BEGIN
 DECLARE COMMAND_STRING VARCHAR(2048);
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION RETURN -1;

 SET COMMAND_STRING = 'CPYSPLF FILE(' CONCAT RTRIM(PARM_SPOOL_NAME) CONCAT ') TOFILE(*TOSTMF) JOB(' CONCAT RTRIM(PARM_JOB_NAME) 
                        CONCAT ') SPLNBR(' CONCAT CHAR(PARM_FILE_NUMBER) CONCAT ') TOSTMF('
                        CONCAT '''' CONCAT RTRIM(PARM_TO_PATH) CONCAT '''' CONCAT ') WSCST(*PDF) STMFOPT(*REPLACE)';

 CALL QCMDEXC(COMMAND_STRING);

 RETURN 0;

END;

COMMENT ON PARAMETER SPECIFIC FUNCTION BRUNNER.CPYSPLFPDF
( 
    PARM_SPOOL_NAME IS 'Spoolfile name',
    PARM_JOB_NAME IS 'Job name',
    PARM_FILE_NUMBER IS 'Spoolfile number',
    PARM_TO_PATH IS 'Target path'
);

LABEL ON SPECIFIC FUNCTION BRUNNER.CPYSPLFPDF IS 'Copy spooled file to pdf';



--EXAMPLE: Copy all spooled files from current user to ifs path /tmp
--SELECT BRUNNER.COPY_SPOOLEDFILE_TO_PDF(
--  SPOOLED_FILE_NAME,        
--  JOB_NAME, 
--  FILE_NUMBER, 
--  '/tmp/' CONCAT RTRIM(SPOOLED_FILE_NAME) CONCAT DIGITS(FILE_NUMBER) CONCAT '.pdf')
--FROM QSYS2.OUTPUT_QUEUE_ENTRIES
--WHERE USER_NAME = USER                 