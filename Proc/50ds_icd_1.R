#50ds_icd_1.R
# source('50ds_icd_1.R',echo=TRUE)

rm(list=ls())
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
rm(START)
source('~/Dropbox/Projects/R/formatICD9.R')

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
load("../Data/ds1_demo.RData")

geticd<-function(demo,icd,group,desc){
icd.txt<-paste('../Data/Txt/',icd,sep='')
icd_data<-read.delim(icd.txt,as.is=TRUE, colClasses=c('integer','Date','character','character'))
names(icd_data)<-tolower(names(icd_data))
tmp<-mdy(icd_data$code_date)
icd_data$codeyear <-tmp[['year']]
icd_data$codemonth<-tmp[['month']]
icd_data$codeday  <-tmp[['day']]
icd_data<-getDOB(demo,icd_data)
icd_data$agedays <-as.integer(icd_data$code_date-icd_data$dob)
icd_data$ageweeks<-round(icd_data$agedays/7,0)
icd_data$ageyears <-round(icd_data$ageweeks/52,2)
icd_data$icd_grp<-group
icd_data$icd_grp_desc<-desc
icd_data
}
g1  <-geticd(ds1_demo,'icd026-139_icd9.txt',1,'Infections')
g2  <-geticd(ds1_demo,'icd140_239_icd9.txt',2,'Neoplasm')
g3  <-geticd(ds1_demo,'icd240_279_icd9.txt',3,'Endocrine')
g4  <-geticd(ds1_demo,'icd290_319_icd9.txt',4,'Mental')
g5  <-geticd(ds1_demo,'icd320_359_icd9.txt',5,'Nervous System')
g6  <-geticd(ds1_demo,'icd360_389_icd9.txt',6,'Sense Organ')
g7  <-geticd(ds1_demo,'icd390_459_icd9.txt',7,'Circulatory')
g8  <-geticd(ds1_demo,'icd460_519_icd9.txt',8,'Respiratory')
g9  <-geticd(ds1_demo,'ICD9_580_629_icd9.txt',10,'Genitourninary')
g10 <-geticd(ds1_demo,'ICD9_630_677_icd9.txt',11,'Pregnancy')
g11 <-geticd(ds1_demo,'ICD9_710_739_icd9.txt',13,'Muscolskeletal')
g12 <-geticd(ds1_demo,'ICD9_740_759_icd9.txt',14,'Congenital')
g13 <-geticd(ds1_demo,'ICD9_760_799_icd9.txt',15,'Perinatal')
g14 <-geticd(ds1_demo,'ICD9_780_799_icd9.txt',16,'Ill-defined')
g15 <-geticd(ds1_demo,'ICD9_800_820_icd9.txt',17,'Injury')
g16 <-geticd(ds1_demo,'ICD9_821_850_icd9.txt',17,'Injury')
g17 <-geticd(ds1_demo,'ICD9_851_900_icd9.txt',17,'Injury')
g18 <-geticd(ds1_demo,'ICD9_901_950_icd9.txt',17,'Injury')
g19 <-geticd(ds1_demo,'ICD9_951_999_icd9.txt',17,'Injury')
g20 <-geticd(ds1_demo,'icd9_280_289_icd9.txt', 3,'Blood')
g21 <-geticd(ds1_demo,'icd520_579_icd9.txt',   9,'Digestive')
g22 <-geticd(ds1_demo,'ICD9_680_709_icd9.txt', 12,'Skin')
g23 <-geticd(ds1_demo,'ICD9_P_V01_85_icd9.txt',18,'E-V')
 
icd<-rbind(g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,
g15,g16,g17,g18,g19,g20,g21,g22,g23)
icd<-formatICD9(icd)
#
#on average there are 134 icd codes per person
# 325004/2420
#
# delete rows where ageyear less than or equal to -2.0
# data have a random number of days added or deleted
# ages within a year a possible
#
con<-dbConnect(MySQL(),user="root",password='',dbname='ds_sd')
gg_icd<-dbWriteTable(con,'icd',icd,row.names=FALSE,overwrite=TRUE)
#
# SAVE ICD
#
save(icd,file="../Data/icd.RData")
#
gg_icd
gg<-dbDisconnect(con)
icd_df<-with(icd,as.data.frame(table(code)))
names(icd_df)<-c('icd_code','freq')
save(icd_df,file="../Data/icd_df.RData")

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
age_max<-aggregate(ageyears~studyid,icd,max)
age_min<-aggregate(ageyears~studyid,icd,min)

#        studyid ageyear
#84957  23263093   -4.00
#98163  23763093  -12.38
#  745.4  5718  VENTRICULAR SEPT DEFECT
#  429.3  7332  CARDIOMEGALY
# 745.69  7807  VENTRICULAR SEPT DEFECT
# 783.42  8970  DELAYED MILESTONES
# 315.32 10136  RECEP-EXPRES LANG DISORD
#  416.8 10872  CHR Pulmon Heart dis nec
#  428.0 12636  Heart Failure
#  758.0 45128  Down syndrome
hi_icd<-Cs(745.4, 429.3,745.69,783.42,315.32, 416.8, 428.0, 758.0)
