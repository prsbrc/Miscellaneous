CREATE OR REPLACE VIEW brunner.date_time AS
(
 SELECT CAST(CURRENT_DATE AS CHAR(10)) AS char_date,
        CAST(CURRENT_TIME AS CHAR(8)) AS char_time,
        CAST(DAYNAME(CURRENT_DATE) AS CHAR(20)) AS day_name
   FROM sysibm.sysdummy1
)