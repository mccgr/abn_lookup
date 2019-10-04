import os
import subprocess
import re
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.select import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep
import zipfile
import datetime as dt



def count_nodes(file_name, node_type):

    node_regex = "</" + node_type + ">|<" + node_type + "/>|<" + node_type + " />"

    egrep = subprocess.Popen(['egrep', '-o', node_regex, file_name], stdout=subprocess.PIPE)

    count = subprocess.Popen(['wc', '-l'],
                            stdin=egrep.stdout,
                            stdout=subprocess.PIPE,
                            )

    end_of_pipe = count.stdout
    result = int(re.sub('[\n\s\r\t]*', '',end_of_pipe.read().decode()))
    
    return(result)
    
    
    

def write_table_data_from_xml_file(path, table_name):

    xsl_file = "xml_to_csv_" + table_name + ".xsl"

    err = open('err.txt', 'w')
    
    xslt = subprocess.Popen(["xsltproc", xsl_file, path], stdout=subprocess.PIPE, \
                            stderr=err, universal_newlines=True)

    write_sql = "COPY abn_lookup." + table_name + \
                        " FROM STDIN CSV HEADER DELIMITER E'\\t' QUOTE E'\\b' ENCODING 'utf-8';"
    
    psql = subprocess.Popen(["psql", "-d", "crsp", "-c", write_sql], stdin=xslt.stdout, stdout=subprocess.PIPE, \
                            stderr=err, universal_newlines=True)

    output, _ = psql.communicate()
    
    err.close()
    
    err = open('err.txt', 'r')
    
    error = err.read()
    
    err.close()
    
    os.remove('err.txt')
    
    if(len(error) == 0):
        error = None

    return output, error
    

    
def process_xml_file(path):
    
    # First count the number of the fundamental nodes for each table: ABR for abns, OtherEntity for trading_names
    # DGR for dgr. These correspond to the number of rows that should be read into each table from the file in path
    
    numrows_abns = count_nodes(path, 'ABR')
    numrows_trading_names = count_nodes(path, 'OtherEntity')
    numrows_dgr = count_nodes(path, 'DGR')
    
    
    # Note: this assumes path being the full path to the file, ie. directory/file_name    
    
    write_abns_output, write_abns_error = write_table_data_from_xml_file(path, 'abns')
    write_trading_names_output, write_trading_names_error = write_table_data_from_xml_file(path, 'trading_names')
    write_dgr_output, write_dgr_error = write_table_data_from_xml_file(path, 'dgr')
    
    success_abns = (write_abns_output == "COPY " + str(numrows_abns) + "\n")
    success_trading_names = (write_trading_names_output == "COPY " + str(numrows_trading_names) + "\n")
    success_dgr = (write_dgr_output == "COPY " + str(numrows_dgr) + "\n")

    
    if(not success_abns):

        if(re.match('COPY [0-9]+\n', write_abns_output)):
            num_abns_written = re.search('[0-9]+', write_abns_output).group(0)

            print("Error in process_xml_file: expected to write " + str(numrows_abns) + \
              " records to abn_lookup.abns from " + path + ", " + num_abns_written + " were written")

        else:

            print("Error in process_xml_file: expected to write " + str(numrows_abns) + \
              " records to abn_lookup.abns from " + path + ", 0 were written")



    if(not success_trading_names):

        if(re.match('COPY [0-9]+\n', write_trading_names_output)):
            num_trds_written = re.search('[0-9]+', write_trading_names_output).group(0)

            print("Error in process_xml_file: expected to write " + str(numrows_trading_names) + \
              " records to abn_lookup.trading_names from " + path + ", " + num_trds_written + " were written")

        else:

            print("Error in process_xml_file: expected to write " + str(numrows_trading_names) + \
              " records to abn_lookup.trading_names from " + path + ", 0 were written")


    if(not success_dgr):

        if(re.match('COPY [0-9]+\n', write_dgr_output)):
            num_dgr_written = re.search('[0-9]+', write_dgr_output).group(0)

            print("Error in process_xml_file: expected to write " + str(numrows_dgr) + \
              " records to abn_lookup.dgr from " + path + ", " + num_dgr_written + " were written")

        else:

            print("Error in process_xml_file: expected to write " + str(numrows_dgr) + \
              " records to abn_lookup.dgr from " + path + ", 0 were written")
                    
            return(False)
            
            
    
    if(write_abns_error is None and write_trading_names_error is None and write_dgr_error is None):
    
        if(success_abns and success_trading_names and success_dgr):

            return(True)
        
        else:
            return(False)
        
    else:
        
        if(write_abns_error):
            print("From write_table_data_from_xml_file('" + path + "', 'abns'): ")
            print(write_abns_error)
            
        if(write_trading_names_error):
            print("From write_table_data_from_xml_file('" + path + "', 'trading_names'): ")
            print(write_trading_names_error)
            
        if(write_trading_names_error):
            print("From write_table_data_from_xml_file('" + path + "', 'dgr'): ")
            print(write_dgr_error)
            
        return(False)





