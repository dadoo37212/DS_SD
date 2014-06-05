#20.R
# source('20.R',echo=TRUE)
# grab data directly from MySQL
#
START<-''
if(Sys.info()['sysname']=='Darwin') START<-'Dropbox'
WD<-file.path('~',START,'Projects','DS_Synthetic_Derivative','DS','Proc')
WD
setwd(WD)

library(Hmisc)
library(knitr)
library(gdata)
library(rms)
library(gdata)
library(stringr)
library(RMySQL)
sql<-"SELECT studyid,
  GROUP_CONCAT( hgba1c ORDER BY lab_date DESC SEPARATOR ',') as hgba1c
  FROM ds1_labs
  where not isnull(hgba1c)
  GROUP BY studyid  limit  50"
con<-dbConnect(MySQL(),user="root",password='',dbname='ds_sd')
rs1 <- dbSendQuery(con, sql)
a1c_wide <- fetch(rs1, n = -1)
head(a1c_wide)
mydf<-a1c_wide
myFun <- function(data) {
  ListCols <- sapply(data, is.list)
  cbind(data[!ListCols], (apply(data[ListCols], 1, unlist)))
}
gg<-myFun(mydf)



###################

g$n<-as.numeric(unlist(strsplit(g$hgba1c,",")))

sql2<-"SELECT studyid,avg(hgba1c)
  FROM ds1_labs
  where not isnull(hgba1c)
  GROUP BY studyid  limit  50"
rs2 <- dbSendQuery(con, sql2)
a1c_mean <- fetch(rs2, n = -1)
head(a1c_mean)
