
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."MGV_ALL_CONNECTIONS" ("PROJECT_ID", "PROJECT_NAME", "CONNECTION_ID", "CONNECTION_NAME", "HOST", "PORT", "USERNAME", "DBURL") AS 
  SELECT md_projects.id project_id ,
    md_projects.project_name project_name,
    MD_CONNECTIONS.ID CONNECTION_ID ,
    MD_CONNECTIONS.NAME CONNECTION_NAME,
    md_connections.host host ,
    md_connections.port port ,
    md_connections.username username ,
    md_connections.dburl dburl
  FROM md_projects,
    md_connections
  WHERE MD_CONNECTIONS.PROJECT_ID_FK = MD_PROJECTS.ID
WITH READ ONLY