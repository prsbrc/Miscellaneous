/*
COPYRIGHT (c)2025 Christian Brunner

Returns filename from given path

Incoming Parameter:
 - Path
 
Returns filename
*/

CREATE OR REPLACE FUNCTION youtlib.extractFileNameFromPath
(
    in_path_name varchar(30000)
)

 returns varchar(30000)
 
 LANGUAGE SQL 
 SPECIFIC youtlib.getfilpath
 DETERMINISTIC 
 MODIFIES SQL DATA
 CALLED ON NULL INPUT
 NO EXTERNAL ACTION
 ALLOW PARALLEL
 NOT SECURED 
 SET OPTION COMMIT = *NONE , DBGVIEW = *SOURCE , DYNUSRPRF = *OWNER , USRPRF = *OWNER

BEGIN 
  
 declare file_name varchar(30000);
 declare error_message_text varchar(1000);
 
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
 BEGIN
   GET DIAGNOSTICS CONDITION 1 error_message_text = message_text;
   CALL systools.lprintf(RTRIM(error_message_text));
   RETURN trim(in_path_name); 
 END;

 set file_name =
        right(in_path_name, length(trim(in_path_name)) - locate_in_string(in_path_name, '/', -1));
 
 return nullif(trim(file_name), '');

END; 


COMMENT ON PARAMETER SPECIFIC FUNCTION youtlib.getfilpath
( 
    in_path_name IS 'Path'
);
