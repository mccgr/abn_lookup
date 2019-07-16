CREATE SCHEMA IF NOT EXISTS abn_lookup;
CREATE ROLE abn_lookup;
ALTER SCHEMA abn_lookup OWNER TO abn_lookup;
CREATE ROLE abn_lookup_access;
GRANT USAGE ON SCHEMA abn_lookup TO abn_lookup_access;