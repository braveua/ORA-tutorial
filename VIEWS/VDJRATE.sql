
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."VDJRATE" ("FROMDATE", "USD", "EUR") AS 
  select distinct r.fromdate,
(select usd.rate from nbu_rate usd where usd.fromdate=r.fromdate and usd.currencyid=840) usd,
(select eur.rate from nbu_rate eur where eur.fromdate=r.fromdate and eur.currencyid=978) eur
from nbu_rate r order by fromdate