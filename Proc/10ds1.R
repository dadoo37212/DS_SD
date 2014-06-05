# 10ds1.R
# source('10ds1.R',echo=TRUE)
# 
# get ds1_demo from  '../Data/Txt/DS1_demo.txt'
# calculate age variables
# fix gender
# create white
#save(ds1_demo,file="../Data/ds1_demo.RData")
# VARS="studyid","ds","gender","race","dob","deceased","dobyear","dobmonth","dobday","white"
#get ds1_vitals<-read.delim('../Data/Txt/DS1_vitals.txt'
#save(ds1_vitals,file="../Data/ds1_vitals.RData")
#
#get ds1_labs<-read.delim('../Data/Txt/DS1_labs.txt'
#save(ds1_labs,file="../Data/ds1_labs.RData")

rm(list=ls())
#
#set working directory -- works for Ubuntu and OSX 
#
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
DATA<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Data')
DATA

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

getDOB<-function(demo,set){
g<-demo[,c('studyid','dob')]
return(merge(set,g,by='studyid'))
}
#
# DS1_demo studyid, gender, race,dob,deceased
#ds1_demo<-read.delim('../Data/Txt/DS1_demo.txt',as.is=TRUE,
#
ds1_demo<-read.delim(paste(DATA,'/Txt/DS1_demo.txt',sep=''),as.is=TRUE,
colClasses=c('integer','character','character','character','character'))
names(ds1_demo)<-tolower(names(ds1_demo))
#
# fix dob
#
ds1_demo$dob<-ifelse(ds1_demo$studyid == 25053085, '1988-09-17',ds1_demo$dob)
ds1_demo$dob<-ifelse(ds1_demo$studyid == 23403092, '1950-11-08',ds1_demo$dob)

ds1_demo$dob<-as.Date(ds1_demo$dob)
str(ds1_demo)


tmp<-mdy(ds1_demo$dob) 
ds1_demo$dobyear<-tmp[['year']]
ds1_demo$dobmonth<-tmp[['month']] 
ds1_demo$dobday<-tmp[['day']] 
table(ds1_demo$dodday)

ds1_demo$gender<-ifelse(ds1_demo$gender %in% c('null','4'),NA,ds1_demo$gender)
ds1_demo$white<-'Other'
ds1_demo$white<-ifelse(ds1_demo$race =='B','Black', ds1_demo$white)
ds1_demo$white<-ifelse(ds1_demo$race =='W','Cauc', ds1_demo$white)
ds1_demo$white<-ifelse(ds1_demo$race =='H','Hisp', ds1_demo$white)

#
# get reviewed records
#

getds<-function(demo,set){
g<-demo
#g<-demo[,c('studyid')]
return(merge(set,g,by='studyid',all.y=TRUE))
}
#
# ADD variable ds based on reviewed status of records
#
#/Users/rick/Dropbox/Projects/DS_Synthetic_Derivative/DS/Data/Txt/DS_Cases2ReviewHN.csv
ds_reviews<-read.csv(paste(DATA,'/Txt/DS_Cases2ReviewHN.csv',sep=''),as.is=TRUE,
colClasses=c('integer','integer','integer','character'))
names(ds_reviews)<-tolower(names(ds_reviews))
save(ds_reviews,file="../Data/ds_reviews.RData")
r1<-ds_reviews[,c('studyid','ds')]
ds1_demo<-getds(ds1_demo,r1)

table(ds1_demo$white,ds1_demo$race)
table(ds1_demo$ds)

#summary(~gender+white+decelabsased+dobyear,ds1_demo)
describe(ds1_demo)
#
# DS1_labs studyid, lab_date, lab_name, lab_value
# lab_names selected CPepti     FT4  HgbA1C   T3-UP     TSH  TSHRcp TSI-3rd  TSI-QL  TSI-QN 
#

