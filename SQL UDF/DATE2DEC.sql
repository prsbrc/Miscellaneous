/*
COPYRIGHT (c)2021 Christian Brunner

Convert iso date to decimal with format yyyymmdd.
Returns null on null input or error

Incoming Parameter:
 - Iso date
 
Returns decimal date or null on failure
*/

CREATE OR REPLACE FUNCTION LIB.DATE2DEC
(
 IN_DATE DATE
)

 RETURNS DECIMAL (8, 0)
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

 RETURN DECIMAL(IN_DATE, 8);

END;