DROP TABLE IF EXISTS abn_lookup.abns;
DROP TABLE IF EXISTS abn_lookup.trading_names;
DROP TABLE IF EXISTS abn_lookup.dgr;

ALTER TABLE IF EXISTS abn_lookup.abns_old RENAME TO abns;
ALTER TABLE IF EXISTS abn_lookup.trading_names_old RENAME TO trading_names;
ALTER TABLE IF EXISTS abn_lookup.dgr_old RENAME TO dgr;