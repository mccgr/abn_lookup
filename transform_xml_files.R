
xml_files <- paste0('xml_files/', list.files('xml_files/'))

for(file in xml_files) {
  
  file_ending <- regmatches(file, regexpr('[0-9]{2}.xml$', file))
  
  command1 <- paste0('xsltproc -o xml_files/main_', file_ending, ' abn_file_transform_main.xsl ', file)
  command2 <- paste0('xsltproc -o xml_files/trading_names_', file_ending, ' abn_file_transform_trd_names.xsl ', file)
  command3 <- paste0('xsltproc -o xml_files/dgr_', file_ending, ' abn_file_transform_dgr.xsl ', file)
  system(command1)
  system(command2)
  system(command3)
  
  file.remove(file)
  
}