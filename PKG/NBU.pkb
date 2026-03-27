
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CREATOR"."NBU" AS 

PROCEDURE add_currency(id_    NUMBER,
                       sname_ VARCHAR2,
                       fname_ VARCHAR2)
IS
BEGIN
    INSERT INTO nbu_currency (id, sname, fname) VALUES (id_, sname_, fname_);
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
END add_currency;
    
    
PROCEDURE add_rate(    currencyid_ NUMBER,
                       rate_       NUMBER,
                       fromdate_   DATE)
IS
BEGIN
    INSERT INTO nbu_rate(currencyid, rate, fromdate) VALUES (currencyid_, rate_, fromdate_);
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
END add_rate;


PROCEDURE load_url_rate(p_url VARCHAR2)
AS
    l_json CLOB;
    pieces utl_http.html_pieces;
BEGIN    
    -- 1. Инициализируем CLOB перед конкатенацией
    DBMS_LOB.CREATETEMPORARY(l_json, TRUE);

    -- 2. Загружаем JSON по частям
    pieces := utl_http.request_pieces(p_url, 32000);
    FOR i IN 1..pieces.count LOOP        
        DBMS_LOB.WRITEAPPEND(l_json, LENGTH(pieces(i)), pieces(i));
    END LOOP;

    -- 3. Проверяем JSON перед обработкой
    IF l_json IS NULL OR LENGTH(l_json) < 10 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ошибка: JSON пуст или поврежден.');
    END IF;

    -- 4. Обрабатываем JSON
    FOR rec IN (
        SELECT 
            r030, cc, txt, rate, 
            TO_DATE(exchangedate, 'DD.MM.YYYY') AS exchangedate
        FROM JSON_TABLE(l_json, '$[*]'
            COLUMNS (
                r030 NUMBER PATH '$.r030',
                cc VARCHAR2(10) PATH '$.cc',
                txt VARCHAR2(100) PATH '$.txt',
                rate NUMBER PATH '$.rate',
                exchangedate VARCHAR2(10) PATH '$.exchangedate'
            )
        )
    ) LOOP
        -- 5. Записываем валюту
        add_currency(id_ => rec.r030, 
                     sname_ => rec.cc, 
                     fname_ => rec.txt);

        -- 6. Записываем курс
        add_rate(currencyid_ => rec.r030, 
                 rate_ => rec.rate, 
                 fromdate_ => rec.exchangedate);
    END LOOP;

    -- 7. Освобождаем временный CLOB
    DBMS_LOB.FREETEMPORARY(l_json);
END load_url_rate;



PROCEDURE load_rate
AS
    l_last DATE;
    l_url  VARCHAR2(255);
BEGIN
  
    SELECT max(r.fromdate)+1 INTO l_last from nbu_rate r;

    while l_last<= sysdate()+1 LOOP
      l_url:= 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=' || to_char(l_last, 'yyyymmdd') || '&json';
      load_url_rate(l_url);
      l_last:= l_last+1;
    END LOOP;
    common.log_message(p_system => 'NBU',
                       p_log_level => 'SUCCESS',
                       p_error_text => 'Загрузка курсов завершена');
    
    EXCEPTION

    WHEN OTHERS THEN
        common.log_message(p_system => 'NBU',
                           p_log_level => 'ERROR',
                           p_error_code => SQLCODE,
                           p_error_text => SQLERRM);
        RAISE;
  
END load_rate;

END NBU;