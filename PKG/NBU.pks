
  CREATE OR REPLACE EDITIONABLE PACKAGE "CREATOR"."NBU" AS 

PROCEDURE add_currency(id_ NUMBER,
                       sname_ VARCHAR2,
                       fname_ VARCHAR2);

PROCEDURE add_rate(    currencyid_ NUMBER,
                       rate_ NUMBER,
                       fromdate_ DATE);

PROCEDURE load_url_rate(p_url VARCHAR2);

PROCEDURE load_rate;

END NBU;