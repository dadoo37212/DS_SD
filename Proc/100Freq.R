# source('100Freq.R',echo=TRUE)
rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
rm(START)
library(Hmisc)
library(gdata)
load("../Data/icd_v30_all.RData")       #59744    13
load("../Data/hamza_icd_v30.RData")     #35650     4
load("../Data/hamza_icd_v30_ep.RData")  #23793     5  N(studyid)=159
load("../Data/demo_v30.RData")
load("../Data/cpt_v30.RData")

icd_df<-with(icd_v30_all,as.data.frame(addmargins(table(icd_grp_desc))))
icd_df[order(icd_df$Freq),]
icd_df[order(icd_df$Freq),]

Ncases<-159
icd_names<-icd_v30_all[,c('code','code_desc','icd_grp_desc')]
icd_names_u<-unique(unique(icd_names))
head(icd_names_u)

icd1<-hamza_icd_v30_ep[,c('studyid','code')]  #Nstudyid = 159
icd1_u<-unique(icd1)  #Nstudyid = 159
icd1_u<-merge(icd1_u,icd_names_u,by.x='code',by.y='code',all.x=TRUE)  #Nstudyid = 159

icd_code<-as.data.frame(table(icd1_u$code))
icd_code<-icd_code[order(icd_code$Freq,decreasing=TRUE),]
head(icd_code)
icd_code<-rename.vars(icd_code,'Var1','code')
icd_code$Prop<-round(icd_code$Freq/Ncases,3)
head(icd_code,n=50)


icd<-merge(icd1_df,icd_names_u,by.y='code',by.x='icd9')
icd


