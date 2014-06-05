# 60getV30_0.R
# source('60getV30_0.R',echo=TRUE)
# get V30 only
#

rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')

library(Hmisc)
library(gdata)

load("../Data/icd.RData")
load("../Data/ds_demo.RData")
load("../Data/cpt.RData")
#
# ds_demo       2431 -- all records
# demo          2130 -- only ds == 1 Verified Down syndrome cases
# demo_v30       167 -- demo records with one or more v30 icd & ds=1
# cpt_v30      61018 -- merged demo_v30 and all cpt
# icd_v30_all  75027 -- icd records for demo_v30
# icd_cpt_v30 136045 -- row bind of icd_v30_all and cpt_v30
#  variable 'grp' indicates if icd_cpt_v30 came from cpt or icd
#  
icd_v30<-icd[substr(icd$code,1,3) %in% c('V30','V31'),] # 337
icd_v30<-icd_v30[icd_v30$agedays==0,]
icd_v30<-icd_v30[!duplicated(icd_v30$studyid),]
icd_NOT_v30<-icd[substr(icd$code,1,3) %nin% c('V30','V31'),]

demo<-ds_demo[ds_demo$ds==1,]  #2132
demo_v30<-merge(demo,icd_v30,by='studyid') #153
save(demo_v30,icd_v30,file='../Data/demo_v30.RData')

demo_v3_id<-as.data.frame(demo_v30[,1]) #153 subjects with V30 at agedays=0
names(demo_v3_id)<-"studyid"
names(demo_v3_id)

cpt_v30<-merge(cpt,demo_v3_id,by='studyid')        #41834
icd1<-merge(icd_v30,demo_v3_id,by='studyid') #54722
icd2<-merge(icd_NOT_v30,demo_v3_id,by='studyid') #54722
icd_v30_all<-rbind(icd1,icd2)
icd_v30_all<-icd_v30_all[order(icd_v30_all$studyid,icd_v30_all$code_date,]

#
#rbind cpt_v30 icd_v30_all
#
cpt_v30<-rename.vars(cpt_v30,'ageyear','ageyears')
cpt_v30<-remove.vars(cpt_v30,c('id_date','key'))
icd_v30_all<-remove.vars(icd_v30_all,c('icd_grp','icd_grp_desc'))
names(icd_v30_all)
names(cpt_v30)
icd_v30_all$grp<-"icd"
cpt_v30$grp<-"cpt"
icd_cpt_v30<-rbind(icd_v30_all,cpt_v30)
icd_cpt_v30<-icd_cpt_v30[order(icd_cpt_v30$studyid,icd_cpt_v30$code_date,icd_cpt_v30$grp),]

gg<-icd_cpt_v30[,c("studyid","grp","code_desc","code","code_date","agedays","dob","codeyear","codemonth","codeday",   "ageweeks","ageyears" )]
gg$code_desc<-strtrim(gg$code_desc,50)
gg<-merge(gg,demo_v3_id,by='studyid')
head(gg)
gg$code_desc<-sprintf("%-50s",gg$code_desc)
head(gg,n=75)
gg[gg$studyid=='23273092',]

icd_cpt_v30_0<-gg
write.csv(icd_cpt_v30_0,file='../Data/icd_cpt_v30_0.csv')
save(icd_cpt_v30_0,file='../Data/icd_cpt_v30_0.RData')
