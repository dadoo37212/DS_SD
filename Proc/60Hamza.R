# 60Hamza.R
# source('60Hamza.R',echo=TRUE)

rm(list=ls())
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)
rm(START)
#
# 
#     ####### #     # ####### ######  #     # ####### 
#     #     # #     #    #    #     # #     #    #    
#     #     # #     #    #    #     # #     #    #    
#     #     # #     #    #    ######  #     #    #    
#     #     # #     #    #    #       #     #    #    
#     #     # #     #    #    #       #     #    #    
#     #######  #####     #    #        #####     #    
#
# studyid_v30 ## only studyids for cases with V30
# hamza_cpt ## agedays < 366 and ageday >=0  91973     4
# hamza_cpt_v30  ##only cases with V30       21361     4
# hamza_icd                                100510      4
# hamza_icd_v30                              23793     4
# hamza_icd_v30_ep                           34470     5
# hamza_cpt_v30_ep                           21361     5
# hamza_icw                                  38354     6
# weight_ep                                    300     5
# weight_wide                                   58    37
# weight_ep                                    300     5

library(Hmisc)
library(knitr)
library(gdata)
library(rms)
library(stringr)
library(RMySQL)

source('~/Dropbox/Projects/R/getids.R')
source('~/Dropbox/Projects/R/coleGetids.R')
source('~/Dropbox/Projects/R/episodes_l.R')
source('~/Dropbox/Projects/R/zeropad.R')
DEBUG<-FALSE
#=-=-=-=-=-=-=-=-=
load("../Data/cpt_v30.RData")
load('../Data/demo_v30.RData')
#
# cpt
#
hamza<-cpt_v30[cpt_v30$agedays< 366 & cpt_v30$agedays >= 0,c('studyid','code','agedays')]
hamza <- hamza[order(hamza$studyid,hamza$agedays),]
hamza <- hamza[!is.na(hamza$studyid),]

hamza<-coleGetids('studyid',hamza)
hamza<-subset(hamza,hamza$key < 366)
hamza_cpt<-hamza
hamza_cpt$key<-zeropad(hamza_cpt$key)

save(hamza_cpt,file='../Data/hamza_cpt.RData') #1,116
write.csv(hamza_cpt,file='../Data/hamza_cpt.csv')

studyid_v30<-as.data.frame(demo_v30$studyid)
names(studyid_v30)<-'studyid'
save(studyid_v30,file='../Data/studyid_v30.RData')

hamza_cpt_v30<-merge(hamza_cpt,studyid_v30,by='studyid')  #151
save(hamza_cpt_v30,file='../Data/hamza_cpt_v30.RData')
write.csv(hamza_cpt_v30,file='../Data/hamza_cpt_v30.csv')

hamza_cpt_v30<-hamza_cpt_v30[order(hamza_cpt_v30$studyid,hamza_cpt_v30$agedays,hamza_cpt_v30$code),]
hamza_cpt_v30_ep<-episodes_l('agedays',hamza_cpt_v30)
save(hamza_cpt_v30_ep,file='../Data/hamza_cpt_v30_ep.RData')
write.csv(hamza_cpt_v30_ep,file='../Data/hamza_cpt_v30_ep.csv')

#
# icd
#
load('../Data/icd_v30_all.RData')
hamza_icd<-icd_v30_all[icd_v30_all$agedays< 366 && icd_v30_all$agedays >= 0,c('studyid','code','agedays')]
hamza_icd <- hamza_icd[order(hamza_icd$studyid,hamza_icd$agedays),]
hamza_icd <- hamza_icd[!is.na(hamza_icd$studyid),]
hamza_icd <- coleGetids('studyid',hamza_icd)
hamza_icd <- subset(hamza_icd,hamza_icd$key < 366)

save(hamza_icd,file='../Data/hamza_icd.RData') #100,006
write.csv(hamza_icd,file='../Data/hamza_icd.csv')

hamza_icd_v30<-merge(hamza_icd,studyid_v30,by='studyid')  #22,723  153 unique studyid's
save(hamza_icd_v30,file='../Data/hamza_icd_v30.RData')
write.csv(hamza_icd_v30,file='../Data/hamza_icd_v30.csv')

