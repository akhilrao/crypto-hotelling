#This code is a combined scroller-scraper which extracts data for each block mined
#folderPath is the path to the output folder where csv files for each day will be loaded
#Relative path should hold, otherwise folderPath must be manually inputted
#Code scrapes data from btc.com
#Sometimes scraper connection may time out. In this case the date range in dates needs to be updated to last scraped day.

import pandas as pd
import requests
##folderPath = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/BlockData/"
folderPath = "../Data/BlockData/"
genericFileHeader = "block data_"
dates = pd.date_range(start ="03-10-2010", end = "01-20-2018")

counter = 1
for day in dates:
    dateString =  str(day.date())
    if counter % 15 == 0: print dateString
    counter += 1
    #
    html = requests.get("https://btc.com/block?date="+dateString).content
    df = pd.read_html(html)[0] #Gets block data as a table
    df.to_csv(folderPath + genericFileHeader + dateString + ".csv") 
