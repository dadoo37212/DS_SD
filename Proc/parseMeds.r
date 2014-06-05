trim <- function(x) sub('[ ]*$', '', sub('^[ ]*', '', x))

# require dataframe with name column
parseDrugs <- function(x) {
  newVars <- c('tech','brand','dosage','paran','with','injection','infusion','oral')
  x[,newVars] <- ''
  x$tech <- toupper(sub("[:].*$", '', x$name))

  x$injection <- grepl("INJ", x$tech)
  # may not want to remove INJ string
  x$tech[x$injection] <- sub('(INJ|INJECTION)', '', x$tech[x$injection])

  # check for infusion
  x$infusion <- grepl("INFUSION", x$tech)
  x$tech[x$infusion] <- sub('REGULAR INFUSION|INFUSION', '', x$tech[x$infusion])

  # taken with additional drug
  haswith <- grep("W/|WITH", x$tech)
  x$with[haswith] <- trim(sub('.*(W/|WITH)(.*)$', '\\2', x$tech[haswith]))
  x$tech[haswith] <- sub('[ ]*(W/|WITH).*$', '', x$tech[haswith])

  # brand name follows colon
  x$brand <- toupper(trim(sub("^[^:]*[:]*(.*)$", '\\1', x$name)))

  # paranthetical notes
  x$paran <- trim(sub('^[^(]*[(]*([^)]*)[)]*$', '\\1', x$tech))
  x$tech <- sub('[ ]*[(].*$', '', x$tech)

  # dose info
  x$dosage <- trim(sub("^[^0-9]*([0-9]*.*)$", "\\1", x$tech))
  x$tech <- sub('[ ]*[0-9]+.*$', '', x$tech)

  # oral meds
  isoral <- grep("[ ](ORAL|CHEWABLE)", x$tech)
  x$oral[isoral] <- trim(sub('.*[ ]((ORAL|CHEWABLE).*)$', '\\1', x$tech[isoral]))
  x$tech[isoral] <- sub('[ ](ORAL|CHEWABLE).*$', '', x$tech[isoral])

  # if technical name is missing, use dosage
  doseToTech <- which(x$tech == '' & x$dosage != '')
  x$tech[doseToTech] <- x$dosage[doseToTech]
  x$dosage[doseToTech] <- ''
  x$tech <- sub('[-; ]*$', '', trim(x$tech))

  # might want to do this
  # x <- x[order(x$tech, x$dosage),]
  print(apply(x[,newVars],MARGIN=2,function(i) length(unique(i))))
  x
}

meds <- read.table('ds_meds.txt', stringsAsFactors=FALSE, header=FALSE, sep='\t', quote="")
names(meds) <- c('demo','name','unit','start','end')

jm <- parseDrugs(meds[,'name',drop=FALSE])

load('con_meds.RData')
meds <- con_meds[,'drug',drop=FALSE]
names(meds) <- 'name'
con <- parseDrugs(meds)
