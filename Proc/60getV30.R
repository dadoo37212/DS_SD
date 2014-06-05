# 60getV30.R
# source('60getV30.R',echo=TRUE)
# get V30 only
#
rm(list=ls())
#setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
rm(START)

library(Hmisc)
library(gdata)
load("../Data/icd.RData")
load("../Data/ds_demo.RData")
load("../Data/cpt.RData")
#
# ds_demo       2431 -- all records (nvars=10)
# demo          2131 -- only ds == 1 
# demo_v30       163 -- demo records with one or more v30 icd & ds=1
# cpt         327208 -- raw cpt records  (nvars=12) 
# cpt_v30      47297 -- merged demo_v30 and all cpt
# icd         393764 -- raw icd records (nvars=  13)
# icd_v30        337 -- icd's for cases with V30 or V31 (nvars=  13)
# icd_v30_all  75027 -- icd records for demo_v30
# icd_cpt_v30 136045 -- row bind of icd_v30_all and cpt_v30
#  variable 'grp' indicates if icd_cpt_v30 came from cpt or icd
#  

icd_v30<-icd[substr(icd$code,1,3) %in% c('V30','V31'),] # 337  records with V30 or V31 icd9 code
icd_v30_df<-as.data.frame(table(icd_v30$studyid))
icd_v30_df$Freq<-NULL
icd_v30_df<-rename.vars(icd_v30_df,'Var1','studyid') #205  studyid's for icd records with V30 or V31

demo<-ds_demo[ds_demo$ds==1,]  #2132  demo records with verified DS dx
demo_v30<-merge(demo,icd_v30_df,by='studyid') #163  demo records with V30 or V31 dx

save(demo_v30,file='../Data/demo_v30.RData')
save(icd_v30,file='../Data/icd_v30.RData')

demo_v3_id<-as.data.frame(demo_v30[,1])  #studyid's for DS==1 and V30 or V31
names(demo_v3_id)<-"studyid"
names(demo_v3_id)  #163  10

cpt_v30<-merge(cpt,demo_v3_id,by='studyid')     #46966
icd_v30_all<-merge(icd,demo_v3_id,by='studyid') #59277
save(icd_v30_all,file='../Data/icd_v30_all.RData')
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
cpt_v30$id_date<-NULL

icd_cpt_v30<-rbind(icd_v30_all,cpt_v30)
icd_cpt_v30<-icd_cpt_v30[order(icd_cpt_v30$studyid,icd_cpt_v30$code_date,icd_cpt_v30$grp),]

gg<-icd_cpt_v30[,c("studyid","grp","code_desc","code","code_date","agedays","dob","codeyear","codemonth","codeday",   "ageweeks","ageyears" )]
gg$code_desc<-strtrim(gg$code_desc,50)
gg<-merge(gg,demo_v3_id,by='studyid')
head(gg)
gg$code_desc<-sprintf("%-50s",gg$code_desc)
head(gg,n=75)
gg[gg$studyid=='23273092',]

icd_cpt_v30<-gg
write.csv(icd_cpt_v30,file='../Data/icd_cpt_v30.csv')
#
#SAVE
#
save(cpt_v30,    file='../Data/cpt_v30.RData')
save(icd_cpt_v30,file='../Data/icd_cpt_v30.RData')
# 
# gg[nchar(gg$code)==6,'code']
# 
# gg$code2<-NA
# gg$code2<-ifelse(nchar(gg$code)==2,paste('0',gg$code,'.00',sep=''),NA)
# gg$code2<-ifelse(nchar(gg$code)==3 & is.na(gg$code2),paste(gg$code,'.00',sep=''),NA)
# gg$code2<-ifelse(nchar(gg$code)==4 & is.na(gg$code2),paste('0',gg$code,'0',sep=''),NA)
# 
# g <- regexpr("\\.[^\\.]*$", gg$code)
# gg$code2<-ifelse(nchar(gg$code)==5 & g == 3 & is.na(gg$code2),paste('0',gg$code,sep=''),NA)
# gg$code2<-ifelse(nchar(gg$code)==5 & g == 4 & is.na(gg$code2),paste(gg$code,'0',sep=''),NA)
# gg[ is.na(gg$code2),'code2']<-gg$code
# 
# table(gg$code2)
# table(nchar(gg$code2))
