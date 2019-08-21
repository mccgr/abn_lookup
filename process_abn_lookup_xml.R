library(xml2)
library(readr)
library(RCurl)
library(dplyr)
library(RPostgreSQL, quietly = TRUE)
library(rvest, quietly = TRUE)
library(parallel)
library(purrr)
library(lubridate)



scrape_main_ABN_df <- function(file_name) {
  
  xml_parse <- read_xml(file_name)
  root <- xml_root(xml_parse)
  nodes <- xml_find_all(root, 'ABR')

  all_cols <- c('abn', 'abn_status', 'abn_status_from_date', 'record_last_updated_date', 'replaced', 'entity_type_ind', 
                'entity_type_text', 'asic_number', 'asic_number_type', 'gst_status', 'gst_status_from_date', 
                'main_ent_type', 'main_ent_name', 'main_ent_add_state', 'main_ent_add_postcode', 'legal_ent_type', 
                'legal_ent_title', 'legal_ent_family_name', 'legal_ent_given_names', 'legal_ent_add_state', 
                'legal_ent_add_postcode')
  df <- data.frame(matrix(nrow = length(nodes), ncol = length(all_cols)), stringsAsFactors = FALSE)
  colnames(df) <- all_cols
 
  df$abn <- xml_text(xml_find_first(nodes, 'abn'))
  df$abn_status <- xml_text(xml_find_first(nodes, 'abn_status'))
  df$abn_status_from_date <- ymd(xml_text(xml_find_first(nodes, 'abn_status_from_date')))
  df$record_last_updated_date <- ymd(xml_text(xml_find_first(nodes, 'record_last_updated_date')))
  df$replaced <- xml_text(xml_find_first(nodes, 'replaced'))
  df$entity_type_ind <- xml_text(xml_find_first(nodes, 'entity_type_ind'))
  df$entity_type_text <- xml_text(xml_find_first(nodes, 'entity_type_text'))
  df$asic_number <- xml_text(xml_find_first(nodes, 'asic_number'))
  df$asic_number_type <- xml_text(xml_find_first(nodes, 'asic_number_type'))
  df$gst_status <- xml_text(xml_find_first(nodes, 'gst_status'))
  df$gst_status_from_date <- ymd(xml_text(xml_find_first(nodes, 'gst_status_from_date')))
  df$main_ent_type <- xml_text(xml_find_first(nodes, 'main_ent_type'))
  df$main_ent_name <- xml_text(xml_find_first(nodes, 'main_ent_name'))
  df$main_ent_add_state <- xml_text(xml_find_first(nodes, 'main_ent_add_state'))
  df$main_ent_add_postcode <- xml_text(xml_find_first(nodes, 'main_ent_add_postcode'))
  df$legal_ent_type <- xml_text(xml_find_first(nodes, 'legal_ent_type'))
  df$legal_ent_title <- xml_text(xml_find_first(nodes, 'legal_ent_title'))
  df$legal_ent_family_name <- xml_text(xml_find_first(nodes, 'legal_ent_family_name'))
  df$legal_ent_given_names <- xml_text(xml_find_first(nodes, 'legal_ent_given_names'))
  df$legal_ent_add_state <- xml_text(xml_find_first(nodes, 'legal_ent_add_state'))
  df$legal_ent_add_postcode <- xml_text(xml_find_first(nodes, 'legal_ent_add_postcode'))
  
  
  return(df)
  
  
}




scrape_trading_names_df <- function(file_name) {
  
  xml_parse <- read_xml(file_name)
  root <- xml_root(xml_parse)
  nodes <- xml_find_all(root, 'OtherEntity')
  
  abn <- xml_text(xml_find_first(nodes, 'abn'))
  name <- xml_text(xml_find_first(nodes, 'name'))
  type <- xml_text(xml_find_first(nodes, 'type'))
  df <- data.frame(abn = abn, name = name, type = type, stringsAsFactors = FALSE)
  return(df)
    
}