hamza_icd_v30<-hamza_icd_v30[order(hamza_icd_v30$studyid,hamza_icd_v30$agedays,hamza_icd_v30$code),]
hamza_icd_v30<-hamza_icd_v30[!is.na(hamza_icd_v30$agedays),]
hamza_icd_v30<-hamza_icd_v30[hamza_icd_v30$agedays < 366,]
hamza_icd_v30_ep<-episodes_l('agedays',hamza_icd_v30)
save(hamza_icd_v30_ep,file='../Data/hamza_icd_v30_ep.RData')
write.csv(hamza_icd_v30_ep,file='../Data/hamza_icd_v30_ep.csv')
#
# birth weight
#
load('../Data/ds1_vitals.RData')
vitals7<-ds1_vitals[ds1_vitals$agedays <= 7,]
vitals7_v30<-merge(vitals7,studyid_v30,by='studyid')  #22,723  153 unique studyid's
vitals7_v30<-vitals7_v30[!is.na(vitals7_v30$weight),]
vitals7_v30$weight<-as.numeric(vitals7_v30$test_value,7)

weight<-vitals7_v30[,c('studyid','weight','agedays')]
weight<-weight[order(weight$studyid,weight$agedays),]
weight<-coleGetids('studyid',weight)

zeropad<-function(i){
ic<-as.character(i)
ic<-paste('000',ic,sep="")
g<-substr(ic,nchar(ic)-1,nchar(ic))
g
}
weight$key<-zeropad(weight$key)
weight<-rename.vars(weight,c('weight','agedays'),c('w','d'))
weight_wide<-reshape(weight,idvar='studyid',timevar='key',direction='wide')
weight_wide<-weight_wide[,order(names(weight_wide))]

save(weight,file='../Data/weight.RData')
write.csv(weight,file='../Data/weight.csv')
save(weight_wide,file='../Data/weight_wide.RData')
write.csv(weight_wide,file='../Data/weight_wide.csv')

weight<-weight[order(weight$studyid,weight$d),]
weight_ep<-episodes_l('d',weight)
save(weight_ep,file='../Data/weight_ep.RData')
write.csv(weight_ep,file='../Data/weight_ep.csv')

#
# hamza_icd_v30_ep
# get studyid for cases with ds == 758 and  agedays <= 7
#
gg2<-hamza_icd_v30_ep[substr(hamza_icd_v30_ep$code,1,3)=='758' & hamza_icd_v30_ep$agedays <= 14 & hamza_icd_v30_ep$ep == 1,]
gg2_df<-as.data.frame(table(gg2$studyid))
names(gg2_df)<-c('studyid','freq')
names(gg2_df)
head(gg2_df)
dim(gg2_df)
#
#get max agedays
ga<-hamza_icd_v30_ep
ga<-ga[ga$ep==1 & !is.na(ga$code),]
ga<-ga[!is.na(ga$studyid),c('studyid','agedays')]
agg<-aggregate(ga,by=list(ga$studyid),FUN=max,na.rm=TRUE)
summary(agg$agedays)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.00    3.00    6.00   12.54   15.00   78.00
#DEBUG<-FALSE
if(DEBUG){
	for( idx in 1:nrow(agg)){
	 #if(readline('hit return or s to stop')=='s') break
	 print(ga[ga$studyid == agg[idx,'studyid'],])
	 print(agg[idx,])
	}
}
#hamza_icd_v30_ep
#hamza_cpt_v30_ep
g1<-merge(hamza_icd_v30_ep,gg2_df,by='studyid')
g1$group<-'icd'
g1<-g1[,c('studyid','code','agedays','key','ep','group')]
head(g1)
g2<-merge(hamza_cpt_v30_ep,gg2_df,by='studyid')
g2$group<-'cpt'
g2<-g2[,c('studyid','code','agedays','key','ep','group')]
head(g2)
#
#weight at birth
#
w<-weight[weight$d==0 & weight$key=='01',]
names(w)<-c('studyid','code','agedays','key')
w$ep<-1
w$group<-'bwgt'
names(w)
#453.592 grams per pound
grams<-453.592
w$code<-w$code*grams
summary(w$code)
w$code<-w$code*grams
summary(w$code)  #code = bwgt in grams
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  712.1  1109.0  1350.0  1288.0  1490.0  1712.0 
hamza_icw<-rbind(g1,g2,w)
hamza_icw<-hamza_icw[order(hamza_icw$studyid,hamza_icw$agedays,hamza_icw$group),]

cpt_codes<-with(subset(hamza_icw,group=='cpt'),as.data.frame(table(code,group)))
cpt_codes_freq<-cpt_codes[order(cpt_codes$Freq),]

icd_codes<-with(subset(hamza_icw,group=='icd'),as.data.frame(table(code,group)))
icd_codes_freq<-icd_codes[order(icd_codes$Freq),]

# cases included V30 and 758 in first 7 days; bwgt in grams on day 0  
# ep is episode # all agedays within an episode are no more than one day apart
#
hamza_icw$ep<-NULL
hamza_icw<-episodes_l('agedays',hamza_icw)
hamza_icw$key<-zeropad(hamza_icw$key)

