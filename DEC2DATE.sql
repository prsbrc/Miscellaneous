CREATE OR REPLACE FUNCTION LIB.DEC2DATE (IN_DEC DECIMAL(8, 0))
 RETURNS DATE
 LANGUAGE SQL
 DETERMINISTIC
 READS SQL DATA
 CALLED ON NULL INPUT
 NO EXTERNAL ACTION
 NOT SECURED

BEGIN

 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
   RETURN NULL;
  END;

 IF IN_DEC=99999999 THEN
  SET IN_DEC=99991231;
 END IF;

 RETURN DATE(TO_DATE(CHAR(IN_DEC), 'YYYYMMDD'));

END;