# 65v30.R
# source('65v30.R',echo=TRUE)
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
source('~/Dropbox/Projects/R/getids.R')
source('~/Dropbox/Projects/R/group_concat.R')

library(Hmisc)
library(gdata)

load("../Data/icd_v30.RData")
load("../Data/cpt_v30.RData")
load("../Data/demo_v30.RData")
#
# ds1_demo      2424 -- all records
# demo          2136 -- only ds == 1 
# demo_v30       163 -- demo records with one or more v30 icd 
# cpt_v30      61018 -- merged demo_v30 and all cpt
# icd_v30_all  75027 -- icd records for demo_v30
# icd_cpt_v30 136045 -- row bind of icd_v30_all and cpt_v30
#  variable 'grp' indicates if icd_cpt_v30 came from cpt or icd
#  
icd_v30_df<-as.data.frame(table(icd_v30$studyid))
icd_v30_df$Freq<-NULL
icd_v30_df<-rename.vars(icd_v30_df,'Var1','studyid')

icd_v30_all<-merge(icd,icd_v30_df,by='studyid')

icd_v30_all<-remove.vars(icd_v30_all,c('icd_grp','icd_grp_desc'))
names(icd_v30_all)
names(cpt_v30)
icd_v30_all$grp<-"icd"
cpt_v30$grp<-"cpt"
#
#rbind cpt_v30 icd_v30_all
#
cpt1<-cpt_v30[,c('studyid','code','agedays')]
names(cpt1)<-c('studyid','cpt','cptdays')
icd1<-icd_v30_all[,c('studyid','code','agedays')]
names(icd1)<-c('studyid','icd','icddays')

#
# recode days into groups of day
#
icd1$d<-icd1$icdday
icd1$d<-ifelse(icd1$icdday>7679,  '30',icd1$d) #21+ yrs
icd1$d<-ifelse(icd1$icdday>4383 & icd1$icdday<= 7679,  '29',icd1$d) #13-20 yrs
icd1$d<-ifelse(icd1$icdday> 365 & icd1$icdday<= 4383,  '28',icd1$d) #1 -5
icd1$d<-ifelse(icd1$icdday> 120 & icd1$icdday<=  365,  '24',icd1$d) #4
icd1$d<-ifelse(icd1$icdday>  90 & icd1$icdday<=  120,  '23',icd1$d) #3
icd1$d<-ifelse(icd1$icdday>  60 & icd1$icdday<=   90,  '22',icd1$d) #2
icd1$d<-ifelse(icd1$icdday>  30 & icd1$icdday<=   60,  '21',icd1$d) #1
icd1$d<-ifelse(icd1$icdday %in% c(10:29), as.character(icd1$icdday), icd1$d )#1
icd1$d<-ifelse(icd1$icdday %in% c(0:9), paste('0',as.character(icd1$icdday),sep=""), icd1$d) #1
icd1$d<-ifelse(icd1$d< 0,NA,icd1$d)     #days

cpt1$d<-cpt1$cptday
cpt1$d<-ifelse(cpt1$cptday>7679,  '30',cpt1$d) #21+ yrs
cpt1$d<-ifelse(cpt1$cptday>4383 & cpt1$cptday<= 7679,  '29',cpt1$d) #13-20 yrs
cpt1$d<-ifelse(cpt1$cptday> 365 & cpt1$cptday<= 4383,  '28',cpt1$d) #1 -5
cpt1$d<-ifelse(cpt1$cptday> 120 & cpt1$cptday<=  365,  '24',cpt1$d) #4
cpt1$d<-ifelse(cpt1$cptday>  90 & cpt1$cptday<=  120,  '23',cpt1$d) #3
cpt1$d<-ifelse(cpt1$cptday>  60 & cpt1$cptday<=   90,  '22',cpt1$d) #2
cpt1$d<-ifelse(cpt1$cptday>  30 & cpt1$cptday<=   60,  '21',cpt1$d) #1
cpt1$d<-ifelse(cpt1$cptday %in% c(10:29), as.character(cpt1$cptday), cpt1$d) #1
cpt1$d<-ifelse(cpt1$cptday %in% c(0:9), paste('0',as.character(cpt1$cptday),sep=""), cpt1$d) #1
cpt1$d<-ifelse(cpt1$d< 0,NA,cpt1$d)     #days