save(hamza_icw,file='../Data/hamza_icw-2014-01-14.RData') #145 unique studyid's
write.csv(hamza_icw,file='../Data/hamza_icw-2014-01-14.csv')

#
# get LOS for episode 1
#
load('../Data/hamza_icw.RData')
ep1<-hamza_icw[hamza_icw$ep==1,] #get first episode
ep1$key<-NULL                    #remove key
ep1<-subset(ep1,!is.na(ep1$studyid)) # remove rows with missing studyid
ep1<-coleGetids('studyid',ep1)       # generate key for data frame ep1
ep1<-subset(ep1,ep1$key<366)         # limit the number of records per case to 365
ep1_1<-ep1[,c('studyid','key','agedays')] #create dataframe with just 3 variables

#
# create wide ep1
#
ep1_w<-reshape(ep1_1,idvar='studyid',timevar='key',direction='wide')

#
# find max agedays for each case.  This defines LOS
#
ep1_1<-ep1_1[order(ep1_1$studyid),] #sort by studyid
los<- aggregate(agedays ~ studyid, ep1_1, max) #get LOS = max agedays per case
los[1:50,]

# then simply merge with the original
#df.max <- merge(df.agg, ep1_1)
#df.max

#
# get icd codes
#
load('../Data/icd_cpt_v30.RData')
'../Data/icd_cpt_v30.RData'<-subset(icd_cpt_v30,icd_cpt_v30$grp=='icd',c('studyid','code','code_desc'))
icd<-icd[order(icd$code),]
studyid<-as.data.frame(table(icd$studyid))
names(studyid)<-c('studyid','freq')
names(studyid)

#icd$code<-sapply(icd$code,fix_icd)
icd$key<-substr(paste(icd$code,':',trim(icd$code_desc),'........................',sep=''),1,30)
icd_key_df<-with(icd,as.data.frame(table(key)))
names(icd_key_df)<-c('key','freq')
icd_key_df<-icd_key_df[order(icd_key_df$freq,decreasing=TRUE),]
head(icd_key_df)

icd_desc_df<-as.data.frame(table(icd$code_desc))
names(icd_desc_df)<-c('desc','freq')
icd_desc_df<-icd_desc_df[order(icd_desc_df$freq,decreasing=TRUE),]
head(icd_desc_df)

icd_df<- with(icd,as.data.frame(table(code)))
names(icd_df)<-c('icd','freq')
icd_df<-icd_df[order(icd_df$freq),]
#
# congenital heart defect
#
chd<-subset(icd,select=c('studyid','code'))
chd$chd<-ifelse(substr(icd$code,1,3)=='746',1,0)
with(subset(chd,chd==1),table(studyid))

chd_agg<-aggregate(chd ~ studyid,chd,FUN=sum)
chd[chd$studyid=='23313101' & chd$chd==1,]
gg<-merge(icd,chd,by='studyid')  #151

#=-=-=-=-=-=-==-
#ICD code	Condition
#gi  751.1	Atresia and Stenosis of small intestine
#gi  751.3	Hirschprung Disease or other congenital functional disorder of colon
#gi  750.3	Congenital TE Fistula
#	
#chd 745.2	Tetralogy of Fallot
#chd 745.4	Ventricular Septal Defect
#chd 745.5	Ostium secundum ASD
#chd 745.60	Endocardial Cushion Defect, Unspecified
#chd 745.69	Other Endocardial Cushion Defects
#chd 746	Other congenital anomalies of heart
#chd 746.9	Unspecified Congenital Anomaly of Heart
#	
#circ 747.0	    Patent ductus arteriosus
#circ 747.10	Coarctation of aorta (preductal or postductal)
#circ 747.83	Persistent fetal circulation
#	  
#thy 243	Congenital Hypothyroidism
#thy 244.9	Unspecified acquired hypothyroidism
#	 
#prem 765.0	Disorders relating to extreme immaturity of infant (765.0 to 765.09)
#prem 765.1	Disorders relating to other preterm infants (765.1 to 765.19)
#prem 765.2	Weeks of gestation (765.2 to 765.29)
#
gi <-ifelse(icd$code %in% c('751.10','751.30','750.3'),1,0)
chd<-ifelse(icd$code %in% c('745.20','745.50','745.60','745.69','746.00','746.90'),1,0)
cir<-ifelse(icd$code %in% c('747.00','747.10','747.83'),1,0);table(cir)
thy<-ifelse(icd$code %in% c('243.00','243.90'),1,0);table(thy)
prem<-ifelse(icd$code %in% c('765.00','765.10','765.20'),1,0);table(prem)

