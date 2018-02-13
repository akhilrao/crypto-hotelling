#This code takes scraped block csv data and compiles into a single csv file
rm(list = ls())
library(plyr)
#____________________________________________________________________________________________
#____________________________________________________________________________________________
#Input file paths here

#Change folderPath to wherever daily files for block data are saved
folderPath = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/BlockData"
#Additional csv file for block difficulty
blockDifficultyFilePath = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/Block Difficulty .csv"

hourlyPriceDataFolderPath =  "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/Prices/AggregatedData"

outputFolderPath = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/Year Data"
#____________________________________________________________________________________________
#____________________________________________________________________________________________
fileNames = list.files(path = folderPath)
##
D = ldply(file.path(folderPath, fileNames), read.csv, skip = 1, as.is = TRUE)[,-1]
D = D[-which(grepl("hours", D$Time)), ] #last day dates saved as #x hours ago which is annoying
#separates rewards into number of coins mined and total transaction fee
reward = strsplit(D$Reward, split = "+", fixed = TRUE)
reward = ldply(reward)
D$coinsMined = reward$V1
D$transactionFee = as.numeric(gsub("BTC","",reward$V2))
##
#Create timestamps
time = ldply(strsplit(D$Time, split = " ", fixed = TRUE))
hourMin = ldply(strsplit(time$V2, ":"))
date = ldply(strsplit(time$V1, "/", fixed = TRUE))
D$Year = date$V1; D$month = date$V2; D$day = date$V3; D$hour = hourMin$V1; D$minute = hourMin$V2
#Make sure data is in correct chronological order
D = D[order(D$Year, D$month, D$day, D$hour, D$minute), ]
#
MineDiff = read.csv(blockDifficultyFilePath, as.is= TRUE)
#
D$difficulty = 0
D$average_time_seconds = 0
D$average_hashrate = 0

#Determines when a difficulty change occurs
for(i in 2:nrow(MineDiff)) {
  dRows = which(D$Height >= MineDiff$height[i-1] & D$Height < MineDiff$height[i])
  D$difficulty[dRows] = MineDiff$diff[i]
  D$average_time_seconds[dRows] = MineDiff$average_time.seconds.[i]
  D$average_hashrate[dRows] = MineDiff$average_hashrate[i]
}
#
#Add Hourly price data
BitstampPrices = read.csv(file.path(hourlyPriceDataFolderPath,"Hourly Bitstamp.csv"))
BitstampPrices$year = as.numeric(paste("20", BitstampPrices$year, sep = ""))
CoinbasePrices = read.csv(file.path(hourlyPriceDataFolderPath,"Hourly Coinbase.csv"))
CoinbasePrices$year = as.numeric(paste("20", CoinbasePrices$year, sep = ""))
BitfinexPrices = read.csv(file.path(hourlyPriceDataFolderPath, "Hourly Bitfinex.csv"))
BitfinexPrices$year = as.numeric(paste("20", BitfinexPrices$year, sep = ""))

D$bitstampPrice = 0
D$bitstampVolBTC = 0
D$bitstampVolUSD = 0
D$coinbasePrice = 0
D$coinbaseVolBTC = 0
D$coinbaseVolUSD = 0
D$bitfinexPrice = 0
D$bitfinexVolBTC = 0
D$bitfinexVolUSD = 0
##
#Adds hourly price data to block dataframe. Code repeats a few times which is ugly as sin, but only needs to be done once
for(y in unique(BitstampPrices$year)) {
  for(m in unique(BitstampPrices$month)){
    Psub = BitstampPrices[which(BitstampPrices$year == y & BitstampPrices$month == m), ]
    print(paste(y, m))
    
    dRows = which(D$Year == y & as.numeric(D$month) == m)
    for(i in dRows) {
      pRow = which(Psub$day == as.numeric(D$day[i]) & Psub$hour == as.numeric(D$hour[i]))
      if(length(pRow > 0)) {
        D$bitstampPrice[i]  = Psub$price[pRow]
        D$bitstampVolBTC[i] = Psub$volumeBTC[pRow]
        D$bitstampVolUSD[i] = Psub$volumeUSD[pRow]
      }

    }
    
  }
}
##
for(y in unique(CoinbasePrices$year)) {
  for(m in unique(CoinbasePrices$month)){
    Psub = CoinbasePrices[which(CoinbasePrices$year == y & CoinbasePrices$month == m), ]
    print(paste(y, m))
    
    dRows = which(D$Year == y & as.numeric(D$month) == m)
    for(i in dRows) {
      pRow = which(Psub$day == as.numeric(D$day[i]) & Psub$hour == as.numeric(D$hour[i]))
      if(length(pRow > 0)) {
        D$coinbasePrice[i]  = Psub$price[pRow]
        D$coinbaseVolBTC[i] = Psub$volumeBTC[pRow]
        D$coinbaseVolUSD[i] = Psub$volumeUSD[pRow]
      }
      
    }
    
  }
}
##
for(y in unique(BitfinexPrices$year)) {
  for(m in unique(BitfinexPrices$month)){
    Psub = BitfinexPrices[which(BitfinexPrices$year == y & BitfinexPrices$month == m), ]
    print(paste(y, m))
    
    dRows = which(D$Year == y & as.numeric(D$month) == m)
    for(i in dRows) {
      pRow = which(Psub$day == as.numeric(D$day[i]) & Psub$hour == as.numeric(D$hour[i]))
      if(length(pRow > 0)) {
        D$bitfinexPrice[i]  = Psub$price[pRow]
        D$bitfinexVolBTC[i] = Psub$volumeBTC[pRow]
        D$bitfinexVolUSD[i] = Psub$volumeUSD[pRow]
      }
      
    }
    
  }
}
#


#
years = unique(D$Year)
for(y in years) {
  print(y)
  write.csv(D[which(D$Year == y),], paste(outputFolderPath, "/block and price data_",y,".csv", sep = ""), row.names = FALSE)
}
