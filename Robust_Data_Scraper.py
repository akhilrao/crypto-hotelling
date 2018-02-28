#This code sends requests to mining pool api data to get mining pool use data
#Currently the pools scraped are:
#   Bitcoin: Slushpool and Btc.com
#   Etherium: ethermine and nanopool
#   Monero:     nanopool and supportXMR

#Each pool has a getData function and a writeData function. The getData sends requests and the
#writeData compiles to csv/text files. 
import pandas as pd
import requests
import sys
import os
import datetime
import time
#############

#Where the relevant mining data will be saved
outputFolder = "C:/Users/sean/Desktop/Bitcoin Scraping Data/Data_Scraper"
slushPoolFolder = outputFolder + "/Slush Pool"
btcFolder = outputFolder + "/BTC_com"
ethermineFolder = outputFolder + "/Ethermine"
nanopoolFolder = outputFolder + "/Nanopool"
nanopoolMoneroFolder = outputFolder + "/Nanopool Monero"
supportXmrFolder = outputFolder + "/Support XMR"
#############
timeSeq = 60*5 #frequency of requests in seconds (60*5 = 5 minutes)
#____________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________________________
#____________________________________________________________________________________________________________________________
#returns a string time
def getTime():
    currentTime = str(datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
    return currentTime
##
#queries slushpool data 
def getSlushPoolData():
    html = requests.get("https://slushpool.com/api/v1/stats/get_btc_pool_hr_distribution/").json()["data"]
    max_buckets = html["max_bucket"]
    max_users = html["total_ghps"]
    total_ghps = html["total_ghps"]
    data = pd.DataFrame(html["buckets"])
    totalWorkers = sum(data["user_count"])
    return {"data": data, "meta_data" : [max_buckets, max_users, total_ghps, totalWorkers] }

##
def getBTCdata():
    html = requests.get("https://us-pool.api.btc.com/v1/pool/multi-coin-stats?dimension=1h").json()
    btcData = html["data"]["btc"]
#
    stats = btcData["stats"]
    return [stats["workers"], stats["users"], stats["shares"]["shares_1m"], stats["shares"]["shares_15m"], stats["shares"]["shares_1h"], stats["shares"]["shares_unit"]]


def getPriceData():
    priceData = requests.get("https://api.coindesk.com/v1/bpi/currentprice.json").json()
    pricesUSD = priceData["bpi"]["USD"]["rate_float"]
    priceTime = priceData["time"]["updated"].replace(",", "")
    return {"pricesUSD":pricesUSD, "priceTime":priceTime}
##
#For EtherMine
def getEthermineData():
    html = requests.get("https://api.ethermine.org/poolStats").json()["data"]
    price = html["price"]["usd"]
    poolStats = html["poolStats"]
    header = "price"
    data = "%s" %price
    for key, val in poolStats.iteritems():
        header += ", " + str(key)
        data += ", " + str(val)
    header += "\n"
    return [header, data]

def getNanopoolData(coin):
    miners = requests.get("https://api.nanopool.org/v1/" +coin +"/pool/activeminers").json()["data"]
    workers = requests.get("https://api.nanopool.org/v1/"+ coin+"/pool/activeworkers").json()["data"]
    hashrate = requests.get("https://api.nanopool.org/v1/" + coin+ "/pool/hashrate").json()["data"]
    price = requests.get("https://api.nanopool.org/v1/" + coin + "/prices").json()["data"]["price_usd"]
    header = "price, miners, workers, hashrate \n"
    data = "%s, %s, %s, %s" %(str(price), str(miners), str(workers), str(hashrate))
    return [header, data]
##
def getSupportXmrData():
    pool = requests.get("https://supportxmr.com/api/pool/stats").json()["pool_statistics"]
    header = ""
    data = ""
    for key, val in pool.iteritems():
        header += ", " + str(key)
        data += ", " + str(val)
    header += "\n"
    return [header, data]

def writeSlushPoolData(slushFolder, currentTime, prices):
    try:
        slushPool = getSlushPoolData()
        slushData = slushPool["data"]
        slushData.to_csv(slushFolder + "/data/slushpool mining data_" + currentTime + ".csv")
        with open(slushFolder + "/metadata/" + "slushpool mining metadata_" + currentTime + ".txt", "w") as f:
            f.write("time, price, price_time, max_bucket, max_users, total_ghps, total_workers \n")
            f.write("%s, %s, %s, %s, %s, %s, %s" %(currentTime, prices["pricesUSD"], prices["priceTime"], slushPool["meta_data"][0], slushPool["meta_data"][1], slushPool["meta_data"][2], slushPool["meta_data"][3]))
    except:
        print "write SlushPoolData failed"


        
def writeBTCdata(btcFolder, currentTime, prices):
    try:
        btcData = getBTCdata()
        with open(btcFolder + "/btc mining data_" + currentTime + ".txt", "w") as f:
            f.write("time, price, price_time, workers, users, hashrate_1m, hashrate_15m, hashrate_1h, unit \n")
##            print "%s, %s, %s, %s, %s, %s, %s, %s, %s" %(currentTime, prices["pricesUSD"], prices["priceTime"], btcData[0], btcData[1], btcData[2], btcData[3], btcData[4], btcData[5]) 
            f.write("%s, %s, %s, %s, %s, %s, %s, %s, %s" %(currentTime, prices["pricesUSD"], prices["priceTime"], btcData[0], btcData[1], btcData[2], btcData[3], btcData[4], btcData[5]) )
    except:
        print "BTC data failed"

def writeEthermineData(ethermineFolder, currentTime):
    try:
        ethermineData = getEthermineData()
        with open(ethermineFolder + "/ethermine data_" + currentTime + ".txt", "w") as f:
            f.write("time, " + ethermineData[0])
            f.write(currentTime + ", " + ethermineData[1])
    except:
        print "writeEthermineData failed"

def writeNanopoolData(folder, currrentTime, coin, name):
    try:
        nanopoolData = getNanopoolData("eth")
        with open(folder + "/"+name+"_" + currentTime + ".txt", "w") as f:
            f.write("time, " + nanopoolData[0])
            f.write(currentTime + ", " + nanopoolData[1])
    except:
        print "writeNanopoolData failed %s" %coin

def writeSupportXmrData(supportXmrFolder, currrentTime):
    try:
        price = str(getNanopoolData("xmr")[1].split(",")[0])
    except:
        price = "NA"
    try:
        supportXmrData = getSupportXmrData()
        with open(supportXmrFolder + "/Support XMR monero data_" + currentTime + ".txt", "w") as f:
            f.write("time, price " + supportXmrData[0])
            f.write(currentTime + ", " + price + supportXmrData[1])
    except:
        print "writeSupportXmrData failed"

        

c = 1
while True:
##    print time.time()
    try:
        currentTime = getTime()
        BTC_price = getPriceData()
##            print currentTime
##            print BTC_price
        writeSlushPoolData(slushPoolFolder, currentTime, BTC_price)
        writeBTCdata(btcFolder, currentTime, BTC_price)
        writeEthermineData(ethermineFolder, currentTime)
        writeNanopoolData(nanopoolFolder, currentTime, "eth", "nanopool data")
        writeNanopoolData(nanopoolMoneroFolder, currentTime, "xmr", "nanopool monero data")
        writeSupportXmrData(supportXmrFolder, currentTime)
        print "%s: %s"% (c, currentTime)
    except:
        print "Failed to load at time %s" %currentTime
    time.sleep(timeSeq)
    c += 1


