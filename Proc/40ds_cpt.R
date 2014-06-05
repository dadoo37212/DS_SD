#40ds_cpt.R
# source('40ds_cpt.R',echo=TRUE)
# 15ds2.R2
# source('15ds2.R',echo=TRUE)
rm(list=ls())
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
#source('/Users/rick/Dropbox/Projects/R/getids.R')
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

getcpt<-function(demo,cpt){
cpt.txt<-paste('../Data/Txt/',cpt,sep='')
cpt_data<-read.delim(cpt.txt,as.is=TRUE, colClasses=c('integer','Date','integer','character'))
names(cpt_data)<-tolower(names(cpt_data))
tmp<-mdy(cpt_data$code_date)
cpt_data$codeyear <-tmp[['year']]
cpt_data$codemonth<-tmp[['month']]
cpt_data$codeday  <-tmp[['day']]
cpt_data<-getDOB(demo,cpt_data)
cpt_data$agedays <-as.integer(cpt_data$code_date-cpt_data$dob)
cpt_data$ageweeks<-round(cpt_data$agedays/7,0)
cpt_data$ageyear <-round(cpt_data$ageweeks/52,2)
cpt_data
}
g1<-getcpt(ds1_demo,'DS_72010_72295_cpt.txt')
g2<-getcpt(ds1_demo,'DS_74000_74190_cpt.txt')
g3<-getcpt(ds1_demo,'DS_74210_74363_cpt.txt')
g4<-getcpt(ds1_demo,'DS_76500_76536_cpt.txt')
g5<-getcpt(ds1_demo,'DS_76500_76999_cpt.txt')
g6<-getcpt(ds1_demo,'DS_76604_76999_cpt.txt')
g7<-getcpt(ds1_demo,'DS_82000_82985_cpt.txt')
g8<-getcpt(ds1_demo,'DS_83001_83993_cpt.txt')
g9<-getcpt(ds1_demo,'DS_84022_84999_cpt.txt')
g10<-getcpt(ds1_demo,'DS_85000_85999_cpt.txt')
g11<-getcpt(ds1_demo,'DS_86000_86849_cpt.txt')
g12<-getcpt(ds1_demo,'DS_92001_92499_cpt.txt')
g13<-getcpt(ds1_demo,'DS_92502_92700_cpt.txt')
g14<-getcpt(ds1_demo,'DS_92950_93799_cpt.txt')
g15<-getcpt(ds1_demo,'DS_95803_96040_cpt.txt')
g16<-getcpt(ds1_demo,'DS_99201_99499_cpt.txt')

cpt<-rbind(g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g16)
#
#on average there are 134 cpt codes per person
# 325004/2420
#
# delete rows where ageyear less than or equal to -2.0
# data have a random number of days added or deleted
# ages within a year a possible
#
ol<-cpt[cpt$ageyear <= -2.0,]
ol2<-ol[!is.na(ol$studyid),]
rows<-dimnames(ol2)[[1]]
cpt<-subset(cpt,dimnames(cpt)[[1]] %nin% rows)
cpt$id_date<-paste(cpt$studyid,cpt$codedate,sep="")

rm(ol,rows,g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g16)
con<-dbConnect(MySQL(),user="root",password='',dbname='ds_sd')
gg_cpt<-dbWriteTable(con,'cpt',cpt,row.names=FALSE,overwrite=TRUE)
#
# SAVE cpt
#
save(cpt,file="../Data/cpt.RData")
gg_cpt
gg<-dbDisconnect(con)
cpt_df<-with(cpt,as.data.frame(table(code)))
names(cpt_df)<-c('cpt_code','freq')
#
# SAVE cpt_df
#
save(cpt_df,file="../Data/cpt_df.RData")

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
age_max<-aggregate(ageyear~studyid,cpt,max)
age_min<-aggregate(ageyear~studyid,cpt,min)

#        studyid ageyear
#84957  23263093   -4.00
#98163  23763093  -12.38