scrape_dgr_df <- function(file_name) {
  
  xml_parse <- read_xml(file_name)
  root <- xml_root(xml_parse)
  nodes <- xml_find_all(root, 'DGR')

  abn <- xml_text(xml_find_first(nodes, 'abn'))
  name <- xml_text(xml_find_first(nodes, 'name'))
  type <- xml_text(xml_find_first(nodes, 'type'))
  dgr_status_from_date <- ymd(xml_text(xml_find_first(nodes, 'dgr_status_from_date')))
  df <- data.frame(abn = abn, name = name, 
                   type = type, dgr_status_from_date = dgr_status_from_date, stringsAsFactors = FALSE)
  return(df)
  
}



delete_old_abn_tables <- function() {
  
  pg <- dbConnect(PostgreSQL())
  
  if(dbExistsTable(pg, c("abn_lookup", "abns"))) {
    
    dbExecute(pg, 'DROP TABLE abn_lookup.abns')
    
  }
  
  if(dbExistsTable(pg, c("abn_lookup", "trading_names"))) {
    
    dbExecute(pg, 'DROP TABLE abn_lookup.trading_names')
    
  }
  
  if(dbExistsTable(pg, c("abn_lookup", "dgr"))) {
    
    dbExecute(pg, 'DROP TABLE abn_lookup.dgr')
    
  }
  
  dbDisconnect(pg)
  
}

initialize_new_abn_lookup_tables <- function(pg) {
  
  pg <- dbConnect(PostgreSQL())
  
  sql_make_main <- "CREATE TABLE abn_lookup.abns (
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
                      gst_status_from_date TEXT,
                      main_ent_type TEXT,
                      main_ent_name TEXT,
                      main_ent_add_state TEXT,
                      main_ent_add_postcode TEXT,
                      legal_ent_type TEXT,
                      legal_ent_title TEXT, 
                      legal_ent_family_name TEXT, 
                      legal_ent_given_names TEXT, 
                      legal_ent_add_state TEXT, 
                      legal_ent_add_postcode TEXT)
                     "
  
  sql_make_trading_names <- "CREATE TABLE abn_lookup.trading_names (
                                abn TEXT, 
                                name TEXT, 
                                type TEXT)"
  
  sql_make_dgr <- "CREATE TABLE abn_lookup.dgr (
                      abn TEXT, 
                      name TEXT, 
                      type TEXT, 
                      dgr_status_from_date DATE)"
  
  dbExecute(pg, sql_make_main)
  dbExecute(pg, sql_make_trading_names)
  dbExecute(pg, sql_make_dgr)
  
  dbDisconnect(pg)
  
}




delete_old_abn_tables()
initialize_new_abn_lookup_tables()

pg <- dbConnect(PostgreSQL())

file_list <- list.files('xml_files/')
main_files <- paste0('xml_files/', grep('^main', file_list, value = TRUE))
trading_names_files <- paste0('xml_files/', grep('^trading_names', file_list, value = TRUE))
dgr_files <- paste0('xml_files/', grep('^dgr', file_list, value = TRUE))


for(i in 1:length(main_files)) {
  
  print(paste0("Processing file ", i))
  main_df <- scrape_main_ABN_df(main_files[i])
  dbWriteTable(pg, c("abn_lookup", "abns"),
               main_df, append = TRUE, row.names = FALSE)
  print(paste0("Successfully processed ", nrow(main_df), " entries into abn_lookup.abns"))
  trading_names_df <- scrape_trading_names_df(trading_names_files[i])
  dbWriteTable(pg, c("abn_lookup", "trading_names"),
               trading_names_df, append = TRUE, row.names = FALSE)
  print(paste0("Successfully processed ", nrow(trading_names_df), " entries into abn_lookup.trading_names"))
  dgr_df <- scrape_dgr_df(dgr_files[i])
  dbWriteTable(pg, c("abn_lookup", "dgr"),
               dgr_df, append = TRUE, row.names = FALSE)
  print(paste0("Successfully processed ", nrow(dgr_df), " entries into abn_lookup.dgr"))
  
}


dbDisconnect(pg)



