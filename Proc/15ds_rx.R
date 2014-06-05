# 15ds_rx.R
# source('15ds_rx.R',echo=TRUE)
rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)library(Hmisc)
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
#tmp<-mdy(ds1_neoplasms_demo$dob) 

getDOB<-function(demo,set){
g<-demo[,c('studyid','dob')]
return(merge(set,g,key='studyid'))
}
#
# ds_cpt code, count  cpt codes used for DS cases in hospital discharge
#
ds_rx<-read.delim('../Data/Txt/rx.tab',as.is=TRUE,sep='\t',header=TRUE,strip.white=TRUE,
colClasses=c('character','character','integer','Date','Date'))
names(ds_rx)<-tolower(names(ds_rx))
dim(ds_rx)
g2<-strsplit(ds_rx$v1,":")
ds_rx$studyid<-as.numeric(sapply(g2,"[",1))
ds_rx$white<-sapply(g2,"[",4)
ds_rx$v1<-NULL
ds_rx<-ds_rx[,c(5,1,2,3,4)]
head(ds_rx)
save(ds_rx,file="../Data/ds_rx.RData")
