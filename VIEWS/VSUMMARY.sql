
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."VSUMMARY" ("NICKNAME", "ID", "FROMDATE", "SHOPID", "SHNICKNAME", "AKC", "PRODID", "NAME", "PRICE", "OLD_PRICE", "UNIT") AS 
  select s.nickname, v."ID",v."FROMDATE",v."SHOPID",v."SHNICKNAME",v."AKC",v."PRODID",v."NAME",v."PRICE",v."OLD_PRICE",v."UNIT"  from sh_shop s
left join vproduct v on v.shopid=s.id