# source('30.ds_cpt.R',echo=TRUE)
rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/Proc')
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
#tmp<-mdy(ds1_neoplasms_demo$dob) 

getDOB<-function(demo,set){
g<-demo[,c('studyid','dob')]
return(merge(set,g,key='studyid'))
}
#
# ds_cpt code, count  cpt codes used for DS cases in hospital discharge
#
ds_cpt<-read.delim('../Data/ds_cpt_code.txt',as.is=TRUE,sep='|',
colClasses=c('character','integer'))
names(ds_cpt)<-tolower(names(ds_cpt))
str(ds_cpt)
ds_cpt$cpt_code<-substr(paste(ds_cpt$cpt_code,"000000",sep=""),1,5)
ds_cpt[order(-ds_cpt$count),]
