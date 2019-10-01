import os
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

    
    
def process_xml_file(path):
    
    # Note: this assumes path being the full path to the file, ie. directory/file_name
    
    command_main = "xsltproc xml_to_csv_main.xsl " + path +     \
                    " | psql -d crsp -c \"COPY abn_lookup.abns " +    \
                    "FROM STDIN CSV HEADER DELIMITER E'\\t' QUOTE E'\\b' ENCODING 'utf-8';\""
    
    command_trd = "xsltproc xml_to_csv_trading_names.xsl " + path +     \
                    " | psql -d crsp -c \"COPY abn_lookup.trading_names " +    \
                    "FROM STDIN CSV HEADER DELIMITER E'\\t' QUOTE E'\\b' ENCODING 'utf-8';\""
    
    command_dgr = "xsltproc xml_to_csv_dgr.xsl " + path +     \
                    " | psql -d crsp -c \"COPY abn_lookup.dgr " +    \
                    "FROM STDIN CSV HEADER DELIMITER E'\\t' QUOTE E'\\b' ENCODING 'utf-8';\""
    
    
    # Note: os.system returns 0 if command is successful, thus write outputs as failures and then test
    failure_main = os.system(command_main)
    failure_trd = os.system(command_trd)
    failure_dgr = os.system(command_dgr)

    if not (failure_main+failure_trd+failure_dgr):
        
        return(True)
    
    else:
        
        if(failure_main):
            
            print("Error in process_xml_file: failure to write to abn_lookup.abns for file " + path)
            
        if(failure_trd):
            print("Error in process_xml_file: failure to write to abn_lookup.trading_names for file " + path)
            
        if(failure_dgr):
            print("Error in process_xml_file: failure to write to abn_lookup.dgr for file " + path)
            
        return(False)



def delete_full_directory(directory):
    # Warning: assumes no subfolders. Designed specifically to delete xml_files folder within the abn_lookup folder
    for file in os.listdir(directory):
        os.remove(directory + '/' + file)
        
    os.rmdir(directory)




download_dir = "/home/bdcallen/abn_lookup/xml_files"

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


# Step 1, delete the old tables and make new ones for storing the new data, with create_new_abn_lookup_tables.sql
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


if(len(os.listdir(download_dir)) == 0):
    
    os.rmdir(download_dir)








    