def delete_full_directory(directory):
    # Warning: assumes no subfolders. Designed specifically to delete xml_files folder within the abn_lookup folder
    for file in os.listdir(directory):
        os.remove(directory + '/' + file)
        
    os.rmdir(directory)




download_dir = os.getenv("ABN_LOOKUP_DIR") + "/xml_files"

if(os.path.exists(download_dir)):
    delete_full_directory(download_dir)

chrome_options = Options()
chrome_options.add_experimental_option("prefs", {
  "download.default_directory": download_dir,
  "download.prompt_for_download": False,
})

chrome_options.add_argument("--headless")
driver = webdriver.Chrome(options=chrome_options)

driver.command_executor._commands["send_command"] = ("POST", '/session/$sessionId/chromium/send_command')
params = {'cmd': 'Page.setDownloadBehavior', 'params': {'behavior': 'allow', 'downloadPath': download_dir}}
command_result = driver.execute("send_command", params)
    
driver.get('http://data.gov.au/dataset/abn-bulk-extract')
soup = BeautifulSoup(driver.page_source, 'html.parser')

xml_file_list = []
for button in soup.findAll(attrs = {'class': "download-button au-btn au-btn--secondary"}):
    href = button.get('href')
    if(re.search('.zip$', href)):
        xml_file_list.append(href)

        
for file_url in xml_file_list:
    time = 0
    driver.get(file_url)
    file_name = re.search('[0-9a-zA-Z\_]+.zip$', file_url).group(0)
    sleep(2)
    while(os.path.isfile(download_dir + '/' + file_name + ".crdownload")):
        sleep(0.02)
        time = time + 0.02
        if(time >= 600):
            print("Error: file " + file_name + " failed to completely download. Halting. Try again.")
            driver.quit()
            break
    
    if(not os.path.isfile(download_dir + '/' + file_name)):
        print("Error: file " + file_name + " did not download at all. Halting. Try again.")
        driver.quit()
        break
        
driver.quit()


for file_url in xml_file_list:
    file_name = re.search('[0-9a-zA-Z\_]+.zip$', file_url).group(0)
    with zipfile.ZipFile(download_dir + '/' + file_name, 'r') as zip_ref:
        zip_ref.extractall(download_dir)
    os.remove(download_dir + '/' + file_name)
    
    
# Now, let's process the xml files using xslt transformation and piping into a psql command


# Step 1, rename the old tables and make new ones for storing the new data, with create_new_abn_lookup_tables.sql
os.system("psql -d crsp < create_new_abn_lookup_tables.sql")

# Now, iterate over the xml_files, using process_xml_file to write the data to postgres

xml_file_names = os.listdir(download_dir)
xml_paths = [download_dir + '/' + x for x in xml_file_names]

for i in range(len(xml_paths)):
    
    print("Processing " + xml_file_names[i])
    t1 = dt.datetime.now()
    success = process_xml_file(xml_paths[i])
    t2 = dt.datetime.now()
    if(success):
        # File successfully process, remove file
        os.remove(xml_paths[i])
        print("   File processed succesfully")
        print("   Time taken: " + str(t2 - t1))
        
    else:
        print("   Failed to process file completely, halting execution")
        break


if(success):
    # if success is true here, it was true for all xml files, hence all have been successfully processed (otherwise the loop is broken and it keeps its false value). Hence delete old tables. Also, as all the xml files were deleted
    # from the xml_files directory after they were processed, this directory is now empty. So os.rmdir it.
    os.system("psql -d crsp < delete_old_abn_lookup_tables.sql")
    os.rmdir(download_dir)
    
else:    
    # success is only false here if for some xml file, process_xml_file returned false, leading to the loop being broken (and success not being subsequently updated)
    # In this case, remove the incomplete tables, rename the old ones back to the proper names
    os.system("psql -d crsp < keep_old_abn_lookup_tables.sql")





    
    








    
