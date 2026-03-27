
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."VPRODUCT" ("ID", "FROMDATE", "SHOPID", "SHNICKNAME", "AKC", "PRODID", "NAME", "PRICE", "OLD_PRICE", "UNIT") AS 
  SELECT p.id,
          p.fromdate,
          s.id shopid,
          s.nickname shnickname,
          a.name akc,
          pr.id prodid,
          pr.name,
          p.price,
          p.old_price,
          p.unit
     FROM sh_price p,
          sh_akc a,
          sh_prod pr,
          sh_shop s
    WHERE p.akcid = a.id
      AND p.prodid = pr.id
      AND pr.shopid = s.id