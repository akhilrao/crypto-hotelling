rm(list = ls())
setwd("C:/Users/seric/Dropbox/CU Boulder/Bitcoin/Data/Year Data")
##
files = list.files()
library(plyr)
D = ldply(files[7:9], read.csv, as.is = TRUE)

D$Time = as.POSIXct(D$Time, "%y/%m/%d %H:%M")
D$TimeDiff = c(NA, sapply(2:nrow(D), function(x) difftime(D$Time[x], D$Time[x-1], units = "mins")))
##
D$difficultyChange = c(0, sapply(2:nrow(D), function(x) ifelse(D$difficulty[x] == D$difficulty[x-1], 0, 1)))
D$difficultyChange[c(30051,30053)] = 0 #Data error requires change
difficultyChangePeriods = which(D$difficultyChange == 1)
##
getMinFromLastincrease = function(x, changePeriods) {
  if(x < min(changePeriods)) {
    return(NA)
  } else {
    period = changePeriods[which(changePeriods <= x)]
    period = period[length(period)]
    return(as.numeric(difftime(D$Time[x], D$Time[period], units = "mins")))
  }
}
#
D$minutesFromLastDifficultyIncrease = sapply(1:nrow(D), getMinFromLastincrease, difficultyChangePeriods)
D$daysFromLastDifficultyIncrease = D$minutesFromLastDifficultyIncrease / (60*24)
#
L1 = lm(D$TimeDiff ~ D$daysFromLastDifficultyIncrease)
summary(L1)
#
plot(D$daysFromLastDifficultyIncrease, D$TimeDiff, pch = 19, col = rgb(1,1,1,.5))
