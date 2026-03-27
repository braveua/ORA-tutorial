
  CREATE OR REPLACE EDITIONABLE PACKAGE "CREATOR"."MONO" as 
PROCEDURE add_rate(
  code_a NUMBER, 
  code_b NUMBER, 
  fromdate TIMESTAMP, 
  rate_buy NUMBER, 
  rate_sell NUMBER
  );
  
end mono;