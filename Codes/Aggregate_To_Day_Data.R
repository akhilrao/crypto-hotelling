#create daily dataset
rm(list = ls())
setwd("C:/Users/seric/Dropbox/CU Boulder/Bitcoin/Data/Year Data")
##
files = list.files()
library(plyr)
D = ldply(files, read.csv, as.is = TRUE)
D$ymd = trunc(as.POSIXct(D$Time, "%y/%m/%d"), "days")
# D$difficultyChange = c(0, sapply(2:nrow(D), function(x) ifelse(D$difficulty[x] == D$difficulty[x-1], 0, 1)))
# D$difficultyChange[c(30051,30053)] = 0 #Data error requires change
#
dayData = as.data.frame(unique(D$ymd))
names(dayData) = "ymd"
dayData$year = as.numeric(paste("20",format(dayData$ymd, "%y"),sep = ""))
dayData$month = as.numeric(format(dayData$ymd, "%m"))
dayData$day = as.numeric(format(dayData$ymd, "%d"))
#
years = unique(D$Year)
months = unique(D$month)
##
dayData$numBlocks = 0
dayData$difficulty = 0
dayData$rewardPerBlock = 0
dayData$transactionFees = 0 
dayData$difficultyChange = 0

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
##
dayData$numBlocks = unlist(dayData$numBlocks)
dayData$difficulty = unlist(dayData$difficulty)
dayData$rewardPerBlock = unlist(dayData$rewardPerBlock)
dayData$transactionFees = unlist(dayData$transactionFees)

dayData$difficultyChange = c(0, sapply(2:nrow(dayData), function(x) ifelse(dayData$difficulty[x] == dayData$difficulty[x-1], 0, 1)))





# dayData = read.csv("../dataByDay.csv", as.is = TRUE)
Prices = read.csv("../prices/Prices from  Bitcoinity.csv", as.is = TRUE)
Prices$Time = trunc(as.POSIXct(Prices$Time, "%y-%m-%d %H:%M:%S"), "days")
Prices = Prices[which(Prices$Time %in% dayData$ymd), ]
#
dayData$bitX =  NA; dayData$bitfineX = NA; dayData$coinbase = NA; dayData$kraken = NA; dayData$AvgPrice = NA
dayData$bitx[which(dayData$ymd %in% Prices$Time)] = Prices$bit.x
dayData$bitfinex[which(dayData$ymd %in% Prices$Time)] = Prices$bitfinex
dayData$coinebase[which(dayData$ymd %in% Prices$Time)] = Prices$coinbase
dayData$kraken[which(dayData$ymd %in% Prices$Time)] = Prices$kraken
dayData$AvgPrice[which(dayData$ymd %in% Prices$Time)] = apply(Prices[,-1],1, mean, na.rm = TRUE)


workPerDiff = 4295032833 #Relates difficulty to average hashrate
dayData$Work = workPerDiff * dayData$difficulty * dayData$numBlocks
dayData$revenuePerDay = (dayData$numBlocks * dayData$rewardPerBlock + dayData$transactionFees)*dayDat$AvgPrice
dayData$revenuePerGH =dayData$revenuePerDay / (dayDat$Work / 1e9)


write.csv(dayData, "../dataByDay.csv", row.names = FALSE)
