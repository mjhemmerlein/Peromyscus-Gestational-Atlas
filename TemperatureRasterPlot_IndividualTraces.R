library(lubridate)
library(ggplot2)
library(cetcolor)
library(dplyr)

test <- read.csv("CleanedTempFiles/INDIVIDUAL_FILE_NAME_HERE.csv")
dates <- read.csv("MetaData_forTemperatureExperiments.csv", header = TRUE)

ID <- test$Tag.ID[1]
test$startDate <- dates$StartDate[which(dates$PT.ID==ID)]
test$startDate  <- as.POSIXct(test$startDate, tz = "MST", format = "%m/%d/%Y %H:%M")
test$DT <- as.POSIXct(test$DT)

##bin data
test$pTRC <- interval(test$startDate, test$DT)
test$HoursFromStart <- time_length(test$pTRC, "hour")
test$HoursFromStartRounded <- floor(test$HoursFromStart)
test$MinsFromStart <- time_length(test$pTRC, "minute")
test$MinsFromStartRounded <- floor(test$MinsFromStart)

test$MinuteofHour <- format(test$DT, "%M")
test$MinCorr <- NA
test$MinCorr[which(test$MinuteofHour<20)] <- 0
test$MinCorr[which(test$MinuteofHour>39)] <- 40
test$MinCorr[which(is.na(test$MinCorr))] <- 20

test$uniquetest <- paste(test$HoursFromStartRounded, test$MinCorr)
length(unique(test$uniquetest))

binned1 <- test %>% 
  group_by(Tag.ID,HoursFromStartRounded,MinCorr) %>%
  summarise(Temp = min(Temp),
            StartDate = min(startDate),
            minsFromStartRounded = min(MinsFromStartRounded),
            DT = min(DT))

min(binned1$Temp)
max(binned1$Temp)

##convert to minutes in the day
binned1$altMinsFrom <- (binned1$HoursFromStartRounded*60)+(binned1$MinCorr)

binned1$altSecsFrom <- binned1$altMinsFrom*60
binned1$Time <- as.POSIXct(binned1$altSecsFrom, origin="2023-01-01", tz = "MST")
binned1$TimeCorr <- binned1$Time + hours(19)

binned1$xaxis <- as.Date(binned1$TimeCorr, format='%d%m%y', tz = "MST")

binned1$minuteOfDay <- (as.numeric(format(binned1$TimeCorr, "%H"))*60)+ as.numeric((format(binned1$TimeCorr, "%M")))

ggplot(data = binned1) + 
  geom_raster(aes(x=as.Date(TimeCorr, format='%d%m%y', tz = "MST"), y=minuteOfDay, fill=Temp)) + 
  scale_fill_gradientn(colours = (cet_pal(6, name = "inferno")),
                       na.value = "transparent",
                       breaks=c(35,37,39),labels=c(35,37,39),
                       limits=c(33.9,40))
