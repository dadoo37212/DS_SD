#  source('90age.R',echo=TRUE)
setwd('/Users/urbanorc/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
load('../Data/icd.RData')
library(Hmisc)
icd$ageyears<-round(icd$ageyears,0)

icd$ageyears<-ifelse(icd$ageyears < 0 | icd$ageyears > 60,NA,icd$ageyears)
table(icd$ageyears)
icd$y<-sprintf("%02.0f",icd$ageyears)
icd$y<-ifelse(icd$y == '-0',NA,icd$y)
table(icd$y)

i<-icd[order(icd$y),c('studyid','y','ageyears')]

i<-i[i$y != 'NA',]
table(i$y)

icd_w<-reshape(i,timevar='ageyears',idvar='studyid',direction='wide')
head(icd_w)

age_max<-aggregate(ageyears~studyid,icd,max)
age_min<-aggregate(ageyears~studyid,icd,min)


rmax<-apply(icd_w[,2:62],1, max,na.rm=TRUE)
rmin<-apply(icd_w[,2:62],1, min,na.rm=TRUE)
rmin_n<-as.numeric(rmin)
rmax_n<-as.numeric(rmax)
gmin<-cut(rmin_n,breaks=c(0,10,20,30,40,50))
gmax<-cut(rmax_n,breaks=c(0,10,20,30,40,50))

tmin<-table(gmin)
tmax<-table(gmax)

plot(tmin,type='b',col='blue',ylim=c(0,1087),pch=0,xaxt='n',xlab='Age Group',
ylab='Count')
axis(1,1:5,c('0-9','10-19','20-29','30-39','40-49'))

lines(tmax,type='b',col='red',pch=1)

legend('topright',c("Max Age","Min Age"),col=c('red',"blue"),pch=c(1,0),
horiz=FALSE)
grid(5,10,col='gray')

