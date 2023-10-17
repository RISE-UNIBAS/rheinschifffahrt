rm(list=ls())
library(spacyr)
library(foreign)
library(dplyr)
library(quanteda)
library(readtext)
mypath <- "/Users/antheaalberto/Documents/GitHub/rheinschifffahrt-showcase/files/transcriptions/txt"
setwd(mypath)

## create a list of all .txt-files in directory and read them into the environment
txt_files_ls = list.files(path=mypath, pattern="[0-9].txt") 

rhein_txt <- readtext(txt_files_ls, 
                       docvarsfrom = "filenames")

## create "link": name of image/scanned page
rhein_txt$image <- rhein_txt$doc_id
rhein_txt$image <- gsub(".txt", ".jpg", rhein_txt$image)
rownames(rhein_txt) <- rhein_txt$image

## open spacy and parse text
spacy_initialize(model = "de_core_news_sm")
parsed_txt <- spacy_parse(rhein_txt$text)
head(parsed_txt)
tail(parsed_txt) # OCR has not worked properly everywhere, but that need not concern us for now

# extract named entities
rhein_entity <- entity_extract(parsed_txt)
persons <- rhein_entity[rhein_entity$entity_type=="PER",]

## creating a link (e.g. 0002.jpg) to merge it to images and metadata
rhein_entity$link <- gsub("text","", rhein_entity$doc_id)
rhein_entity$link <- as.numeric(rhein_entity$link)
rhein_entity$link <- ifelse(rhein_entity$link < 10, paste0("000", rhein_entity$link),
                            ifelse(rhein_entity$link >= 10 & rhein_entity$link < 100, paste0("00", rhein_entity$link),
                                   paste0("0", rhein_entity$link)))
rhein_entity$link <- paste0(rhein_entity$link, ".jpg")

setwd("/Users/antheaalberto/switchdrive/RISE/Veranstaltungen/20220301_BGSH/Rheinschifffahrt Showcase")
write.csv(rhein_entity, file = "persons.csv", fileEncoding = "UTF-8")
# The above lines are for writing and saving a .csv file with only persons
# It is commented out because I have already saved it earlier
