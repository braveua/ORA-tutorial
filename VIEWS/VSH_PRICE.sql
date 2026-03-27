
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."VSH_PRICE" ("ID", "FROMDATE", "AKCID", "PRODID", "PRICE", "OLD_PRICE", "UNIT", "SHOPID", "SHOPNAME", "NAME") AS 
  select pri.id,
       pri.fromdate,
       pri.akcid,
       pri.prodid,
       pri.price,
       pri.old_price,
       pri.unit,
       pro.shopid,
       sh.name as shopname,
       pro.name
  from sh_price pri, 
       sh_prod pro,
       sh_shop sh
 where pri.prodid = pro.id
   and pro.shopid = sh.id