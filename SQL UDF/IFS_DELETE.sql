/*
COPYRIGHT (c)2021 Christian Brunner

Delete / Remove object link from ifs

Incoming Parameter:
 - Path to object to be removed
 
Returns 0 by success and -1 due failure
*/

CREATE or replace FUNCTION yourlib.ifs_delete
( 
	ifs_path VARCHAR(32000) DEFAULT  NULL
)

RETURNS SMALLINT   

LANGUAGE SQL 
SPECIFIC yourlib.ifs_dlt 
DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
NO EXTERNAL ACTION 
ALLOW PARALLEL

BEGIN 
  
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION RETURN - 1; 
  
 CALL QCMDEXC ( 'RMVLNK OBJLNK(' CONCAT '''' CONCAT TRIM ( ifs_path ) CONCAT '''' CONCAT ')' ); 
  
 RETURN 0; 
  
END; 
  
COMMENT ON PARAMETER SPECIFIC FUNCTION yourlib.ifs_dlt 
( ifs_path IS 'Path to the object' ) ; 
  
LABEL ON SPECIFIC FUNCTION yourlib.ifs_dlt IS 'Delete or remove ifs file' ; 
