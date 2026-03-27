
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CREATOR"."MONO" as 
PROCEDURE add_rate(
  code_a NUMBER, 
  code_b NUMBER, 
  fromdate TIMESTAMP, 
  rate_buy NUMBER, 
  rate_sell NUMBER
  ) IS
BEGIN
  INSERT INTO mn_rate(codea, codeb, fromdate, ratebuy, ratesell) VALUES(code_a, code_b, fromdate, rate_buy, rate_sell);
  EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
      NULL;
END add_rate;
  
end mono;