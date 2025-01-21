library(ggplot2)
library(lubridate)
library(tidyverse)
library(dplyr)
library(cetcolor)
library(lme4) 
library(emmeans) 
library(lmerTest)

dates <- read.csv("Raw_Data/MetaData_forTemperatureExperiments.csv", header = TRUE)

# extract min/max temps per dam per day --------------------------------------------
test <- read.csv("individualCleanedTempFile.csv")   ## <- you must enter the file name here for each individual
                                                    ##    temperature file that has ALREADY been cleaned.

ID <- test$Tag.ID[1]
test$concDate <- dates$PredictedConceptionDate[which(dates$PT.ID==ID)]
test$concDate  <- as.POSIXct(test$concDate, tz = "MST", format = "%m/%d/%Y %H:%M")
test$concDate <- test$concDate + years(2000)
test$DT <- as.POSIXct(test$DT)

test$pTRC <- interval(test$concDate, test$DT)
test$DaysFromConc <- time_length(test$pTRC, "day")
test$DaysFromConcRounded <- floor(test$DaysFromConc)
test$HourOfDay <- format(test$DT, "%H")

binned1 <- test %>% 
  group_by(Tag.ID,DaysFromConcRounded) %>%
  summarise(minTemp = min(Temp),
            maxTemp = max(Temp),
            concDate = min(concDate),
            DT = min(DT))

## this next line uses row bind to combine all values for individuals.
m <- rbind(m, binned1)

## after running this for each individual, we saved the compiled file,  -------------------------------------------- 
##    which is a long-form dataset with all daily min/max temp values
##    for each female. we've provided the resulting data set in on the
##    github page. 
write.csv(m, "Raw_Data/LongForm_DailyMinMax.csv")

## if you read in the longform file, you can pick up from here!  ---------------------------------------------------

m <- read.csv("Raw_Data/LongForm_DailyMinMax.csv")
m$ExpBlock <- NA
m$ExpBlock[which(m$DaysFromConcRounded < 0)] <- "1_PreCopulation"               ##up to 10 days
m$ExpBlock[which(between(m$DaysFromConcRounded, 1, 6))] <- "2_EarlyPreg_PreImpl"##5 days
m$ExpBlock[which(between(m$DaysFromConcRounded, 6, 21))] <- "3_MidPreg"         ##15 days
m$ExpBlock[which(between(m$DaysFromConcRounded, 21, 24))] <- "4_LatePreg"       ##3 days
m$ExpBlock[which(between(m$DaysFromConcRounded, 24, 35))] <- "5_Lac"            ##11 days
m$ExpBlock[which(m$DaysFromConcRounded > 35)] <- "6_Weaning"

ggplot(m, aes(x = ExpBlock, y = minTemp)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(x = ExpBlock, y = minTemp), alpha = 0.4, width = 0.2) +
  scale_y_continuous(limits = c(33, 41), breaks = seq(33, 41, by = 0.5))

ggplot(m, aes(x = ExpBlock, y = maxTemp)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(x = ExpBlock, y = maxTemp), alpha = 0.4, width = 0.2) +
  scale_y_continuous(limits = c(33, 41), breaks = seq(33, 41, by = 0.5))

t <- lmer(minTemp ~ ExpBlock + (1|Tag.ID), data = m)
pairs(emmeans(t, ~ExpBlock))

t <- lmer(maxTemp ~ ExpBlock + (1|Tag.ID), data = m)
pairs(emmeans(t, ~ExpBlock))
