# 80SelectControls.r
# source('80SelectControls.r',echo=FALSE)
rm(list=ls())
setwd('~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Proc')
library(Hmisc)
PWD<-'~/Dropbox/Projects/DS_Synthetic_Derivative/DS/Data/'
load(paste(PWD,'demo_v30.RData',sep=""))
demo_v30$gender<-ifelse(demo_v30$gender=='U',NA,demo_v30$gender)
demo_v30[demo_v30$studyid=='23283094','gender']<-'F'
demo_v30[demo_v30$studyid=='23823099','gender']<-'M'
with(demo_v30,ftable(addmargins(table(dobyear,gender))))
#        gender   F   M Sum
#dobyear                   
#1994             1   0   1
#1996             2   1   3
#1997             1   1   2
#1998             3   1   4
#1999             3   4   7
#2000             3   2   5
#2001             4   4   8
#2002             1   7   8
#2003             1   6   7
#2004             3   5   8
#2005             8   9  17
#2006             3   7  10
#2007             8   9  17
#2008             8  16  24
#2009             7   8  15
#2010             2   6   8
#2011             4   1   5
#2012             2   2   4
#Sum             64  89 153

PWD<-'~/Dropbox/Projects/DS_Synthetic_Derivative/Controls/Data/'
load(paste(PWD,'con_demo.RData',sep=""))
load(paste(PWD,'con_icd.RData',sep=""))
table(con_demo$dobyear)
con_demo<-con_demo[con_demo$dobyear >= 1994,]
#
# get studids for con_demo with V30 at age0
#
#s<-subset(con_icd,substr(con_icd$code,1,3)=='V30' & con_icd$agedays <=6,)
studyid<-subset(con_icd,substr(con_icd$code,1,3)=='V30' & con_icd$agedays con_demo<-merge(con_demo,studyid,by='studyid')

con_dobyear<-addmargins(table(con_demo$dobyear))
v30_dobyear<-table(demo_v30$dobyear)

sum(v30_dobyear)/con_dobyear[length(con_dobyear)]

#1994 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 
#   1    3    2    4    7    5    8    8    7    8   17   10   17   24   15    8    5    4 
# 
# with(con_sample,table(dobyear))
#dobyear
#1994 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 
#   4   12    8   16   28   20   32   32   28   32   68   40   68   96   60   32   20   16 

get_samples<-function(year,dobyr,con_demo,index){
tmp<-subset(con_demo,con_demo$dobyear==year)
tmp[sample(1:nrow(tmp),dobyr[index]*4,replace=FALSE),]
}
c1994<-get_samples(1994,v30_dobyear,con_demo,1)
c1996<-get_samples(1996,v30_dobyear,con_demo,2)
c1997<-get_samples(1997,v30_dobyear,con_demo,3)
c1998<-get_samples(1998,v30_dobyear,con_demo,4)
c1999<-get_samples(1999,v30_dobyear,con_demo,5)
c2000<-get_samples(2000,v30_dobyear,con_demo,6)
c2001<-get_samples(2001,v30_dobyear,con_demo,7)
c2002<-get_samples(2002,v30_dobyear,con_demo,8)
c2003<-get_samples(2003,v30_dobyear,con_demo,9)
c2004<-get_samples(2004,v30_dobyear,con_demo,10)
c2005<-get_samples(2005,v30_dobyear,con_demo,11)
c2006<-get_samples(2006,v30_dobyear,con_demo,12)
c2007<-get_samples(2007,v30_dobyear,con_demo,13)
c2008<-get_samples(2008,v30_dobyear,con_demo,14)
c2009<-get_samples(2009,v30_dobyear,con_demo,15)
c2010<-get_samples(2010,v30_dobyear,con_demo,16)
c2011<-get_samples(2011,v30_dobyear,con_demo,17)
c2012<-get_samples(2012,v30_dobyear,con_demo,18)
con_sample<-rbind(c1994,c1996,c1997,c1998,c1999,c2000,c2001,c2002,c2003,c2004,c2005,c2006,c2007,c2008,c2009,c2010,c2011,c2012)

save(con_sample,file='../Data/con_sample.RData')
