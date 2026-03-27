
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."VSH_TODAY" ("LAST", "NICKNAME", "CNT") AS 
  select trunc(sysdate) last, s.nickname,
(select count(*) from vproduct p
where p.fromdate=trunc(sysdate) and p.shopid=s.id) cnt
from sh_shop s