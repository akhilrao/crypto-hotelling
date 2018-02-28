D = read.csv("C:/Users/seric/Dropbox/CU Boulder/Bitcoin/crypto-hotelling/Data/dataByDay.csv")
D$date = as.Date(D$ymd, "%Y-%m-%d")
halvings = c(which(D$rewardPerBlock == 25)[1], which(D$rewardPerBlock == 12.5)[1])

LWD = 3



makePlots = function(rnge, halfTime, yearLab = "Date") {
  plot(D$date[rnge], D$revenuePerDay[rnge]/1000, type = "l", xlab = yearLab, ylab = "Total Mining Revenue Per Day ($1000/day)", lwd = LWD)
  # abline(v = D$date[hDate])
  
  

  
  
  plot(D$date[rnge], D$Work[rnge], type = "l", xlab = yearLab, ylab = "Average Work (Gh/Block)", lwd = LWD)
  abline(v = D$date[halfTime], lty = 2, lwd = LWD)
  #
  plot(D$date[rnge], D$difficulty[rnge], type = "l", xlab = yearLab, ylab = "difficulty", lwd = LWD)
  abline(v = D$date[halfTime], lwd = LWD, lty = 2)
  #
  par(mar = c(5,4,4,4) + 0.1)
  plot(D$date[rnge], D$revenuePerGH[rnge], type = "l", xlab = yearLab, ylab = "Revenue per average work ($/Gh)", lwd = LWD)
  par(new = TRUE)
  plot(D$date[rnge], D$AvgPrice[rnge], type = "l", xlab = "", ylab = "", xaxt = "n", yaxt = "n", lty = 2, lwd = LWD, col = "red")
  axis(4); mtext("Bitcoin Price", side = 4, line = 2 )
  legend("topleft", legend = c("revenue per average work", "bitcoin price"), col = c(1,2), lwd = LWD)
}


N = 100; start = halvings[1] - N; end = halvings[1] + N
rnge = start:end
makePlots(rnge, halvings[1], yearLab = "Years = 2012:2013")



start = which(D$year == 2016)[1]; end = which(D$year == 2017)[1]
rnge = start:end

makePlots(rnge,halvings[2], yearLab = "Year = 2016")
####





rnge = which(format(D$date,"%Y") %in% c(2016,2017))
D1 = D[rnge, ]
plot(D1$date, D1$revenuePerGH, type = "l")
par(new = TRUE)
plot(D1$date, D1$AvgPrice,xlab = "",ylab = "", xaxt = "n", yaxt = "n", col = "red", type = "l")
axis(4)
#
plot(D1$date, D1$Work, type = "l")
par(new = TRUE)
plot(D1$date, D1$AvgPrice)
