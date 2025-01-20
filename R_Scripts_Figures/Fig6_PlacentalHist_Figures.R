library(ggplot2)
library(tidyverse)
library(readxl)
library(lme4) 
library(emmeans) 
library(lmerTest)
library(data.table)

# Figure 6 ---------

d <- read.csv("Raw_Data/ZoneVol_master.csv", header = TRUE)

VolumeInfo = d %>%
  group_by(Pair_ID, Implantation_Site, Day_of_Gestation) %>%
  summarise(Dec = mean(Decidua_area),
            JZ = mean(Junctional_area),
            LZ = mean(Labyrinth_area),
            Order = min(Order))

longVol <- melt(setDT(VolumeInfo), id.vars = colnames(VolumeInfo)[c(1:3,7)], variable.name = "volume")
longVol$UniqueID <- as.factor(paste(longVol$Day_of_Gestation, longVol$Order, longVol$Pair_ID, longVol$Implantation_Site))

ggplot(longVol, aes(fill=volume, y=value, x=UniqueID)) + 
  geom_bar(position="stack", stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 

ggplot(longVol, aes(fill=volume, y=value, x=UniqueID)) + 
  geom_bar(position="fill", stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))







