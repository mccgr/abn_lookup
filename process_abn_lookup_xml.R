library(XML)
library(readr)
library(RCurl)
library(dplyr)
library(RPostgreSQL, quietly = TRUE)
library(rvest, quietly = TRUE)
library(parallel)
library(purrr)
library(lubridate)
library(RSelenium)



get_variable_value <- function(node, variable_name) {
  
  # This is a function for extracting the values from fields which ONLY APPEAR ONCE under a node
  # Returns the value in the field if it exists, returns NA if the field does not exist
  
  variable_node_list <- getNodeSet(node, variable_name)
  
  if(length(variable_node_list) == 0) {
    
    return(NA)
    
  } else{
    
    value <- xmlValue(variable_node_list[[1]])
    
    return(value)
    
  }
  
}


get_variable_attribute <- function(node, variable_name, attribute_name) {
  
  # This is a function for extracting the attributes from fields which ONLY APPEAR ONCE under a node
  # Returns the attribute in the node if it exists, returns NA if the node does not exist
  
  variable_node_list <- getNodeSet(node, variable_name)
  
  if(length(variable_node_list) == 0) {
    
    return(NA)
    
  } else{
    
    value <- xmlGetAttr(variable_node_list[[1]], attribute_name)
    
    return(value)
    
  }
  
}


paste_names <- function(lst) {
  
  # This function is for pasting the given names in the LegalEntity node into a single string
  
  if(length(lst) == 0) {
    
    return(NA)
    
  }
  
  else if(length(lst) == 1) {
  
    return(lst[[1]])
  
  }
  
  else {result = lst[[1]]
  
  for(i in 2:length(lst)) {
    
    result <- paste(result, lst[[i]], sep = " ")
    
  }
  
  return(result)
  
  }
  
}



scrape_main_ABN_df <- function(node) {
  
  recordLastUpdatedDate <- ymd(xmlGetAttr(node, 'recordLastUpdatedDate'))
  replaced <- xmlGetAttr(node, 'replaced')
  
  abn_node <- getNodeSet(node, 'ABN')[[1]]
  abn <- xmlValue(abn_node)
  abn_status <- xmlGetAttr(abn_node, 'status')
  abn_status_from_date <- ymd(xmlGetAttr(abn_node, 'ABNStatusFromDate'))
  
  entity_type_node <- getNodeSet(node, 'EntityType')[[1]]
  entity_type_index <- xmlValue(getNodeSet(entity_type_node, 'EntityTypeInd')[[1]])
  entity_type_text <- xmlValue(getNodeSet(entity_type_node, 'EntityTypeText')[[1]])
  
  asic_number <- get_variable_value(node, 'ASICNumber')
  asic_number_type <- get_variable_attribute(node, 'ASICNumber', 'ASICNumberType')
  
  gst_status <- get_variable_attribute(node, 'GST', 'status')
  gst_status_from_date <- ymd(get_variable_attribute(node, 'GST', 'GSTStatusFromDate'))
  
  main_ent <- getNodeSet(node, 'MainEntity')
  if(length(main_ent)) {
    
    main_ent_node <- main_ent[[1]]
    main_ent_type <- xmlGetAttr(getNodeSet(main_ent_node, 'NonIndividualName')[[1]], 'type')
    main_ent_name <- xmlValue(getNodeSet(getNodeSet(main_ent_node, 'NonIndividualName')[[1]], 'NonIndividualNameText')[[1]])
    main_ent_add_state <- xmlValue(getNodeSet(
    getNodeSet(getNodeSet(main_ent_node, 'BusinessAddress')[[1]], 'AddressDetails')[[1]], 'State')[[1]])
    main_ent_add_postcode <- xmlValue(getNodeSet(
    getNodeSet(getNodeSet(main_ent_node, 'BusinessAddress')[[1]], 'AddressDetails')[[1]], 'Postcode')[[1]])
    
  } else {
    
    main_ent_type <- NA
    main_ent_name <- NA
    main_ent_add_state <- NA
    main_ent_add_postcode <- NA
    
  }
  
  legal_ent <- getNodeSet(node, 'LegalEntity')
  if(length(legal_ent)) {
    
    legal_ent_node <- legal_ent[[1]]
    legal_ent_in_node <- getNodeSet(legal_ent_node, 'IndividualName')[[1]]
    legal_ent_type <- xmlGetAttr(legal_ent_in_node, 'type')
    
    legal_ent_title <- get_variable_value(legal_ent_in_node, 'NameTitle')
    legal_ent_fam_name <- xmlValue(getNodeSet(legal_ent_in_node, 'FamilyName')[[1]])
    legal_ent_given_names <- paste_names(lapply(getNodeSet(legal_ent_in_node, 'GivenName'), xmlValue))
    
    legal_ent_add_state <- xmlValue(getNodeSet(
    getNodeSet(getNodeSet(legal_ent_node, 'BusinessAddress')[[1]], 'AddressDetails')[[1]], 'State')[[1]])
    legal_ent_add_postcode <- xmlValue(getNodeSet(
    getNodeSet(getNodeSet(legal_ent_node, 'BusinessAddress')[[1]], 'AddressDetails')[[1]], 'Postcode')[[1]])
    
  } else {
    
    legal_ent_type <- NA
    legal_ent_title <- NA
    legal_ent_fam_name <- NA
    legal_ent_given_names <- NA
    legal_ent_add_state <- NA
    legal_ent_add_postcode <- NA
    
  }
  
  
  df <- data.frame(abn = abn, abn_status = abn_status, abn_status_from_date = abn_status_from_date, 
        recordLastUpdatedDate = recordLastUpdatedDate, replaced = replaced, entity_type_index = entity_type_index, 
        entity_type_text = entity_type_text, asic_number = asic_number, asic_number_type = asic_number_type, 
        gst_status = gst_status, gst_status_from_date = gst_status_from_date, main_ent_type = main_ent_type,
        main_ent_name = main_ent_name, main_ent_add_state = main_ent_add_state, 
        main_ent_add_postcode = main_ent_add_postcode, legal_ent_type = legal_ent_type, 
        legal_ent_title = legal_ent_title, legal_ent_fam_name = legal_ent_fam_name, 
        legal_ent_given_names = legal_ent_given_names, legal_ent_add_state = legal_ent_add_state, 
        legal_ent_add_postcode = legal_ent_add_postcode)
  
  
  return(df)
  
}

