rm(list = ls())

fileName = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/Prices/BitcoinCharts API data/bitfinexUSD.csv"
outputFileName = "C:/Users/sean/Dropbox/CU Boulder/Bitcoin/Data/Prices/AggregatedData/Hourly Bitfinex.csv"


D = read.csv(fileName, header = FALSE, col.names = c("unixTime","price","volume"))
head(D)

D$Time = as.POSIXct(D$unixTime, origin = "1970-01-01")

D$year = format(D$Time, "%y")
D$month =format(D$Time, "%m")
D$day = format(D$Time, "%d")
D$hour = format(D$Time, "%H")

D$hourlyTime = paste(D$year,"/", D$month,"/", D$day,":", D$hour, sep = "")
##
COLNAMES = c("hourlyTime", "year", "month", "day", "hour", "price", "volumeBTC")
H = as.data.frame(matrix(nrow = length(unique(D$hourlyTime)), ncol = length(COLNAMES)))
colnames(H) = COLNAMES
#
firstHourRows = which(!duplicated(D$hourlyTime))
H[, c("hourlyTime", "year", "month", "day", "hour")] = D[firstHourRows, c("hourlyTime", "year", "month", "day", "hour")]
##
years = unique(D$year)
months = unique(D$month)
for(y in years) {
  for(m in months) {
    print(paste("year:",y, "month:", m))
    Dsub = D[which(D$year == y & D$month == m), ]
    hSub = which(H$year == y & H$month == m)
    H$price[hSub] = sapply(H$hourlyTime[hSub], function(x) mean(Dsub$price[which(Dsub$hourlyTime == x)]))
    H$volumeBTC[hSub] = sapply(H$hourlyTime[hSub], function(x) sum(Dsub$volume[which(Dsub$hourlyTime == x)]))
  }
}


H$price = unlist(H$price)
H$volumeBTC = unlist(H$volumeBTC)
H$volumeUSD = H$volumeBTC * H$price


write.csv(H, outputFileName, row.names = FALSE)
