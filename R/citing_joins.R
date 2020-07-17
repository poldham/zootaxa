library(tidyverse)
library(sparklyr)

# start with journalid

zootaxa <- journals %>% 
  filter(journalid == 171471881)

# join to papers table by journal id

papers_results <- zootaxa %>% 
  inner_join(., papers, by = "journalid")

# get the paperids
# add source_paperid for later step
# to avoid awkward naming issues

zootaxa_paperid <- papers_results %>% 
  select(paperid) %>% 
  mutate(source_paperid = paperid)


# Retrive citing papers ---------------------------------------------------

# When working with journals the entry for citationcount in the journals table (116,518 for zootaa) is the target
# The citing papers can be calculated by identifying input paperids
# in the references (paperreferences) under paperreferenceid. The paperids from that table
# are citing the input paperids
# here is an example with zootaxa data where zootaxa paperid 9826026 is cited by xyz paperids

# Source: spark<?> [?? x 2]
# 
# paperreferenceid  paperid
# <dbl>      <dbl>
# 1   9826026 2090111574
# 2   9826026 2001968725
# 3   9826026 2060261793
# 4   9826026   11718830
# 5   9826026 2173299910
# 6   9826026   61467507
# 7   9826026 2104082704
# 8   9826026   65124641
# 9   9826026 2116268233
# 10   9826026  190274643

# to prevent paper.x and paper.y col names rename the input

zootaxa_source_paperid <- zootaxa_paperid %>% 
  rename(source_paperid = paperid)

# identify zootaxa papers in the paperrefernencedid and then take the paperid (citing) and retrieve from
# the papers table

zootaxa_citing <- inner_join(zootaxa_source_paperid, references, by = c("source_paperid" = "paperreferenceid")) %>% 
  inner_join(papers, by = "paperid")

# Do the results match with the journals table citationcount?
sdf_nrow(zootaxa_citing) # 116,518 = matches with journals table. OK

spark_write_csv(zootaxa_citing, "zootaxa_citing_csv", delimiter = "\t", mode ="overwrite")

# read in from dbfs

# dbfs cp -r dbfs:/zootaxa_citing_csv ./zootaxa/zootaxa_citing_csv

# read into R
# due to file import issues reported by rlang on import used cat in terminal

# cd zootaxa/zootaxa_citing_csv
# cat *.csv >zootaxa_citing.tsv

# read in the cat file

zootaxa_citing <- data.table::fread("/Users/colinbarnes/zootaxa/zootaxa_citing_csv/zootaxa_citing.tsv") %>% 
  rename(citing_paperid = paperid)

nrow(zootaxa_citing) # 116,525 (close enough for now but test paperids)

write_csv(zootaxa_citing, "data/citing/citing.csv")
R.utils::gzip("data/citing/citing.csv")