scrape_trading_names_df <- function(node) {
  
  other_ent_nodes <- getNodeSet(node, 'OtherEntity')
  
  if(length(other_ent_nodes)) {
    
    abn <- xmlValue(getNodeSet(node, 'ABN')[[1]])
    
    type <- unlist(lapply(other_ent_nodes, function(x) {xmlGetAttr(getNodeSet(x, 'NonIndividualName')[[1]], 'type')}))
    name <- unlist(lapply(other_ent_nodes, 
                          function(x) {xmlValue(getNodeSet(getNodeSet(x, 'NonIndividualName')[[1]], 'NonIndividualNameText')[[1]])}))
    
    df <- data.frame(name = name, type = type)
    
    df$abn <- abn
    
    df <- df[, c('abn', 'name', 'type')]
    
  } else{
    
    
    df <- data.frame(matrix(nrow = 0, ncol = 0))
    
    
  }
  
  return(df)
  
}


scrape_dgr_df <- function(node) {
  
  dgr_nodes <- getNodeSet(node, 'DGR')
  
  if(length(dgr_nodes)) {
    
    abn <- xmlValue(getNodeSet(node, 'ABN')[[1]])
    
    dgr_status_from_date <- do.call(c, lapply(dgr_nodes, function(x) {ymd(xmlGetAttr(x, 'DGRStatusFromDate'))}))
    type <- unlist(lapply(dgr_nodes, function(x) {xmlGetAttr(getNodeSet(x, 'NonIndividualName')[[1]], 'type')}))
    name <- unlist(lapply(dgr_nodes, 
                          function(x) {xmlValue(getNodeSet(getNodeSet(x, 'NonIndividualName')[[1]], 'NonIndividualNameText')[[1]])}))
    
    df <- data.frame(name = name, type = type, dgr_status_from_date = dgr_status_from_date)
    
    df$abn <- abn
    
    df <- df[, c('abn', 'name', 'type', 'dgr_status_from_date')]
    
  } else{
    
    
    df <- data.frame(matrix(nrow = 0, ncol = 0))
    
    
  }
  
  return(df)
  
}


process_abr_node_data <- function(node, pg) {
  
  main_df <- scrape_main_ABN_df(node)
  trading_names_df <- scrape_trading_names_df(node)
  dgr_df <- scrape_dgr_df(node)
  
  
  dbWriteTable(pg, c("abn_lookup", "abns"),
               main_df, append = TRUE, row.names = FALSE)
  dbWriteTable(pg, c("abn_lookup", "trading_names"),
               trading_names_df, append = TRUE, row.names = FALSE)
  dbWriteTable(pg, c("abn_lookup", "dgr"),
               dgr_df, append = TRUE, row.names = FALSE)
  

}


download_xml_files <- function() {
  
  abr_download_url <- "http://data.gov.au/dataset/abn-bulk-extract"
  
  
  
  
}

remDr <- remoteDriver(remoteServerAddr = "localhost"
                      , port = 4444
                      , browserName = "firefox"
)


driver <- rsDriver(browser=c("firefox"))
remote_driver <- driver[["client"]]
remote_driver$open()

driver <- rsDriver(browser=c("chrome"))
remote_driver <- driver[["client"]]
remote_driver$open()

pg <- dbConnect(PostgreSQL())


xml_parse <- xmlParse('20190710_Public02.xml')
xml_root <- xmlRoot(xml_parse)

abr_nodes <- getNodeSet(xml_root, 'ABR')

table(unlist(mclapply(abr_nodes, function(x) {names(xmlAttrs(x))}, mc.cores = 24)))

table(unlist(mclapply(abr_nodes, function(x) {sum(names(xmlAttrs(x)) == 'recordLastUpdatedDate')}, mc.cores = 24)))
table(unlist(mclapply(abr_nodes, function(x) {sum(names(xmlAttrs(x)) == 'replaced')}, mc.cores = 24)))



dbDisconnect(pg)

no_given_names <- which(unlist(mclapply(has_leg_ent, function(x) {sum(names(xmlChildren(getNodeSet(getNodeSet(abr_nodes[[x]], 'LegalEntity')[[1]], 'IndividualName')[[1]])) == 'GivenName')}, mc.cores = 24)) == 0)
df <- bind_rows(lapply(no_given_names, function (x) {process_ABR_node(abr_nodes[[has_leg_ent[x]]])}), .id = "column_label") %>% collect()


