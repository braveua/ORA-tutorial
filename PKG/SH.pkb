
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CREATOR"."SH" as
--------------------------------------------------------------------------------
  FUNCTION get_shopid(p_url VARCHAR2) RETURN NUMBER AS
    l_id NUMBER;
  BEGIN
    SELECT id INTO l_id from sh_shop WHERE url = p_url;
    return l_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      BEGIN
        INSERT INTO sh_shop (URL) VALUES (p_url) RETURNING ID INTO l_id;  
        COMMIT;
        RETURN l_id;
      END;
  END;
--------------------------------------------------------------------------------  
  FUNCTION get_akcid(p_akc VARCHAR2) 
                     RETURN NUMBER
  AS
    l_akcid NUMBER;
  BEGIN
    SELECT id INTO l_akcid from sh_akc WHERE name = p_akc;
    return l_akcid;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      BEGIN
        INSERT INTO sh_akc (name) VALUES (p_akc) RETURNING ID INTO l_akcid;
        COMMIT;
        RETURN l_akcid;
      END;
  END;
--------------------------------------------------------------------------------
  procedure insert_prod(p_url varchar2, p_name varchar2) as
    cnt int;
  begin
    select count(*) into cnt from sh_prod where url=p_url;
    dbms_output.put_line(cnt);
    if cnt=0
        then
            insert into sh_prod (url, name) values (p_url, p_name);
            commit;
    end if;
  end insert_prod;
--------------------------------------------------------------------------------  
  FUNCTION insert_prod(p_url VARCHAR2, p_name VARCHAR2, p_shopid NUMBER) RETURN NUMBER AS
    l_id NUMBER;
  BEGIN
    BEGIN
      SELECT ID INTO l_id FROM sh_prod WHERE URL = p_url and shopid = p_shopid;
      
      UPDATE sh_prod SET NAME=p_name WHERE id = l_id;
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
          BEGIN
            INSERT INTO sh_prod (URL, NAME, shopid) VALUES (p_url, p_name, p_shopid) RETURNING ID INTO l_id;
            RETURN l_id;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                begin
                  NULL;
                end;
              when others then
                DBMS_OUTPUT.PUT_LINE('aaaaaaaaaaaaaaaa!!!!!!!!!!!');
          END;
    END;
    RETURN l_id;
  END insert_prod;
  ------------------------------------------------------------------------------
  PROCEDURE insert_price(p_shopid NUMBER,
                         p_akc VARCHAR2,
                         p_name VARCHAR2,
                         p_url VARCHAR2,
                         p_price NUMBER,
                         p_old_price NUMBER,
                         p_unit      VARCHAR2,
                         p_fromdate DATE DEFAULT NULL)
  AS
    l_akcid NUMBER  := NULL;
    l_prodid NUMBER;
  BEGIN
    if p_akc is not null then
      l_akcid := get_akcid(p_akc);
    end if;
      
    l_prodid := insert_prod(p_url=>p_url,
                            p_name=>p_name,
                            p_shopid=>p_shopid);     
                            
                            
--    -- ★★★★★ ЛОГИРОВАНИЕ NULL PRODID ★★★★★
--    IF l_prodid IS NULL THEN
--        INSERT INTO insert_price_log (
--            p_shopid, p_akc, p_name, p_url, p_price, p_old_price, p_unit, v_prodid, v_error
--        ) VALUES (
--            p_shopid, p_akc, p_name, p_url, p_price, p_old_price, p_unit, NULL, 
--            'NULL PRODID DETECTED! insert_prod returned NULL'
--        );
--        DBMS_OUTPUT.PUT_LINE('========================================');
--        DBMS_OUTPUT.PUT_LINE('❌ NULL PRODID DETECTED!');
--        DBMS_OUTPUT.PUT_LINE('   shopid: ' || p_shopid);
--        DBMS_OUTPUT.PUT_LINE('   akc: ' || p_akc);
--        DBMS_OUTPUT.PUT_LINE('   name: ' || p_name);
--        DBMS_OUTPUT.PUT_LINE('   url: ' || p_url);
--        DBMS_OUTPUT.PUT_LINE('   price: ' || p_price);
--        DBMS_OUTPUT.PUT_LINE('   old_price: ' || p_old_price);
--        DBMS_OUTPUT.PUT_LINE('   unit: ' || p_unit);
--        DBMS_OUTPUT.PUT_LINE('========================================');
--    END IF;
--    -- ★★★★★ КОНЕЦ ЛОГИРОВАНИЯ ★★★★★                            
                            
    begin
      insert into sh_price (akcid, prodid, price, old_price, unit, fromdate) values(l_akcid, l_prodid, p_price, p_old_price, p_unit, p_fromdate);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
    end;
    commit;
  END;  
--------------------------------------------------------------------------------
end sh;