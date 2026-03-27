
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CREATOR"."MGV_ALL_STORED_PROGRAMS" ("PROJECT_ID", "PROJECT_NAME", "CONNECTION_ID", "HOST", "PORT", "USERNAME", "CATALOG_ID", "CATALOG_NAME", "SCHEMA_ID", "SCHEMA_NAME", "STORED_PROGRAM_ID", "PROGRAMTYPE", "STORED_PROGRAM_NAME", "PACKAGE_ID_FK") AS 
  SELECT md_projects.id project_id ,
    md_projects.project_name project_name ,
    md_connections.id connection_id ,
    md_connections.host host ,
    md_connections.port port ,
    md_connections.username username ,
    md_catalogs.id catalog_id ,
    md_catalogs.catalog_name catalog_name ,
    md_schemas.id schema_id ,
    md_schemas.name schema_name ,
    md_stored_programs.id stored_program_id ,
    md_stored_programs.programtype programtype ,
    md_stored_programs.name stored_program_name,
    md_stored_programs.package_id_fk package_id_fk
  FROM md_projects ,
    md_connections,
    md_catalogs ,
    md_schemas ,
    md_stored_programs
  WHERE md_stored_programs.schema_id_fk = md_schemas.id
  AND md_schemas.catalog_id_fk          = md_catalogs.id
  AND md_catalogs.connection_id_fk      = md_connections.id
  AND md_connections.project_id_fk      = md_projects.id