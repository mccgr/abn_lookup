-- This is a program which drops the old abn_lookup tables (if they exist), then makes new tables for the updated data to be written into. 
-- Also, as a last step, this program sets the ownership to abn_lookup and access to abn_lookup_access for each table

ALTER TABLE IF EXISTS abn_lookup.abns RENAME TO abns_old;
ALTER TABLE IF EXISTS abn_lookup.trading_names RENAME TO trading_names_old;
ALTER TABLE IF EXISTS abn_lookup.dgr RENAME TO dgr_old;


CREATE TABLE abn_lookup.abns (

  abn TEXT,
  abn_status TEXT,
  abn_status_from_date DATE,
  record_last_updated_date DATE,
  replaced TEXT,
  entity_type_ind TEXT,
  entity_type_text TEXT,
  asic_number TEXT,
  asic_number_type TEXT,
  gst_status TEXT,
  gst_status_from_date DATE,
  main_ent_type TEXT,
  main_ent_name TEXT,
  main_ent_add_state TEXT,
  main_ent_add_postcode TEXT,
  legal_ent_type TEXT,
  legal_ent_title TEXT, 
  legal_ent_family_name TEXT, 
  legal_ent_given_names TEXT, 
  legal_ent_add_state TEXT, 
  legal_ent_add_postcode TEXT

);


CREATE TABLE abn_lookup.trading_names (

  abn TEXT,
  name TEXT,
  "type" TEXT

);


CREATE TABLE abn_lookup.dgr (

  abn TEXT,
  name TEXT,
  "type" TEXT,
  dgr_status_from_date DATE

);


ALTER TABLE abn_lookup.abns OWNER TO abn_lookup;
GRANT SELECT ON abn_lookup.abns TO abn_lookup_access;
ALTER TABLE abn_lookup.trading_names OWNER TO abn_lookup;
GRANT SELECT ON abn_lookup.trading_names TO abn_lookup_access;
ALTER TABLE abn_lookup.dgr OWNER TO abn_lookup;
GRANT SELECT ON abn_lookup.dgr TO abn_lookup_access;




