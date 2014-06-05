#ds_meds.R
# source('ds_meds.R',echo=TRUE)
rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)
library(gdata)

mdy<-function(date){
month<-as.numeric(format(date,"%m"))
day<-as.numeric(format(date,"%d"))
year<-as.numeric(format(date,"%Y"))
return(list(year=year,month=month,day=day))
}
load('../Data/ds_demo.RData')

getDOB<-function(demo,set){
g<-demo[,c('studyid','dob')]
return(merge(set,g,key='studyid'))
}

#
# ds_meds studyid, gender, race,dob,deceased
#
ds_meds<-read.delim('../Data/ds_meds.txt',as.is=TRUE,sep="\t",header=FALSE,
col.names=c('studyid','gender','age','race','ethnicity','deceased','dna','drug','freq','startdate','enddate'))
#,colClasses=c('integer','character','character','character','character'))
names(ds_meds)<-tolower(names(ds_meds))
names(ds_meds)
head(ds_meds)
ds_meds$studyid<-substr(ds_meds$studyid,6,13)
ds_meds$gender<-substr(ds_meds$gender,8,9)
ds_meds$age<-substr(ds_meds$age,5,6)
ds_meds$race<-substr(ds_meds$race,6,15)
ds_meds$ethnicity<-substr(ds_meds$ethnicity,11,18)
ds_meds$deceased<-substr(ds_meds$deceased,10,17)
ds_meds$dna<-substr(ds_meds$dna,5,18)
head(ds_meds)
ds_meds$startdate<-as.Date(ds_meds$startdate)

tmp<-mdy(ds_meds$startdate)

ds_meds$startyear <-tmp[['year']]
ds_meds$startmonth<-tmp[['month']]
ds_meds$startday  <-tmp[['day']]
ds_meds<-getDOB(ds_demo,ds_meds)
ds_meds$agedays <-as.integer(ds_meds$startdate-ds_meds$dob)
ds_meds$ageweeks<-round(ds_meds$agedays/7,0)
ds_meds$ageyear <-round(ds_meds$ageweeks/52,2)

head(ds_meds)
save(ds_meds,file='../Data/ds_meds.RData')
