# 60join.R
# source('60join.R',echo=TRUE)
#join icd birth to cpt
#icd=v30 v31, cpt=844.43
rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)
library(knitr)
library(gdata)
library(rms)
library(stringr)
library(RMySQL)

load("../Data/icd.RData")
load("../Data/cpt.RData")
source('~/Dropbox/Projects/R/getids.R')

icd_birth<-icd[substr(icd$code,1,3) %in% c('V30','V31'),]
icd_birth_df<-with(icd_birth,as.data.frame(table(studyid)))
#icd_birth[icd_birth$studyid==23273092,]
#
#select 205 demo subjects with V30 or V31 icd9 entries
#
demo_birth<-merge(ds1_demo,icd_birth_df,by='studyid')
cpt84443<-cpt[cpt$code=='84443' & !is.na(cpt$agedays),]
with(subset(cpt84443,cpt84443$agedays<14),table(agedays))
cpt84443_wk1<-subset(cpt84443,cpt84443$agedays<14)
tsh<-length(table(cpt84443_wk1$studyid))
births<-nrow(icd_birth_df)

rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')

library(Hmisc)
library(gdata)

load("../Data/icd.RData")
load("../Data/ds1_demo.RData")

icd_v30<-icd[substr(icd$code,1,3) %in% c('V30','V31'),]
demo_v30<-merge(ds1_demo,icd_v30,by='studyid')
demo_v30<-rename.vars(demo_v30,c('dob.x'),c('dob'))
demo_v30<-remove.vars(demo_v30,c('deceased','code_desc','dob.y','icd_grp_desc'))

