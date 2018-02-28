rm(list = ls())
D = read.csv("C:/Users/seric/Dropbox/CU Boulder/Bitcoin/crypto-hotelling/Data/dataByDay.csv")
D$date = as.Date(D$ymd, "%Y-%m-%d")
halvings = c(which(D$rewardPerBlock == 25)[1], which(D$rewardPerBlock == 12.5)[1])

LWD = 3
#
MA_length = 30
MA_sides = 2

D$Price_MA = filter(D$AvgPrice, rep(1/MA_length, MA_length), sides = MA_sides)
D$work_MA = filter(D$Work, rep(1/MA_length,MA_length), sides = MA_sides)
D$revenuePerGH_MA = filter(D$revenuePerGH, rep(1/MA_length, MA_length), sides = MA_sides)
D$workDiff = c(NA, D$Work[-1] - D$Work[-nrow(D)])
D$workDiff_MA = filter(D$workDiff, rep(1/MA_length, MA_length), sides = MA_sides)
#
D$PriceDiff = c(NA, D$AvgPrice[-1] - D$AvgPrice[-nrow(D)])
D$PriceDiff_MA = filter(D$PriceDiff, rep(1/MA_length, MA_length), sides = MA_sides)
#
rnge = which(D$year == 2016)
D1 = D[rnge, ]

plot(D1$date, D1$AvgPrice, type = "l", lwd = LWD)
lines(D1$date, D1$Price_MA, col = "red", lwd = LWD)
#

plot(D1$date, D1$Price_MA, lwd = LWD, type = "l")
par(new = T)
plot(D1$date, D1$work_MA, lwd = LWD, type = "l", col = "red")
#
par(new = TRUE)
plot(D1$date, D1$revenuePerGH_MA, lwd = LWD, col = "blue", type = "l")
#

rnge = which(D$year > 2014 & D$year < 2017)
# rnge = rnge[1:(length(rnge)-50)]
D1 = D[rnge, ]
plot(D1$date, D1$revenuePerGH_MA, lwd = LWD, col = "blue", type = "l")
par(new = T)
plot(D1$date, D1$Price_MA, lwd = LWD, type = "l")
abline(v = D$date[halvings[2]])
#


#

abline(0,0)

plot(D1$date, D1$PriceDiff_MA, type = "l")
abline(0,0)
par(new = TRUE)
plot(D1$date, D1$workDiff_MA, type = "l", col = "red")
##
plot(D1$workDiff_MA, D1$PriceDiff_MA)


rnge = which(D$year == 2016 )
D1 = D[rnge, ]
plot(D1$date, log(D1$revenuePerGH_MA), type = "l")
abline(v = D$date[halvings[2]])

plot(D1$date, log(D1$work_MA30), type = "l")
abline(v = D$date[halvings[2]])
#
par(new = TRUE)
plot(D1$date, log(D1$Price_MA), type = "l", lty = 2, xlab = "", ylab = "", xaxt = "n", yaxt = "n")

par(new = TRUE)
plot(D1$date, log(D1$AvgPrice), type = "l", lty = 2, xlab = "", ylab = "", xaxt = "n", yaxt = "n", col = "red")
