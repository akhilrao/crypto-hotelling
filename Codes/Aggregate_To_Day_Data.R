#This code aggregates block-level data to a daily dataset. Price and block data is from Bitcoinity.org

rm(list = ls())
library(plyr)
#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#Input Filepaths here


yearlyBlockDataFolderPath = "C:/Users/seric/Dropbox/CU Boulder/Bitcoin/Data/Year Data"
setwd(yearlyBlockDataFolderPath)

#Other filepaths can be releative to block data folder path
dailyPriceDataFilePath = "../prices/Prices from  Bitcoinity.csv"
outputFileName = "../dataByDay.csv"

#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#Constants
WORK_PER_DIFF = 4295032833 #Relates difficulty to average hashrate
GIGAHASH = 1e9

#Load block-level data
blocklevelDataFiles = list.files()
D = ldply(blocklevelDataFiles, read.csv, as.is = TRUE)
D$ymd = trunc(as.POSIXct(D$Time, "%y/%m/%d"), "days")
#Get daily dates and create daily dataframe
dayData = as.data.frame(unique(D$ymd))
names(dayData) = "ymd"
dayData$year = as.numeric(paste("20",format(dayData$ymd, "%y"),sep = ""))
dayData$month = as.numeric(format(dayData$ymd, "%m"))
dayData$day = as.numeric(format(dayData$ymd, "%d"))
dayData$numBlocks = 0
dayData$difficulty = 0
dayData$rewardPerBlock = 0
dayData$transactionFees = 0 
dayData$difficultyChange = 0
#
years = unique(D$Year)
months = unique(D$month)
#Aggregates block data to daily data
for(y in years) {
  for(m in months) {
    print(paste("year:",y, "month:", m))
    Dsub = D[which(D$Year == y & D$month == m), ]
    dayDataSub = which(dayData$year == y & dayData$month == m)
    #
    dayData$numBlocks[dayDataSub] = sapply(dayData$ymd[dayDataSub], function(x) length(which(Dsub$ymd == x)))
    dayData$difficulty[dayDataSub] = sapply(dayData$ymd[dayDataSub], function(x) Dsub$difficulty[which(Dsub$ymd == x)[1]])
    dayData$rewardPerBlock[dayDataSub] = sapply(dayData$ymd[dayDataSub], function(x) Dsub$coinsMined[which(Dsub$ymd == x)[1]])
    dayData$transactionFees[dayDataSub] = sapply(dayData$ymd[dayDataSub], function(x) sum(Dsub$transactionFee[which(Dsub$ymd == x)]))
  }
}
#Above code creates lists instead of vectors so need to unlist
dayData$numBlocks = unlist(dayData$numBlocks)
dayData$difficulty = unlist(dayData$difficulty)
dayData$rewardPerBlock = unlist(dayData$rewardPerBlock)
dayData$transactionFees = unlist(dayData$transactionFees)
#Determines when block difficulty changes
dayData$difficultyChange = c(0, sapply(2:nrow(dayData), function(x) ifelse(dayData$difficulty[x] == dayData$difficulty[x-1], 0, 1)))
#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________
#Add price data
Prices = read.csv(dailyPriceDataFilePath, as.is = TRUE)
Prices$Time = trunc(as.POSIXct(Prices$Time, "%y-%m-%d %H:%M:%S"), "days")
Prices = Prices[which(Prices$Time %in% dayData$ymd), ]

#Takes daily price data from major exchanges. 
#Average price is simply a straight average of all exchanges, including 
#bit-x	bitfinex	cex.io	coinbase	exmo	gemini	hitbtc	itbit	kraken and others
dayData$bitX =  NA; dayData$bitfineX = NA; dayData$coinbase = NA; dayData$kraken = NA; dayData$AvgPrice = NA
dayData$bitx[which(dayData$ymd %in% Prices$Time)] = Prices$bit.x
dayData$bitfinex[which(dayData$ymd %in% Prices$Time)] = Prices$bitfinex
dayData$coinebase[which(dayData$ymd %in% Prices$Time)] = Prices$coinbase
dayData$kraken[which(dayData$ymd %in% Prices$Time)] = Prices$kraken
dayData$AvgPrice[which(dayData$ymd %in% Prices$Time)] = apply(Prices[,-1],1, mean, na.rm = TRUE)

#Creates miner revenue related data, including average work per day and revenue
dayData$Work = WORK_PER_DIFF * dayData$difficulty * dayData$numBlocks
dayData$revenuePerDay = (dayData$numBlocks * dayData$rewardPerBlock + dayData$transactionFees)*dayDat$AvgPrice
dayData$revenuePerGH =dayData$revenuePerDay / (dayDat$Work / GIGAHASH)


write.csv(dayData, outputFileName, row.names = FALSE)
