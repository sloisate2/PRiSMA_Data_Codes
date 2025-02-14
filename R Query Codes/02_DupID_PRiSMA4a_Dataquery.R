#*****************************************************************************
#*QUERY #2 -- CHECK FOR DUPLICATE IDs
#* Written by: Stacie Loisate & Xiaoyan Hu
#* Last updated: 13 March 2023

#*Input: Wide data (all raw .csv files)
#*Function: identify any duplicate IDs 
#*Output: .rda file with all duplicate IDs 
#*****************************************************************************
#* Items to Update before running script 
#* You can copy and paste "UPDATE EACH RUN" to find where to update 
#* 1. Update "UploadDate" 
#* 2. Set working directory to site-specific folder 
#* 3. Load in wide data 
#* 4. Load in long data 

#* Once the previous lines of code are updated, you can start to run the script 
#* Notes: 
#* If you get an error that says it cannot bind because there are 0 rows, that means there are no duplicates 
#*****************************************************************************

# clear environment 
rm(list = ls())

# load packages 
library(tidyverse)
library(readxl)
library(tibble)
library(readr)
library(dplyr)
library(data.table)
library(lubridate)

## UPDATE EACH RUN ## 
# 1. Update "UploadDate" (this should match the folder name in synapse)
UploadDate = "2023-02-10"

#*****************************************************************************
#*set directory and read data 
#*****************************************************************************
## UPDATE EACH RUN ## 
## 2. Set working directory to site-specific folder - main folder
setwd("~/PRiSMAv2Data/Zambia/2023-02-10/")

## UPDATE EACH RUN ## 
## 3. Load in wide data 
load("~/PRiSMAv2Data/Zambia/2023-02-10/data/2023-02-10_wide.RData")

#*****************************************************************************
#* check duplicated IDs, also check the rest vars' info
#*****************************************************************************
#*Make empty dataframe 
VarNamesDuplicate <- as.data.frame(matrix(nrow = 1, ncol = 6))
names(VarNamesDuplicate) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted", "Form")

#****************************************
#* SCRNID --> 00 
#****************************************
if (exists("mnh00")==TRUE){
  
dup_SCRNID <- function(form) {
  ID <- form %>% 
    dplyr::select(SCRNID)
  dup <- form[duplicated(ID),] %>% 
    arrange(SCRNID) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dupID)
}

m00_id_dup <- dup_SCRNID(mnh00)

# export key variables 
m00_id_dup <- m00_id_dup %>% 
   group_by(SCRNID) %>% 
  filter(OTHR_IEORRES != 1 & OTHR_IEORRES == 77) %>% ## remove the participants that had some reason to be excluded 
  dplyr::select(SCRNID, MOMID, PREGID, FORMCOMPLDAT_MNH00) 

# add visit type column 
m00_id_dup <- add_column(m00_id_dup,VisitType = NA , .after = "PREGID")

# rename columns 
names(m00_id_dup) = c("SCRNID","MOMID", "PREGID", "VisitType", "DateFormCompleted")

# add form column 
m00_id_dup <- add_column(m00_id_dup,Form = "MNH00" , .after = "DateFormCompleted")

#*bind with other forms
if (nrow(m00_id_dup > 1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m00_id_dup)
} 

}
#****************************************
#* SCRNID --> 02
#****************************************
if (exists("mnh02")==TRUE){
  
dup_SCRNID <- function(form) {
  ID <- form %>% 
    dplyr::select(SCRNID)
  dup <- form[duplicated(ID),] %>% 
    arrange(SCRNID) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dupID)
}

m02_id_dup <- dup_SCRNID(mnh02)

# export key variables 
m02_id_dup <- m02_id_dup %>% 
  dplyr::select(SCRNID, MOMID, PREGID, FORMCOMPLDAT_MNH02)


# add visit type column 
m02_id_dup <- add_column(m02_id_dup,VisitType = NA , .after = "PREGID")

# rename columns 
names(m02_id_dup) = c("SCRNID","MOMID", "PREGID", "VisitType", "DateFormCompleted")

# add form column 
m02_id_dup <- add_column(m02_id_dup,Form = "MNH02" , .after = "DateFormCompleted")


#*bind with other forms
if (nrow(m02_id_dup > 1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m02_id_dup)
} 
}

