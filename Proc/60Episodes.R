# 60Episodes.R
#
# create wide_cpt for days 1 to 365
#
# source('60Episodes.R',echo=TRUE)


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
#
#FUNCTIONS
#
zeropad<-function(i){
ic<-as.character(i)
ic<-paste('000',ic,sep="")
g<-substr(ic,nchar(ic)-2,nchar(ic))
g
}
source('~/Dropbox/Projects/R/getids.R')

load("../Data/ds_demo.RData") #  2431   10
load("../Data/icd.RData")     #393764   13
load("../Data/cpt.RData")     #327208   12

#
#  CPT
#
df<-cpt
key<-'studyid'
df <- df[order(df$studyid,df$agedays),]
df$key <- unlist(tapply(df[[key]], df[[key]], FUN=function(x) seq(length(x))))
#
# convert ageday and key to character
# rename ageday to d
# pad with leading zeros
# select ageday < 366 and ge 0
#
df2<-subset(df,df$agedays < 366 & df$agedays >= 0)
df2<-subset(df2,df2$key < 366)
df2$key<-zeropad(df2$key)
#
# select vars 'studyid','code','agedays','key'
#
df2<-subset(df2,select=c('studyid','code','agedays','key'))
df2<-rename.vars(df2,'agedays','d')

df2_wide<-reshape(df2,timevar='key',idvar='studyid',direction='wide')
#
# save df2_wide
#
df2_wide<-df2_wide[,order(names(df2_wide))] #1116  731
names(df2_wide)

g<-sapply(df2_wide,FUN=function(s) as.numeric(is.na(s)))
g_s<-apply(g[,c(1:365)],1,sum)
gg<-sapply(df2_wide,FUN=function(s) as.numeric(!is.na(s)))
gg_s<-apply(gg[,c(1:365)],1,sum)

studyid<-df2_wide[,c(731)]
cnt<-gg_s
g2<-cbind(studyid,cnt,df2_wide[,c(1:730)])  #1116  732

g2[1:5,c(1:20,368:387)]

g2<-rename.vars(g2,c('df2_wide[, c(731)]','gg_s',c('studyid','cnt')))
#
# grab cpt codes for subject 5
#
g2_long<-reshape(g2,direction='long',varying=list(names(g2))) #816912      3
g2_long  #vars "time"    "studyid" "id"  

d1<-g2[,c(1,2,368:732)] #studyid cnt d.0001..d.365
c1<-g2[,c(1:367)]       #studyid cnt code.0001..code.365
n1<-names(d1)
names(c1)<-n1
c1$group<-'cpt'
d1$group<-'day'
c1_d1<-rbind(d1,c1)  #2232  368
c1_d1<-c1_d1[order(c1_d1$studyid,c1_d1$group),]
c1_d1<-c1_d1[,c(1,2,368,3:367)] #order variables "studyid" "cnt"     "group"   "d.001"....
#
# save c1_d1
# cpt codes within studyid
# with group=='cpt' d.### == sequential day with stuyid recorded 
# For example, studyid 23263090 has one recorded cpt code 99283 on age in days 324
#
#         studyid cnt group d.001 d.002 d.003 d.004 d.005 d.006 d.007
#2482311 23263090   1   cpt 99283    NA    NA    NA    NA    NA    NA
#248231  23263090   1   day   324    NA    NA    NA    NA    NA    NA
save(c1_d1,file='../Data/c1_d1.RData')
write.csv(c1_d1,file='../Data/c1_d1.csv')

