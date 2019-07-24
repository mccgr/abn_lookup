import os
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.select import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep
import zipfile


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
