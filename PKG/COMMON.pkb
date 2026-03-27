
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CREATOR"."COMMON" AS

  PROCEDURE log_message (
    p_system         VARCHAR2,
    p_log_level      VARCHAR2,
    p_error_code     NUMBER := NULL,
    p_error_text     CLOB := NULL
  ) AS
  l_system syslog.system%type;
  l_log_level syslog.log_level%TYPE := p_log_level;
    
  BEGIN
  --  l_log_level := CASE WHEN some_condition THEN 'INFO' ELSE 'ERROR' END;
    IF l_log_level IS NULL THEN
      l_log_level := 'ERROR';
    END IF;
    
    INSERT INTO syslog (system, log_level, error_code, error_text, log_date)
    VALUES (p_system, p_log_level, p_error_code, p_error_text, SYSTIMESTAMP);
    COMMIT;
  END log_message;

END COMMON;