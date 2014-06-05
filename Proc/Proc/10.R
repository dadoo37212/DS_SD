# 10.R
# source("10.R",echo=TRUE)
library(Hmisc)
demo<-read.delim('../Data/DS1/DS1_demo.txt')
names(demo)<-tolower(names(demo))
demo$testdate<-demo$test_date; demo$test_date<-NULL
demo$dobyear<-as.numeric(substr(demo$dob,1,4))
demo$age<-(2013 - demo$dobyear)
demo$gender<-ifelse(demo$gender %in% c('null','4'),NA,demo$gender)
demo$deceased<-ifelse(demo$deceased %in% c('null','4'),NA,demo$deceased)
demo$white<-'Other'
demo$white<-ifelse(demo$race =='B','Black', demo$white)
demo$white<-ifelse(demo$race =='W','Cauc', demo$white)
demo$white<-ifelse(demo$race =='H','Hisp', demo$white)

table(demo$white,demo$race)
#summary(~gender+white+dobyear,demo)
describe(demo)

vitals<-read.delim('../Data/DS1/DS1_vitals.txt',as.is=TRUE)
names(vitals)<-tolower(names(vitals))
describe(vitals)
sort(names(vitals))
vitals$bp<-ifelse(vitals$test_name=='Blood Pressure',vitals$test_value,NA)
 head(subset(vitals,test_name=='Blood Pressure'))
#systolic
#diastolic
gg<-strsplit(vitals$bp,"/",fixed=TRUE)

tmp <- unlist(strsplit(vitals$bp, split="/"))
cols <- c("sys", "dias")
nC <- length(cols)
ind <- seq(from=1, by=nC, length=nrow(vitals))
for(i in 1:nC) {
  vitals[, cols[i]] <- tmp[ind + i - 1]
}
vitals$sys<-as.numeric(vitals$sys)
vitals$dias<-as.numeric(vitals$dias)
vitals$sys <-ifelse(vitals$sys  < 54 | vitals$sys > 500,NA,vitals$sys)
vitals$dias<-ifelse(vitals$dias < 54 | vitals$dias > 500,NA,vitals$dias)
vitals$testyear<-as.numeric(substr(vitals$test_date,1,4))
vitals$testmonth<-as.numeric(substr(vitals$test_date,6,7))
vitals$testyear<-ifelse(vitals$test.year <1990 | vitals$test.year > 2013,NA,
vitals$testyear)
vitals$seq<-vitals$testyear + (vitals$testmonth/100)

pdf('DOB Year.pdf')
hist(demo$dobyear,breaks=c(1940,1945,1950,1955,1960,1965,1970,1975,1980,1985,1990,1995,2000,2005,2010,2015),freq=TRUE,main="DOB Year", xlab="Year 1940 - 2013 in 5 year increments")
grid(col='black')
dev.off()

pdf('AgeToday.pdf')
hist(demo$age, freq=TRUE,main="Age Today", xlab="Years 1940 - 2013",labels=TRUE,
breaks=c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70))
grid(col='black')
dev.off()

bp<-subset(vitals,select=c('studyid','test_date','testyear','sys','dias'),
subset=test_name=='Blood Pressure' & !(is.na(sys) | is.na(dias) | is.na(test.year)))
bp<-bp[order(bp$studyid,bp$test_date),]
bp.u<-bp[!duplicated(bp$studyid),]
bp.all<-merge(bp.u,demo,key='studyid',index='test_date')
bp.all$age<-bp.all$test.year-bp.all$dobyear

bp_wide <- reshape(vitals, v.names = c('sys','dias'), idvar = "studyid",
                timevar = "test.year", direction = "wide")
head(bp_wide)

bp_seq<-subset(vitals,select=c('studyid','seq','sys','dias'),
subset=test_name=='Blood Pressure' & !(is.na(sys) | is.na(dias) | is.na(seq)))
bp_seq<-bp_seq[order(bp_seq$seq),]
bp_wide_seq <- reshape(bp_seq, v.names = c('sys','dias'), idvar = "studyid",
                timevar = "seq", direction = "wide")
head(bp_wide_seq)


ds.all<-merge(vitals,demo,key='studyid',index='seq')
ds.all$age<-ds.all$test.year-ds.all$dobyear
ds.all.u<-ds.all[!duplicated(ds.all$studyid),]

d.v<-merge(vitals,bp,by='studyid')
save(demo, vitals,file='../Data/DS1/ds1.RData')
save(bp,bp_seq,file='../Data/DS1/bp.RData')
save(bp_wide,bp_wide,file='../Data/DS1/bp_wide.RData')


d.v<-merge(demo,bp_wide,by='studyid')
gg<-d.v[d.v$test_name=='Blood Pressure',]

