# 80bwgt.R
# source('80bwgt.R',echo=TRUE)
rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)
library(knitr)
library(gdata)
library(rms)
library(gdata)
library(stringr)
library(RMySQL)
mdy<-function(date){
month<-as.numeric(format(date,"%m"))
day<-as.numeric(format(date,"%d"))
year<-as.numeric(format(date,"%Y"))
return(list(year=year,month=month,day=day))
}
#tmp<-mdy(ds1_demo$dob) 

getDOB<-function(demo,set){
g<-demo[,c('studyid','dob')]
return(merge(set,g,by='studyid'))
}
#
# DS1_demo studyid, gender, race,dob,deceased
#
bwgt<-read.csv('../Data/Txt/bwgt.txt',as.is=TRUE,
colClasses=c('integer','character','character','character','character'))
names(bwgt)<-tolower(names(bwgt))
bwgt$bwgt<-as.numeric(bwgt$bwgt)
bwgt$wgt<-bwgt$bwgt
bwgt$wgt<-ifelse(bwgt$unit=='kg',bwgt$wgt*1000,bwgt$wgt)
bwgt$wgt<-ifelse(bwgt$unit=='lb',bwgt$wgt*453.592,bwgt$wgt)
#table(bwgt$wgt,bwgt$unit)

bwgt[bwgt$unit=='kg',]
bwgt[bwgt$unit=='lb',]
bwgt[bwgt$unit=='g',]
bwgt$bwgt<-NULL
bwgt<-rename.vars(bwgt,'wgt','bwgt')
names(bwgt)

# studyid        code agedays key ep group
b2<-bwgt[,c(1,5)]
b2$code<-bwgt$bwgt
b2$agedays<-0
b2$key<-'01'
b2$ep<-1
b2$group<-'bwgt'
b2$bwgt<-NULL
bwgt<-b2
save(bwgt,file='../Data/bwgt.RData')
write.csv(bwgt,file='../Data/bwgt.csv')
