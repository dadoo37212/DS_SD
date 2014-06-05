# 60join.R
# source('60join.R',echo=TRUE)
#join icd birth to cpt
#icd=v30 v31, cpt=844.43
rm(list=ls())
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
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

load("../Data/demo_v30.RData")
load("../Data/hamza_icd_v30_ep.RData")
load("../Data/hamza_cpt_v30.RData")
source('~/Dropbox/Projects/R/zeropad.R')

icd_birth<-hamza_icd_v30_ep[substr(hamza_icd_v30_ep$code,1,3) %in% c('V30','V31'),]
#V30.00 V30.01 V30.10 V31.00 V31.01 
#   148    100      2      1      6  257
#
icd_birth_df<-with(icd_birth,as.data.frame(table(studyid))) #159
dim(icd_birth[!duplicated(icd_birth$studyid),])  #159
#icd_birth[icd_birth$studyid==23273092,]

cpt84443<-hamza_cpt_v30[hamza_cpt_v30$code=='84443',]
cpt84443_df<-as.data.frame(table(cpt84443$studyid))
cpt84443$key<-zeropad(cpt84443$key)
gg<-cpt84443

gg<-gg[order(gg$studyid,gg$agedays),c('studyid','agedays','key')]
head(gg,n=50)
gg<-gg[order(gg$studyid,gg$key),]
gg<-rename.vars(gg,'agedays','d')
tsh_wide<-reshape(gg,idvar='studyid',timevar='key',direction='wide')
tsh_wide<-tsh_wide[,order(names(tsh_wide))]
head(tsh_wide)

#gg<-icd[substr(icd$code,1,3) %in% c('758','758.0') & icd$agedays < 30,]
#gg<-gg[!is.na(gg$studyid),]  #3134

gg<-icd[icd$code =='758' | substr(icd$code,1,5) =='758.0' & icd$agedays < 30,]
gg<-gg[!is.na(gg$studyid),]  #3347
dim(gg)

gg<-gg[order(gg$studyid,gg$code_date),c('studyid','agedays','ageyears','code_date')]
gg<-getids('studyid',gg)
head(gg,n=50)
gg<-gg[,order(names(gg))]

ds_wide<-reshape(gg,idvar='studyid',timevar='key',drop=c('ageyears','code_date'),direction='wide')
ds_wide<-ds_wide[,order(names(ds_wide))]

head(ds_wide)

ds_first<-subset(ds_wide,select=c(1,2))
ds_first<-rename.vars(ds_first,'agedays.1','dsfirst')
tsh_ds<-merge(ds_first,tsh_wide,by='studyid')
tsh_ds<-tsh_ds[,c(1,2,3,4,5,6,7,8,9,10)]
tsh_ds<-rename.vars(tsh_ds,c('agedays.1', 'agedays.2','agedays.3', 'agedays.4', 'agedays.5','agedays.6','agedays.7','agedays.8'),c('tsh.1','tsh.2','tsh.3','tsh.4',
'tsh.5','tsh.6','tsh.7','tsh.8'))
