# 70join.R
# source('70join.R',echo=TRUE)
#join icd birth to cpt
rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)
library(knitr)
library(gdata)
library(rms)
source('~/Dropbox/Projects/R/getids.R')

load("../Data/icd.RData")
load("../Data/ds1_demo.RData")
load("../Data/cpt.RData")
#
# ds1_demo      2424 -- all records
# demo          2136 -- only ds == 1 
# demo_v30       167 -- demo records with one or more v30 icd 
# cpt_v30      61018 -- merged demo_v30 and all cpt
# icd_v30_all  75027 -- icd records for demo_v30
# icd_cpt_v30 136045 -- row bind of icd_v30_all and cpt_v30
#  variable 'grp' indicates if icd_cpt_v30 came from cpt or icd
#  

demo<-ds1_demo[ds1_demo$ds==1,]
icd<-remove.vars(icd,c('icd_grp','icd_grp_desc'))
cpt<-remove.vars(cpt,c('id_date','key'))
cpt<-rename.vars(cpt,'ageyear','ageyears')
icd$grp<-"icd"
cpt$grp<-"cpt"
icd_cpt<-rbind(icd,cpt)
icd_cpt<-icd_cpt[order(icd_cpt$studyid,icd_cpt$code_date,icd_cpt$grp),]

gg<-icd_cpt[,c("studyid","grp","code_desc","code","code_date","agedays","ageyears","dob","codeyear","codemonth","codeday", "ageweeks" )]
gg$code_desc<-strtrim(gg$code_desc,50)
gg$code_desc<-sprintf("%-50s",gg$code_desc)
head(gg,n=75)
write.csv(icd_cpt,file='../Data/icd_cpt.csv')
save(icd_cpt,file='../Data/icd_cpt.RData')


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