cpt1<-cpt1[order(cpt1$studyid,cpt1$cptday),]
icd1<-icd1[order(icd1$studyid,icd1$icdday),]
#
# start cpt2 here
#
cpt2<-getids('studyid',cpt1)
icd2<-getids('studyid',icd1)

names(icd2);names(cpt2)

cpt2<-remove.vars(cpt2,'d')
icd2<-remove.vars(icd2,'d')
names(icd2);names(cpt2)

cpt2<-rename.vars(cpt2,'cptdays','d')
icd2<-rename.vars(icd2,'icddays','d')
head(icd2);head(cpt2)

#reshape
cpt2<-subset(cpt2,d <=1100)  #3 years
icd2<-subset(icd2,d <=1100)  #3 years
cpt2<-subset(cpt2,d >= 0)  # positive
icd2<-subset(icd2,d >= 0)  # positive

cpt2$d<-as.character(cpt2$d)
cpt2$d<-paste('0000',cpt2$d,sep='')
cpt2$d<-paste(substr(cpt2$d,nchar(cpt2$d)-3,nchar(cpt2$d)))
 
icd2$d<-as.character(icd2$d)
icd2$d<-paste('0000',icd2$d,sep='')
icd2$d<-paste(substr(icd2$d,nchar(icd2$d)-3,nchar(icd2$d)))
head(icd2,n=100)

table(cpt2$d)
table(icd2$d)
############ key
cpt2<-subset(cpt2,key <=1100)  #3 years
icd2<-subset(icd2,key <=1100)  #3 years
cpt2<-subset(cpt2,key >= 0)  # positive
icd2<-subset(icd2,key >= 0)  # positive

cpt2$key<-as.character(cpt2$key)
cpt2$key<-paste('0000',cpt2$key,sep='')
cpt2$key<-paste(substr(cpt2$key,nchar(cpt2$key)-3,nchar(cpt2$key)))
 
icd2$key<-as.character(icd2$key)
icd2$key<-paste('0000',icd2$key,sep='')
icd2$key<-paste(substr(icd2$key,nchar(icd2$key)-3,nchar(icd2$key)))
head(icd2,n=100)

table(cpt2$key)
table(icd2$key)

cpt2_wide<-reshape(cpt2,timevar='key',idvar='studyid',direction='wide')
icd2_wide<-reshape(icd2,timevar='key',idvar='studyid',direction='wide')
cpt2_wide<-cpt2_wide[,order(names(cpt2_wide))]
icd2_wide<-icd2_wide[,order(names(icd2_wide))]

write.csv(cpt2_wide,file='../Data/cpt2_wide.csv')
save(cpt2_wide,file='../Data/cpt2_wide.RData')
write.csv(icd2_wide,file='../Data/icd2_wide.csv')
save(icd2_wide,file='../Data/icd2_wide.RData')

g<-subset(cpt2_wide,select=c(2201,1:25))
g$cpt<-paste(g$cpt.0001,g$cpt.0002,
g$cpt.0003,
g$cpt.0004,
g$cpt.0005,
g$cpt.0006,
g$cpt.0007,
g$cpt.0008,
g$cpt.0009,
g$cpt.0010,
g$cpt.0011,
g$cpt.0012,
g$cpt.0013,
g$cpt.0014,
g$cpt.0015,
sep=",")
# make all code ###.##
#
#table(nchar(icd$code))
#icd$code<-ifelse(nchar(icd$code)==2,paste('0',icd$code,'.00',sep=''),icd$code)
#table(nchar(icd$code))
#icd$code<-ifelse(nchar(icd$code)==3,paste(icd$code,'.00',sep=''),icd$code)
#table(nchar(icd$code))
#icd$code<-ifelse(nchar(icd$code)==4,paste('0',icd$code,'0',sep=''),icd$code)
#table(nchar(icd$code))
#icd$code<-ifelse(nchar(icd$code)==5,paste(icd$code,'0',sep=''),icd$code)
#table(nchar(icd$code))


#junk
# icd2[icd2$studyid=='23273092' & substr(icd2$icd,1,3)=='758',]
# icd2[icd2$studyid=='23313096' & substr(icd2$icd,1,3)=='758',]

#23313096
