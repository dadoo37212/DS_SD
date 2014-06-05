# 15ds2.R2
# source('15ds2.R',echo=TRUE)
rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
#OP outpatient
#save(op,file="../Data/op.RData")
#endocrinte icd9's
#save(ds2_endocrine_icd9,file="../Data/ds2_endocrine_icd9.RData")
#neoplasms
#save(ds2_neoplasms_icd9,file="../Data/ds2_neoplasms_icd9.RData")
#test procedures
#save(cpt_test,file="../Data/ds2_cpt.RData")

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
load("../Data/ds_demo.RData")
#
# op studyid, code_date, code, code_desc
# codes selected (outpatient visits) 99201 99202 99203 99204 99205 99211 99212 99213 99214 99215 

op<-read.delim('../Data/DS2/DS2_cpt.txt',as.is=TRUE, colClasses=c('integer','Date','integer','character'))
names(op)<-tolower(names(op))

str(op)
tmp<-mdy(op$code_date)
op$codeyear <-tmp[['year']]
op$codemonth<-tmp[['month']]
op$codeday  <-tmp[['day']]

with(op,table(codeyear))
with(op,table(codemonth))
with(op,table(codeday,codemonth))
op$outpatient<-1
op<-getDOB(ds1_demo,op)
op$agedays <-as.integer(op$code_date-op$dob)
op$ageweeks<-round(op$agedays/7,0)
op$ageyear <-round(op$ageweeks/52,2)
str(op)
#
# testcpt studyid, code_date, code, code_desc
# codes selected 90000

cpt_test<-read.delim('../Data/DS2/DS2_test_90000_cpt.txt',as.is=TRUE, colClasses=c('integer','Date','integer','character'))
names(cpt_test)<-tolower(names(cpt_test))

str(cpt_test)
tmp<-mdy(cpt_test$code_date)
cpt_test$codeyear <-tmp[['year']]
cpt_test$codemonth<-tmp[['month']]
cpt_test$codeday  <-tmp[['day']]

with(cpt_test,table(codeyear))
with(cpt_test,table(codemonth))
with(cpt_test,table(codeday,codemonth))
cpt_test<-getDOB(ds_demo,cpt_test)
cpt_test$agedays <-as.integer(cpt_test$code_date-cpt_test$dob)
cpt_test$ageweeks<-round(cpt_test$agedays/7,0)
cpt_test$ageyear <-round(cpt_test$ageweeks/52,2)
str(cpt_test)

#
# START DS2_endocrine_icd9 studyid, code_date, code_name, code_desc
# 
#

ds2_endocrine_icd9<-read.delim('../Data/DS2_endocrine/DS2_endocrine_icd9.txt',as.is=TRUE,
  colClasses=c('integer','Date','character','character'))

names(ds2_endocrine_icd9)<-tolower(names(ds2_endocrine_icd9))
tmp<-mdy(ds2_endocrine_icd9$code_date)
ds2_endocrine_icd9$labyear  <-tmp[['year']]
ds2_endocrine_icd9$labmonth <-tmp[['month']]
ds2_endocrine_icd9$labday   <-tmp[['day']]
ds2_endocrine_icd9          <-getDOB(ds_demo,ds2_endocrine_icd9)
ds2_endocrine_icd9$agedays  <-as.integer(ds2_endocrine_icd9$code_date-ds2_endocrine_icd9$dob)
ds2_endocrine_icd9$ageweeks <-round(ds2_endocrine_icd9$agedays/7,0)
ds2_endocrine_icd9$ageyears <-round(ds2_endocrine_icd9$ageweeks/52,2)

#str(ds2_endocrine_icd9)

with(ds2_endocrine_icd9,table(labyear))
with(ds2_endocrine_icd9,table(labmonth))
with(ds2_endocrine_icd9,table(labday,labmonth))
#
# START DS2_neoplasms_icd9 studyid, code_date, code_name, code_desc
#
#
ds2_neoplasms_icd9<-read.delim('../Data/DS2_neoplasms/DS2_neoplasms_icd9.txt',as.is=TRUE,
colClasses=c('integer','Date','character','character')
)
names(ds2_neoplasms_icd9)<-tolower(names(ds2_neoplasms_icd9))
tmp<-mdy(ds2_neoplasms_icd9$code_date)
ds2_neoplasms_icd9$labyear <-tmp[['year']]
ds2_neoplasms_icd9$labmonth<-tmp[['month']]
ds2_neoplasms_icd9$labday  <-tmp[['day']]
ds2_neoplasms_icd9<-getDOB(ds_demo,ds2_neoplasms_icd9)
ds2_neoplasms_icd9$agedays<-as.integer(ds2_neoplasms_icd9$code_date-ds2_neoplasms_icd9$dob)
ds2_neoplasms_icd9$ageweeks<-round(ds2_neoplasms_icd9$agedays/7,0)
ds2_neoplasms_icd9$ageyears<-round(ds2_neoplasms_icd9$ageweeks/52,2)

#str(ds2_neoplasms_icd9)
#
#save update birth records in ds_sb database
#
con<-dbConnect(MySQL(),user="root",password='',dbname='ds_sd')
gg_op    <-dbWriteTable(con,'op',op,row.names=FALSE,overwrite=TRUE)
gg_icd9   <-dbWriteTable(con,'ds2_endocrine_icd9',ds2_endocrine_icd9,row.names=FALSE,overwrite=TRUE)
gg_icd92  <-dbWriteTable(con,'ds2_neoplasms_icd9',ds2_neoplasms_icd9,row.names=FALSE,overwrite=TRUE)
   
gg_op      
gg_icd9
gg_icd92
save(op,file="../Data/op.RData")
save(ds2_endocrine_icd9,file="../Data/ds2_endocrine_icd9.RData")
save(ds2_neoplasms_icd9,file="../Data/ds2_neoplasms_icd9.RData")
save(cpt_test,file="../Data/ds2_cpt.RData")

gg<-dbDisconnect(con)