#****************************************
#*SCRNID & US_VISIT & US_OHOSTDAT  --> 01
#****************************************
if (exists("mnh01")==TRUE){

#check US_OHOSTDAT if duplicates with SCRNID & US_VISIT
dup_US <- function(form) {
  ID <- form %>% 
    dplyr::select(SCRNID, US_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(SCRNID, US_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

out_us <- dup_US(mnh01)

# export key variables if duplicates exists 
#out_us <- out_us %>% select(SCRNID,MOMID, PREGID, FORMCOMPLDAT_MNH01)
out_us <- out_us %>% select(SCRNID,MOMID, PREGID, US_VISIT)
out_us <- add_column(out_us,FORMCOMPLDAT_MNH01 =NA)

# rename columns 
names(out_us) = c("SCRNID","MOMID", "PREGID", "VisitType", "DateFormCompleted")

# add form column 
out_us <- add_column(out_us,Form = "MNH01")

#*bind with other forms
if (nrow(out_us > 1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, out_us)
} 
}
#****************************************
#*#MOMID & PREGID --> 03
#****************************************
if (exists("mnh03")==TRUE){
  
names(mnh03) <- toupper(names(mnh03))
datalist <- list(mnh03)

dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

xmomid_dup <- datalist %>% map(dup_MOMID_PREGID)
names(xmomid_dup) = c("m03")

for (i in seq(xmomid_dup)){
  assign(paste0(names(xmomid_dup[i]),"_id_dup"), xmomid_dup[[i]])
}

# export key variables if duplicates exists 
m03_id_dup <- m03_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH03)

# add SCRNID column if duplicates exist 
if (length(m03_id_dup >1)) {
  m03_id_dup = cbind(SCRNID = "NA", m03_id_dup)
}

# rename columns if duplicates exist 
if (length(m03_id_dup >1)) {
  names(m03_id_dup) = c("SCRNID","MOMID", "PREGID", "DateFormCompleted")
}

# add form column
m03_id_dup <- add_column(m03_id_dup,Form = "MNH03")

#*bind with other forms
if (nrow(m03_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m03_id_dup)
}
}
#****************************************
#* MOMID & PREGID & US_VISIT --> MNH04
#****************************************
if (exists("mnh04")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, TYPE_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, TYPE_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

id_visit_dup_m04 <- dup_MOM_PREG_TV(mnh04)

# export key variables if duplicates exists 
if (length(id_visit_dup_m04 >1)) {
id_visit_dup_m04 <- id_visit_dup_m04 %>% select(MOMID, PREGID, TYPE_VISIT,FORMCOMPLDAT_MNH04)
}
  
# add SCRNID column if duplicates exist 
if (length(id_visit_dup_m04 >1)) {
  id_visit_dup_m04 = cbind(SCRNID = "NA", id_visit_dup_m04)
}

# rename columns if duplicates exist 
if (length(id_visit_dup_m04 >1)) {
  names(id_visit_dup_m04) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
id_visit_dup_m04 <- add_column(id_visit_dup_m04,Form = "MNH04")

#*bind with other forms
if (nrow(id_visit_dup_m04 >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, id_visit_dup_m04)
}

}

#****************************************
#* MOMID & PREGID & US_VISIT --> MNH05
#****************************************
if (exists("mnh05")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, TYPE_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, TYPE_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

id_visit_dup_m05 <- dup_MOM_PREG_TV(mnh05)

# export key variables if duplicates exists 
if (length(id_visit_dup_m05 >1)) {
id_visit_dup_m05 <- id_visit_dup_m05 %>% select(MOMID, PREGID, TYPE_VISIT,FORMCOMPLDAT_MNH05)
}
  
# add SCRNID column if duplicates exist 
if (length(id_visit_dup_m05 >1)) {
  id_visit_dup_m05 = cbind(SCRNID = "NA", id_visit_dup_m05)
}

# rename columns if duplicates exist 
if (length(id_visit_dup_m05 >1)) {
  names(id_visit_dup_m05) = c("SCRNID","MOMID", "PREGID", "VisitType","DateFormCompleted")
}

# add form column 
id_visit_dup_m05 <- add_column(id_visit_dup_m05,Form = "MNH05")

#*bind with other forms
if (nrow(id_visit_dup_m05 >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, id_visit_dup_m05)
}
}
#****************************************
#* MOMID & PREGID & US_VISIT --> MNH06
#****************************************
if (exists("mnh06")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, TYPE_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, TYPE_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

id_visit_dup_m06 <- dup_MOM_PREG_TV(mnh06)

# export key variables if duplicates exists 
if (length(id_visit_dup_m06 >1)) {
id_visit_dup_m06 <- id_visit_dup_m06 %>% select(MOMID, PREGID, TYPE_VISIT,FORMCOMPLDAT_MNH06)
}
  
# add SCRNID column if duplicates exist 
if (length(id_visit_dup_m06 >1)) {
  id_visit_dup_m06 = cbind(SCRNID = "NA", id_visit_dup_m06)
}

# rename columns if duplicates exist 
if (length(id_visit_dup_m06 >1)) {
  names(id_visit_dup_m06) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
id_visit_dup_m06 <- add_column(id_visit_dup_m06,Form = "MNH06")

#*bind with other forms
if (nrow(id_visit_dup_m06 >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, id_visit_dup_m06)
}

}
#****************************************
#* MNH07 
#****************************************
if (exists("mnh07")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, MAT_SPEC_COLLECT_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, MAT_SPEC_COLLECT_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m07_id_dup <- dup_MOM_PREG_TV(mnh07)

# export key variables if duplicates exists 
m07_id_dup <- m07_id_dup %>% select(MOMID, PREGID, MAT_SPEC_COLLECT_VISIT, FORMCOMPLDAT_MNH07)

# add SCRNID column if duplicates exist 
if (length(m07_id_dup >1)) {
  m07_id_dup = cbind(SCRNID = "NA", m07_id_dup)
}

# rename columns if duplicates exist 
if (length(m07_id_dup >1)) {
  names(m07_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column
m07_id_dup <- add_column(m07_id_dup,Form = "MNH07")

#*bind with other forms
if (nrow(m07_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m07_id_dup)
}

}
#****************************************
#* MNH08
#****************************************
if (exists("mnh08")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, VISIT_LBSTDAT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, VISIT_LBSTDAT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m08_id_dup <- dup_MOM_PREG_TV(mnh08)

# export key variables if duplicates exists 
m08_id_dup <- m08_id_dup %>% select(MOMID, PREGID,VISIT_LBSTDAT, FORMCOMPLDAT_MNH08)

# add SCRNID column if duplicates exist 
if (length(m08_id_dup >1)) {
  m08_id_dup = cbind(SCRNID = "NA", m08_id_dup)
}

# rename columns if duplicates exist 
if (length(m08_id_dup >1)) {
  names(m08_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m08_id_dup <- add_column(m08_id_dup,Form = "MNH08")

#*bind with other forms
if (nrow(m08_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m08_id_dup)
}

}
#****************************************
#* MNH09
#****************************************
if (exists("mnh09")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m09_id_dup <- dup_MOMID_PREGID(mnh09)

# export key variables if duplicates exists 
m09_id_dup <- m09_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH09)


# add SCRNID column if duplicates exist 
if (length(m09_id_dup >1)) {
  m09_id_dup = cbind(SCRNID = "NA", m09_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m09_id_dup >1)) {
  m09_id_dup = add_column(m09_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m09_id_dup >1)) {
  names(m09_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m09_id_dup <- add_column(m09_id_dup,Form = "MNH09")


#*bind with other forms
if (nrow(m09_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m09_id_dup)
}
}
#****************************************
#* MNH10
#****************************************
if (exists("mnh10")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m10_id_dup <- dup_MOMID_PREGID(mnh10)

# export key variables if duplicates exists 
m10_id_dup <- m10_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH10)

# add SCRNID column if duplicates exist 
if (length(m10_id_dup >1)) {
  m10_id_dup = cbind(SCRNID = "NA", m10_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m10_id_dup >1)) {
  m10_id_dup = add_column(m10_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m10_id_dup >1)) {
  names(m10_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m10_id_dup <- add_column(m10_id_dup,Form = "MNH10")

#*bind with other forms
if (nrow(m10_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m10_id_dup)
}

}

#****************************************
#* MNH11 -- create new variable names for 
#* duplicates for infants and merge later
#****************************************
if (exists("mnh11")==TRUE){
  
dup_INFANTID <- function(form) {
  ID <- form %>% 
    select(INFANTID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(INFANTID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m11_id_dup <- dup_INFANTID(mnh11)

# export key variables if duplicates exists 
m11_id_dup <- m11_id_dup %>% select(MOMID, PREGID,INFANTID, FORMCOMPLDAT_MNH11)

# add SCRNID column if duplicates exist 
if (length(m11_id_dup >1)) {
  m11_id_dup = cbind(SCRNID = "NA", m11_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m11_id_dup >1)) {
  m11_id_dup = add_column(m11_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m11_id_dup >1)) {
  names(m11_id_dup) = c("SCRNID","MOMID", "PREGID","INFANTID","VisitType", "DateFormCompleted")
}

# add form column 
m11_id_dup <- add_column(m11_id_dup,Form = "MNH11")

#*bind with other forms
if (nrow(m11_id_dup >1)){
  VarNamesDuplicate_Inf <- m11_id_dup
}
}
#****************************************
#* MNH12
#****************************************
if (exists("mnh12")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, PNC_N_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, PNC_N_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m12_id_dup <- dup_MOM_PREG_TV(mnh12)

# export key variables if duplicates exists 
m12_id_dup <- m12_id_dup %>% select(MOMID, PREGID,PNC_N_VISIT, FORMCOMPLDAT_MNH12)

# add SCRNID column if duplicates exist 
if (length(m12_id_dup >1)) {
  m12_id_dup = cbind(SCRNID = "NA", m12_id_dup)
}

# rename columns if duplicates exist 
if (length(m12_id_dup >1)) {
  names(m12_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m12_id_dup <- add_column(m12_id_dup,Form = "MNH12")


#*bind with other forms
if (nrow(m12_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m12_id_dup)
}
}
#****************************************
#* MNH13
#****************************************
if (exists("mnh13")==TRUE){
  
dup_INF_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, PNC_N_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, PNC_N_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m13_id_dup <- dup_INF_TV(mnh13)

# export key variables if duplicates exists 
m13_id_dup <- m13_id_dup %>% select(MOMID, PREGID,INFANTID,PNC_N_VISIT, FORMCOMPLDAT_MNH13)

# add SCRNID column if duplicates exist 
if (length(m13_id_dup >1)) {
  m13_id_dup = cbind(SCRNID = "NA", m13_id_dup)
}

# rename columns if duplicates exist 
if (length(m13_id_dup >1)) {
  names(m13_id_dup) = c("SCRNID","MOMID", "PREGID","InfantID","VisitType", "DateFormCompleted")
}

# add form column 
m13_id_dup <- add_column(m13_id_dup,Form = "MNH13")


#*bind with other forms
if (nrow(m13_id_dup >1)){
  VarNamesDuplicate_Inf <- rbind(VarNamesDuplicate_Inf, m13_id_dup)
} 
}
#****************************************
#* MNH14
#****************************************
if (exists("mnh14")==TRUE){
  
dup_INF_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, POC_VISIT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, POC_VISIT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m14_id_dup <- dup_INF_TV(mnh14)

# export key variables if duplicates exists 
m14_id_dup <- m14_id_dup %>% select(MOMID, PREGID,INFANTID,POC_VISIT, FORMCOMPLDAT_MNH14)

# add SCRNID column if duplicates exist 
if (length(m14_id_dup >1)) {
  m14_id_dup = cbind(SCRNID = "NA", m14_id_dup)
}

# rename columns if duplicates exist 
if (length(m14_id_dup >1)) {
  names(m14_id_dup) = c("SCRNID","MOMID", "PREGID","InfantID","VisitType", "DateFormCompleted")
}

# add form column 
m14_id_dup <- add_column(m14_id_dup,Form = "MNH14")


#*bind with other forms
if (nrow(m14_id_dup >1)){
  VarNamesDuplicate_Inf <- rbind(VarNamesDuplicate_Inf, m14_id_dup)
} 
}
#****************************************
#* MNH15
#****************************************
if (exists("mnh15")==TRUE){

dup_INF_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, OBSTERM)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, OBSTERM) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m15_id_dup <- dup_INF_TV(mnh15)

# export key variables if duplicates exists 
m15_id_dup <- m15_id_dup %>% select(MOMID, PREGID,INFANTID,OBSTERM, FORMCOMPLDAT_MNH15)

# add SCRNID column if duplicates exist 
if (length(m15_id_dup >1)) {
  m15_id_dup = cbind(SCRNID = "NA", m15_id_dup)
}

# rename columns if duplicates exist 
if (length(m15_id_dup >1)) {
  names(m15_id_dup) = c("SCRNID","MOMID", "PREGID","InfantID","VisitType", "DateFormCompleted")
}

# add form column
m15_id_dup <- add_column(m15_id_dup,Form = "MNH15")

#*bind with other forms
if (nrow(m15_id_dup >1)){
  VarNamesDuplicate_Inf <- rbind(VarNamesDuplicate_Inf, m15_id_dup)
} 
}
#****************************************
#* MNH16
#****************************************
if (exists("mnh16")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m16_id_dup <- dup_MOMID_PREGID(mnh16)

# export key variables if duplicates exists 
m16_id_dup <- m16_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH16)

# add SCRNID column if duplicates exist 
if (length(m16_id_dup >1)) {
  m16_id_dup = cbind(SCRNID = "NA", m16_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m16_id_dup >1)) {
  m16_id_dup = add_column(m16_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m16_id_dup >1)) {
  names(m16_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}


# add form column 
m16_id_dup <- add_column(m16_id_dup,Form = "MNH16")


#*bind with other forms
if (nrow(m16_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m16_id_dup)
}
}
#****************************************
#* MNH17
#****************************************
if (exists("mnh17")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m17_id_dup <- dup_MOMID_PREGID(mnh17)

# export key variables if duplicates exists 
m17_id_dup <- m17_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH17)

# add SCRNID column if duplicates exist 
if (length(m17_id_dup >1)) {
  m17_id_dup = cbind(SCRNID = "NA", m17_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m17_id_dup >1)) {
  m17_id_dup = add_column(m17_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m17_id_dup >1)) {
  names(m17_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m17_id_dup <- add_column(m17_id_dup,Form = "MNH17")


#*bind with other forms
if (nrow(m17_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m17_id_dup)
}
}
#****************************************
#* MNH18
#****************************************
if (exists("mnh18")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m18_id_dup <- dup_MOMID_PREGID(mnh18)

# export key variables if duplicates exists 
m18_id_dup <- m18_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH18)

# add SCRNID column if duplicates exist 
if (length(m18_id_dup >1)) {
  m18_id_dup = cbind(SCRNID = "NA", m18_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m18_id_dup >1)) {
  m18_id_dup = add_column(m18_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m18_id_dup >1)) {
  names(m18_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m18_id_dup <- add_column(m18_id_dup,Form = "MNH18")

#*bind with other forms
if (nrow(m18_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m18_id_dup)
}
}
#****************************************
#* MNH19
#****************************************
if (exists("mnh19")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, OBSSTDAT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, OBSSTDAT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m19_id_dup <- dup_MOM_PREG_TV(mnh19)

# export key variables if duplicates exists 
m19_id_dup <- m19_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH19)

# add SCRNID column if duplicates exist 
if (length(m19_id_dup >1)) {
  m19_id_dup = cbind(SCRNID = "NA", m19_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m19_id_dup >1)) {
  m19_id_dup = add_column(m19_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m19_id_dup >1)) {
  names(m19_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m19_id_dup <- add_column(m19_id_dup,Form = "MNH19")

#*bind with other forms
if (nrow(m19_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m19_id_dup)
}
}
#****************************************
#* MNH20
#****************************************
if (exists("mnh20")==TRUE){
  
dup_INF_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, OBSSTDAT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, OBSSTDAT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m20_id_dup <- dup_INF_TV(mnh20)

# export key variables if duplicates exists 
m20_id_dup <- m20_id_dup %>% select(MOMID, PREGID,INFANTID, FORMCOMPLDAT_MNH20)

# add SCRNID column if duplicates exist 
if (length(m20_id_dup >1)) {
  m20_id_dup = cbind(SCRNID = "NA", m20_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m20_id_dup >1)) {
  m20_id_dup = add_column(m20_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m20_id_dup >1)) {
  names(m20_id_dup) = c("SCRNID","MOMID", "PREGID","InfantID","VisitType", "DateFormCompleted")
}

# add form column 
m20_id_dup <- add_column(m20_id_dup,Form = "MNH20")

#*bind with other forms
if (nrow(m20_id_dup >1)){
  VarNamesDuplicate_Inf <- rbind(VarNamesDuplicate_Inf, m20_id_dup)
} 

}

#****************************************
#* MNH21 -- save as separate form 
#* VarNamesDuplicate_adverse
#****************************************
if (exists("mnh21")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, INFANTID, AESTDAT)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID,INFANTID, AESTDAT) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m21_id_dup <- dup_MOM_PREG_TV(mnh21)

# export key variables if duplicates exists 
m21_id_dup <- m21_id_dup %>% select(MOMID, PREGID, INFANTID, FORMCOMPLDAT_MNH21)

# add SCRNID column if duplicates exist 
if (length(m21_id_dup >1)) {
  m21_id_dup = cbind(SCRNID = "NA", m21_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m21_id_dup >1)) {
  m21_id_dup = add_column(m21_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m21_id_dup >1)) {
  names(m21_id_dup) = c("SCRNID","MOMID", "PREGID","INFANTID","VisitType", "DateFormCompleted")
}

# add form column 
m21_id_dup <- add_column(m21_id_dup,Form = "MNH21")

#*bind with other forms
if (nrow(m21_id_dup >1)){
  VarNamesDuplicate_adverse <-  m21_id_dup
}
}

#****************************************
#* MNH23
#****************************************
if (exists("mnh23")==TRUE){
  
dup_MOMID_PREGID <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m23_id_dup <- dup_MOMID_PREGID(mnh23)

# export key variables if duplicates exists 
m23_id_dup <- m23_id_dup %>% select(MOMID, PREGID, FORMCOMPLDAT_MNH23)

# add SCRNID column if duplicates exist 
if (length(m23_id_dup >1)) {
  m23_id_dup = cbind(SCRNID = "NA", m23_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m23_id_dup >1)) {
  m23_id_dup = add_column(m23_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m23_id_dup >1)) {
  names(m23_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m23_id_dup <- add_column(m23_id_dup,Form = "MNH23")

#*bind with other forms
if (nrow(m23_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m23_id_dup)
}
}
#****************************************
#* MNH24
#****************************************
if (exists("mnh24")==TRUE){
  
dup_INFANTID <- function(form) {
  ID <- form %>% 
    select(INFANTID)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(INFANTID)
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m24_id_dup <- dup_INFANTID(mnh24)

# export key variables if duplicates exists 
m24_id_dup <- m24_id_dup %>% select(MOMID, PREGID,INFANTID, FORMCOMPLDAT_MNH24)

# add SCRNID column if duplicates exist 
if (length(m24_id_dup >1)) {
  m24_id_dup = cbind(SCRNID = "NA", m24_id_dup)
}

# add visit type column  if duplicates exist 
if (length(m24_id_dup >1)) {
  m24_id_dup = add_column(m24_id_dup,VisitType = NA , .after = "PREGID")
}

# rename columns if duplicates exist 
if (length(m24_id_dup >1)) {
  names(m24_id_dup) = c("SCRNID","MOMID", "PREGID","INFANTID","VisitType", "DateFormCompleted")
}

# add form column 
m24_id_dup <- add_column(m24_id_dup,Form = "MNH24")


#*bind with other forms
if (nrow(m24_id_dup >1)){
  VarNamesDuplicate_Inf <- m24_id_dup
}
}

#****************************************
#* MNH25
#****************************************
if (exists("mnh25")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, ANC_VISIT_N)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, ANC_VISIT_N) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m25_id_dup <- dup_MOM_PREG_TV(mnh25)

# export key variables if duplicates exists 
m25_id_dup <- m25_id_dup %>% select(MOMID, PREGID,ANC_VISIT_N, FORMCOMPLDAT_MNH25)

# add SCRNID column if duplicates exist 
if (length(m25_id_dup >1)) {
  m25_id_dup = cbind(SCRNID = "NA", m25_id_dup)
}

# rename columns if duplicates exist 
if (length(m25_id_dup >1)) {
  names(m25_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m25_id_dup <- add_column(m25_id_dup,Form = "MNH25")

#*bind with other forms
if (nrow(m25_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m25_id_dup)
}
}
#****************************************
#* MNH26
#****************************************
if (exists("mnh26")==TRUE){
  
dup_MOM_PREG_TV <- function(form) {
  ID <- form %>% 
    select(MOMID, PREGID, FTGE_STAGE)
  dup <- form[duplicated(ID) | duplicated(ID, fromLast = TRUE),] %>% 
    arrange(MOMID, PREGID, FTGE_STAGE) 
  dupID <-print(dup, n=nrow(dup), na.print=NULL)
  return(dup)
}

m26_id_dup <- dup_MOM_PREG_TV(mnh26)

# export key variables if duplicates exists 
m26_id_dup <- m26_id_dup %>% select(MOMID, PREGID,FTGE_STAGE, FORMCOMPLDAT_MNH26)

# add SCRNID column if duplicates exist 
if (length(m26_id_dup >1)) {
  m26_id_dup = cbind(SCRNID = "NA", m26_id_dup)
}

# rename columns if duplicates exist 
if (length(m26_id_dup >1)) {
  names(m26_id_dup) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted")
}

# add form column 
m26_id_dup <- add_column(m26_id_dup,Form = "MNH26")

#*bind with other forms
if (nrow(m26_id_dup >1)){
  VarNamesDuplicate <- rbind(VarNamesDuplicate, m26_id_dup)
}
}
#****************************************
#* BIND ALL DATA FRAMES 
#****************************************
# add infant id column to momid dataframe 
names(VarNamesDuplicate) = c("SCRNID","MOMID", "PREGID","VisitType", "DateFormCompleted", "Form")
VarNamesDuplicate <- add_column(VarNamesDuplicate, INFANTID = NA, .after = "PREGID")

# update naming
VarNamesDuplicate = VarNamesDuplicate[-1,]
names(VarNamesDuplicate) = c("ScrnID","MomID", "PregID","InfantID", "VisitType", "DateFormCompleted", "Form")

## add additional columns 
VarNamesDuplicate = cbind(QueryID = NA, 
                          UploadDate = UploadDate, 
                          #MomID = "NA", PregID = "NA",
                          #DateFormCompleted = "NA", 
                          VarNamesDuplicate, 
                          `Variable Name` = "NA",
                          `Variable Value` = "NA",
                          FieldType = "Text", 
                          EditType = "Duplicate ID", 
                          DateEditReported = format(Sys.time(), "%Y-%m-%d"))
# combine form/edit type var 
VarNamesDuplicate$Form_Edit_Type <- paste(VarNamesDuplicate$Form,"_",VarNamesDuplicate$EditType)


duplicates_query <- VarNamesDuplicate
VarNamesDuplicate <- VarNamesDuplicate

#export
save(duplicates_query, file = "queries/duplicates_query.rda")

#*****************************************************************************
#* comparing mom id 
#* This code will check that all moms who are enrolled had an enrollment form 
#*****************************************************************************
## UPDATE EACH RUN ## 
## 4. Load in long data  
load("~/PRiSMAv2Data/Kenya/2023-02-10/data/2023-02-10_long.RData")

## get MOMIDs in enrollment form 
enroll_momid <- data_long %>% filter(form == "MNH02")
enroll_momid_vec <- as.vector(unique(enroll_momid$MOMID))

## get MOMIDs in all forms 
all_momid <- data_long %>% filter(form != "MNH02" & form != "MNH00" & form != "MNH01")

## subset all MOMIDs that have forms 03-25 but not enrollment 
out<-subset(all_momid, !(all_momid$MOMID %in% enroll_momid$MOMID))

## return to wide format 
out <- spread(out, key = varname, value = response)

## only keep the first 5 columns 
out = out[,1:5]
MomidNotMatched <- out
# update naming
MomidNotMatched <- add_column(out, "InfantID" = NA, .after = "PREGID") ## add infant id 
names(MomidNotMatched) = c("ScrnID","MomID", "PregID","InfantID", "DateFormCompleted", "Form")

# add visit type column 
MomidNotMatched <- add_column(MomidNotMatched, VisitType = NA , .after = "InfantID")

## add additional columns 
MomidNotMatched_query = cbind(QueryID = NA, 
                              UploadDate = UploadDate, 
                              #MomID = "NA", PregID = "NA",
                              #DateFormCompleted = "NA", 
                              MomidNotMatched, 
                              `Variable Name` = "NA",
                              `Variable Value` = "NA",
                              FieldType = "Text", 
                              EditType = "MOMID Missing Enrollment", 
                              DateEditReported = format(Sys.time(), "%Y-%m-%d"))

# combine form/edit type var 
MomidNotMatched_query <- add_column(MomidNotMatched_query,Form_Edit_Type = paste(MomidNotMatched_query$Form,"_",MomidNotMatched_query$EditType))

#export Mom ID not matched query 
save(MomidNotMatched_query, file = "queries/MomidNotMatched_query.rda")

