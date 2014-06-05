# 15ds1.R
# source('15ds1.R',echo=TRUE)
rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
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

getds<-function(demo,set){
g<-demo
#g<-demo[,c('studyid')]
return(merge(set,g,by='studyid',all.y=TRUE))
}
#
ds_reviews<-read.csv('/Users/rick/Dropbox/Projects/DS_Synthetic_Derivative/DS/Data/Txt/DS_Cases2Review2013-12-11.csv',as.is=TRUE,
colClasses=c('integer','integer','integer','character'))
names(ds_reviews)<-tolower(names(ds_reviews))
save(ds_reviews,file="../Data/ds_reviews.RData")
load(file="../Data/ds1_demo.RData")
ds1_demo$ds<-NULL
r1<-ds_reviews[,c('studyid','ds')]
ds_demo<-getds(ds1_demo,r1)
ds_demo$ds<-ifelse(is.na(ds_demo$ds),1,ds_demo$ds)
table(ds_demo$ds,exclude=NULL)
ds_demo$deceased<-ifelse(ds_demo$deceased=='null','N',ds_demo$deceased)
save(ds_demo,file="../Data/ds_demo.RData")
#
