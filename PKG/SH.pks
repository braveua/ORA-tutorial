
  CREATE OR REPLACE EDITIONABLE PACKAGE "CREATOR"."SH" AS 
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
    PROCEDURE insert_prod(p_url  VARCHAR2, 
                          p_name VARCHAR2);
        
    FUNCTION insert_prod(p_url    VARCHAR2, 
                         p_name   VARCHAR2, 
                         p_shopid NUMBER) 
                         RETURN NUMBER;
                         
    FUNCTION get_shopid(p_url VARCHAR2) 
                        RETURN NUMBER;

    FUNCTION get_akcid(p_akc  VARCHAR2) 
                       RETURN NUMBER;
                         
    PROCEDURE insert_price(p_shopid NUMBER,
                           p_akc VARCHAR2,
                           p_name VARCHAR2,
                           p_url VARCHAR2,
                           p_price NUMBER,
                           p_old_price NUMBER,
                           p_unit      VARCHAR2,
                           p_fromdate DATE DEFAULT NULL);
    
    

END sh;