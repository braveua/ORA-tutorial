
  CREATE OR REPLACE EDITIONABLE PACKAGE "CREATOR"."COMMON" AS 

  PROCEDURE log_message (
    p_system         VARCHAR2,
    p_log_level      VARCHAR2,
    p_error_code     NUMBER := NULL,
    p_error_text     CLOB := NULL
  );

END COMMON;