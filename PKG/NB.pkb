
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CREATOR"."NB" 
AS
-- Package body

PROCEDURE addnote(p_id NUMBER,
                  p_parentid NUMBER,
                  p_subject VARCHAR2,
                  p_content VARCHAR2,
                  p_tag NUMBER
                 )
IS
BEGIN
	INSERT into nb_note (id, parentid, subject, content, tag) values (p_id, p_parentId, p_subject, p_content, p_tag);
    null;
END;

PROCEDURE updatenote(p_id NUMBER,
--                  p_parentid NUMBER,
                  p_subject VARCHAR2,
                  p_content VARCHAR2
--                  p_tag NUMBER
                 )
IS
BEGIN
	UPDATE nb_note SET subject=p_subject, content=p_content where id=p_id;
END;

PROCEDURE deletenote(p_id NUMBER)
IS
BEGIN
	DELETE FROM nb_note WHERE ID=p_id;
END;

END nb;