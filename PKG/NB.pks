
  CREATE OR REPLACE EDITIONABLE PACKAGE "CREATOR"."NB" 
AS 
-- Package header
  PROCEDURE addnote(p_id NUMBER,
                    p_parentid NUMBER,
                    p_subject VARCHAR2,
                    p_content VARCHAR2,
                    p_tag NUMBER
                   );
                
  PROCEDURE updatenote(p_id NUMBER,
                       p_subject VARCHAR2,
                       p_content VARCHAR2
                      );

  PROCEDURE deletenote(p_id NUMBER);

END nb;