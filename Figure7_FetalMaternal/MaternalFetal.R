library(ggplot2)
library(tidyverse)
library(readxl)
library(lme4) 
library(emmeans) 
library(lmerTest)
library(data.table)

# Figure 7 ---------

##MFBS
mfbs <- read.csv("Raw_Data/MFBS_master.csv", header = TRUE)
mfbs <- mfbs[-which(is.na(mfbs$Abs_FBS)),]
mfbs$Day_of_Gestation <- as.factor(mfbs$Day_of_Gestation)

mfbs_volABS = mfbs %>%
  group_by(Pair.ID, Implantation.Site, Day_of_Gestation) %>%
  summarise(absMat = mean(Abs_MBS),
            absTissue = mean(Abs_Tiss) + mean(Abs_nucl),
            absFet = mean(Abs_FBS),
            Order = min(Order)
  )

ABSmfbs_longVol <- melt(setDT(mfbs_volABS), id.vars = colnames(mfbs_volABS)[c(1:3,7)], variable.name = "volume")
ABSmfbs_longVol$UniqueID <- as.factor(paste(ABSmfbs_longVol$Day_of_Gestation, 
                                            ABSmfbs_longVol$Order, 
                                            ABSmfbs_longVol$Pair.ID, 
                                            ABSmfbs_longVol$Implantation.Site))

ggplot(ABSmfbs_longVol, aes(fill=volume, y=value, x=UniqueID)) + 
  geom_bar(position="stack", stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))