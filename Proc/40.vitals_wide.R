# source('40.vitals_wide.R',echo=TRUE)
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/Proc')
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
#install.packages('vioplot')
#install.packages('ggplot2')
library(vioplot)
library(Hmisc)
library(ggplot2)
library(gdata)
load('../Data/ds1_vitals.RData')

ds1_vitals$seq<-sequence(rle(ds1_vitals$studyid)$length)
vitals<-ds1_vitals[,c("studyid","test_date","test_name","dob","ageyears","sys","dias","bmi","height","weight","seq" )]
vitals_short<-vitals[vitals$seq < 20,]
wide<-reshape(vitals_short,idvar=c("studyid","test_date","test_name","dob","ageyears"),timevar='seq',direction="wide")
dim(wide)
names(wide)
ages<-wide[,c('studyid','ageyears')]
head(ages)
table(round(ages$ageyears))
hist(round(ages$ageyears))
agg_vitals<-aggregate(ageyears ~ studyid,data=ds1_vitals,min)
hist(round(agg_vitals$ageyears))
age_tab<-table(round(agg_vitals$ageyears))
png('AgeFirstVisit.png')

plot(round(prop.table(age_tab),2)[1:33]*100,main="Age at first recorded visit",
   xlab="Age (years)",ylab="Percentage of cases",type='b')
mtext("Age data taken from SD vital signs measurements.",side=1,line=4)

dev.off()
#
#number of visits
#
#
visits<-aggregate(seq ~ studyid,data=vitals,FUN=max)
boxplot(visits$seq)
summary(visits$seq)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0    16.0    51.0   157.1   145.0  4741.0 
