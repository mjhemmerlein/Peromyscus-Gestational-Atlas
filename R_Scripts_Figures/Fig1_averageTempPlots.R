library(ggplot2)
library(lubridate)
library(tidyverse)
library(dplyr)
library(cetcolor)

# Figure 1a ----------

m <- read.csv("Raw_Data/AllMerge.csv", header = TRUE)
tempsOnly <- m[,grep(pattern = "Temp*", names(m))]

tempsOnly$NAcount <- rowSums(is.na(tempsOnly))
tempsOnly$N <- 9-tempsOnly$NAcount
tempsOnly$avgTemp <- rowMeans(tempsOnly[,c(1:9)], na.rm=TRUE)
tempsOnly <- transform(tempsOnly, SD=apply(tempsOnly[,c(1:9)], 1, sd, na.rm = TRUE))
tempsOnly$SE <- (tempsOnly$SD/sqrt(tempsOnly$N))
tempsOnly$lowCI <- tempsOnly$avgTemp-(tempsOnly$SD*1.95)
tempsOnly$highCI <- tempsOnly$avgTemp+(tempsOnly$SD*1.95)

all <- cbind(m, tempsOnly[,c(11:16)]) 
#write.csv(all, "AllMerge_wSummaryStats.csv")

#limit to 10 days before copulation
all <- read.csv("AllMerge_wSummaryStats.csv")
all$HoursFromConctoPlot <- all$altMinsFrom/60
sh <- all[which(all$HoursFromConctoPlot>-240),]
sh <- sh[which(sh$HoursFromConctoPlot<1093),]

##LINE PLOT
ggplot(sh) +
  geom_line(aes(x = altMinsFrom, y = avgTemp)) +
#  geom_line(aes(x = altMinsFrom, y = lowCI, colour = "blue")) +
#  geom_line(aes(x = altMinsFrom, y = highCI, colour = "red")) +
  labs(x = "Time", y = "Average Temperature") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Figure 1b ----------

##RASTER PLOT

sh$altSecsFrom <- sh$altMinsFrom*60
sh$Time <- as.POSIXct(sh$altSecsFrom, origin="2023-03-01", tz = "MST")
sh$TimeCorr <- sh$Time + hours(19)

sh$xaxis <- as.Date(sh$TimeCorr, format='%d%m%y', tz = "MST")

sh$minuteOfDay <- (as.numeric(format(sh$TimeCorr, "%H"))*60)+ as.numeric((format(sh$TimeCorr, "%M")))

ggplot(data = sh) + 
  geom_raster(aes(x=as.Date(TimeCorr, format='%d%m%y', tz = "MST"), y=minuteOfDay, fill=avgTemp)) + 
  scale_fill_gradientn(colours = (cet_pal(6, name = "l4")))

