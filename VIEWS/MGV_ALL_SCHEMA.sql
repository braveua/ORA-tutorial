
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."MGV_ALL_SCHEMA" ("PROJECT_ID", "PROJECT_NAME", "CONNECTION_ID", "HOST", "PORT", "USERNAME", "CATALOG_ID", "CATALOG_NAME", "SCHEMA_ID", "SCHEMA_NAME") AS 
  SELECT md_projects.id project_id ,
    md_projects.project_name project_name,
    md_connections.id connection_id ,
    md_connections.host host ,
    md_connections.port port ,
    md_connections.username username ,
    md_catalogs.id catalog_id ,
    md_catalogs.catalog_name catalog_name,
    md_schemas.id schema_id ,
    md_schemas.name schema_name
  FROM md_connections,
    md_catalogs ,
    md_schemas ,
    md_projects
  WHERE md_schemas.catalog_id_fk   = md_catalogs.id
  AND md_catalogs.connection_id_fk = md_connections.id
  AND md_connections.project_id_fk = md_projects.id
WITH READ ONLY