ds1_labs<-read.delim(paste(DATA,'/Txt/DS1_labs.txt',sep=''),as.is=TRUE,
colClasses=c('integer','Date','character','character')
)
names(ds1_labs)<-tolower(names(ds1_labs))
ds1_labs$cpepti<-ifelse(ds1_labs$lab_name   =='CPepti' ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$ft4   <-ifelse(ds1_labs$lab_name   =='FT4'    ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$hgba1c<-ifelse(ds1_labs$lab_name  =='HgbA1C'  ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$t3up  <-ifelse(ds1_labs$lab_name  =='T3-UP'   ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$tsh   <-ifelse(ds1_labs$lab_name  =='TSH'     ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$tshrcp<-ifelse(ds1_labs$lab_name  =='TSHRcp'  ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$tsi3rd<-ifelse(ds1_labs$lab_name  =='TSI-3rd' ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$tsiql <-ifelse(ds1_labs$lab_name  =='TSI-QL'  ,as.numeric(ds1_labs$lab_value),NA)
ds1_labs$tsiqn <-ifelse(ds1_labs$lab_name  =='TSI-QN'  ,as.numeric(ds1_labs$lab_value),NA)
with(ds1_labs,table(cpepti,lab_name))
with(ds1_labs,table(tsiqn,lab_name))
tmp<-mdy(ds1_labs$lab_date)
ds1_labs$labyear <-tmp[['year']]
ds1_labs$labmonth<-tmp[['month']]
ds1_labs$labday  <-tmp[['day']]
ds1_labs<-getDOB(ds1_demo,ds1_labs)
ds1_labs$agedays<-as.integer(ds1_labs$lab_date-ds1_labs$dob)
ds1_labs$ageweeks<-round(ds1_labs$agedays/7,0)
ds1_labs$ageyears<-round(ds1_labs$ageweeks/52,2)

#str(ds1_labs)

with(ds1_labs,table(labyear))
with(ds1_labs,table(labmonth))
with(ds1_labs,table(labday,labmonth))
tmp<-subset(ds1_labs,lab_name=='HgbA1C',select=c('studyid','lab_value','hgba1c'))
head(tmp)

#
#ds1_vitals  studyid, test_date, test_name, test_value
# test_names selected  "bp" "sys" "dias" "bmi" "height" "weight"
#
ds1_vitals<-read.delim(paste(DATA,'/Txt/DS1_vitals.txt',sep=''),as.is=TRUE,
colClasses=c('integer','Date','character','character'))
names(ds1_vitals)<-tolower(names(ds1_vitals))
str(ds1_vitals)

describe(ds1_vitals)
sort(names(ds1_vitals))
ds1_vitals$bp<-ifelse(ds1_vitals$test_name=='Blood Pressure',ds1_vitals$test_value,NA)
 head(subset(ds1_vitals,test_name=='Blood Pressure'))
#systolic
#diastolic
p<-str_locate(ds1_vitals$bp,'/')
ds1_vitals$sys<-as.numeric(str_sub(ds1_vitals$bp,1,p[,1]-1))
ds1_vitals$dias<-as.numeric(str_sub(ds1_vitals$bp,p[,1]+1))
with(ds1_vitals,table(sys))
with(ds1_vitals,table(dias))
ds1_vitals$sys <-ifelse(ds1_vitals$sys  < 54 | ds1_vitals$sys > 500,NA,ds1_vitals$sys)
ds1_vitals$dias<-ifelse(ds1_vitals$dias < 54 | ds1_vitals$dias > 500,NA,ds1_vitals$dias)
ds1_vitals$bmi<- -99
ds1_vitals$bmi<-ifelse(ds1_vitals$test_name=='BMI',round(as.numeric(ds1_vitals$test_value),1),NA)
ds1_vitals$bmi<-ifelse(ds1_vitals$bmi < 10 | ds1_vitals$bmi > 50,NA, ds1_vitals$bmi )
ds1_vitals$height<- -99
ds1_vitals$height<-ifelse(ds1_vitals$test_name=='Height',round(as.numeric(ds1_vitals$test_value),1),NA)
ds1_vitals$height<-ifelse(ds1_vitals$height < 10 | ds1_vitals$height > 200,NA, ds1_vitals$height )
ds1_vitals$weight<- -99
ds1_vitals$weight<-ifelse(ds1_vitals$test_name=='Weight',round(as.numeric(ds1_vitals$test_value),1),NA)
ds1_vitals$weight<-ifelse(ds1_vitals$weight < 1 | ds1_vitals$weight > 300,NA, ds1_vitals$weight )

tmp<-mdy(ds1_vitals$test_date)
ds1_vitals$testyear<-tmp[['year']]
ds1_vitals$testmonth<-tmp[['month']]
ds1_vitals$testday  <-tmp[['day']]
ds1_vitals$testyear<-ifelse(ds1_vitals$testyear <1990 | ds1_vitals$testyear > 2013,NA,
ds1_vitals$testyear)
ds1_vitals<-getDOB(ds1_demo,ds1_vitals)
ds1_vitals$agedays<-as.integer(ds1_vitals$test_date-ds1_vitals$dob)
ds1_vitals$agedays<-ifelse(ds1_vitals$agedays < 0    ,NA,ds1_vitals$agedays)
ds1_vitals$agedays<-ifelse(ds1_vitals$agedays > 29200,NA,ds1_vitals$agedays)
ds1_vitals$ageweeks<-round(ds1_vitals$agedays/7,0)
ds1_vitals$ageyears<-round(ds1_vitals$ageweeks/52,2)
ds1_vitals$seq<-sequence(rle(ds1_vitals$studyid)$length)

str(ds1_vitals)
#
#save update records 
#
#delete duplicates
gg<-ds1_demo[-c(6,11,13,18,90,324,607,926,1410,1819,2224),]
ds1_demo<-gg
rm(gg)

con<-dbConnect(MySQL(),user="root",password='',dbname='ds_sd')
gg_vitals1<-dbWriteTable(con,'ds1_vitals',ds1_vitals,row.names=FALSE,overwrite=TRUE)
gg_demo   <-dbWriteTable(con,'ds1_demo',ds1_demo,row.names=FALSE,overwrite=TRUE)
gg_labs   <-dbWriteTable(con,'ds1_labs',ds1_labs,row.names=FALSE,overwrite=TRUE)
         
gg_vitals1
gg_demo   
gg_labs     
save(ds1_demo,file="../Data/ds1_demo.RData")
save(ds1_vitals,file="../Data/ds1_vitals.RData")
save(ds1_labs,file="../Data/ds1_labs.RData")

gg<-dbDisconnect(con)

