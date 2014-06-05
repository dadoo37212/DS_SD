# 60Hamza_long.R  DEPRECIATED
# source('60Hamza_long.R',echo=TRUE)

rm(list=ls())

START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
rm(START)

library(Hmisc)
library(knitr)
library(gdata)
library(rms)
library(gdata)
library(stringr)
library(RMySQL)

#source('~/Dropbox/Projects/R/getids.R')
#=-=-=-=-=-=-=-=-=
load("../Data/cpt.RData")
load('../Data/demo_v30.RData')
#
# cpt
#
hamza<-cpt[cpt$agedays< 366 & cpt$agedays >= 0,c('studyid','code','agedays')]
hamza <- hamza[order(hamza$studyid,hamza$agedays),]
hamza <- hamza[!is.na(hamza$studyid),]
key<-"studyig"
hamza$key <- unlist(tapply(hamza[[key]], hamza[[key]], FUN=function(x) seq(length(x))))
#hamza <-getids('studyid',hamza)
hamza<-subset(hamza,hamza$key < 366)

save(hamza,file='../Data/hamza.RData') #1,116
write.csv(hamza,file='../Data/hamza.csv')

id<-as.data.frame(demo_v30$studyid)
names(id)<-'studyid'
hamza_v30<-merge(hamza,id,by='studyid')  #151
#
#
#
#
save(hamza_v30,file='../Data/hamza_v30.RData')
write.csv(hamza_v30,file='../Data/hamza_v30.csv')
#
# icd
#
load('../Data/icd.RData')
hamza_icd<-icd[icd$agedays< 366 & icd$agedays >= 0,c('studyid','code','agedays')]
hamza_icd <- hamza_icd[order(hamza_icd$studyid,hamza_icd$agedays),]
hamza_icd <- hamza_icd[!is.na(hamza_icd$studyid),]
hamza_icd$key <- unlist(tapply(hamza_icd[[key]], hamza_icd[[key]], FUN=function(x) seq(length(x))))
#hamza_icd <-getids('studyid',hamza_icd)
hamza_icd<-subset(hamza_icd,hamza_icd$key < 366)
hamza_icd$code_n<-as.numeric(hamza_icd$code)

save(hamza_icd,file='../Data/hamza_icd.RData') #100,006
write.csv(hamza_icd,file='../Data/hamza_icd.csv')
id<-as.data.frame(demo_v30$studyid) #153
names(id)<-'studyid'
hamza_icd_v30<-merge(hamza_icd,id,by='studyid')  #22,723  153 unique studyid's
save(hamza_icd_v30,file='../Data/hamza_icd_v30.RData')
write.csv(hamza_icd_v30,file='../Data/hamza_icd_v30.csv')

#
# birth weight
#
load('../Data/ds1_vitals.RData')
vitals7<-ds1_vitals[ds1_vitals$agedays <= 7,]
vitals7_v30<-merge(vitals7,id,by='studyid')  #22,723  153 unique studyid's
vitals7_v30<-vitals7_v30[!is.na(vitals7_v30$weight),]
vitals7_v30$weight<-as.numeric(vitals7_v30$test_value,7)

weight<-vitals7_v30[,c('studyid','weight','agedays')]
weight<-weight[order(weight$studyid,weight$agedays),]
key<-'studyid'
weight$key <- unlist(tapply(weight[[key]], weight[[key]], FUN=function(x) seq(length(x))))

zeropad<-function(i){
ic<-as.character(i)
ic<-paste('000',ic,sep="")
g<-substr(ic,nchar(ic)-1,nchar(ic))
g
}
weight$key<-zeropad(weight$key)
weight<-rename.vars(weight,c('weight','agedays'),c('w','d'))
weight_wide<-reshape(weight,idvar='studyid',timevar='key',direction='wide')
weight_wide<-weight_wide[,order(names(weight_wide))]

save(weight,file='../Data/weight.RData')
write.csv(weight,file='../Data/weight.csv')
save(weight_wide,file='../Data/weight_wide.RData')
write.csv(weight_wide,file='../Data/weight_wide.csv')

#
# episodes
#

rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)

#source('~/Dropbox/Projects/R/getids.R')
source('~/Dropbox/Projects/R/episodes.R')
load('../Data/weight.RData')
load('../Data/weight_wide.RData')
ww<-weight_wide
key<-ww[,c(1:18)]
weight_wide_episodes<-episodes(key,ww)

