library(tidyverse)
library(sparklyr)
library(R.utils) # for gzip

# This script shows the main table joins for microsoft academic graph using the
# journal id for zootaxa. It assumes you have run the mag_startup scripts to connect
# to the tables on the databricks spark cluster. As some jobs can take a while
# it is best to open the spark UI on databricks to check the status of the job.
# For the zootaxa journal we want to obtain the joins through the journals table
# and move outwards The MAG schema is here:
# https://docs.microsoft.com/en-us/academic-services/graph/reference-data-schema

# Papers ------------------------------------------------------------------

# obtain the journal id for zootaxa

zootaxa <- journals %>% 
  filter(journalid == 171471881)

# join to papers table by journal id

papers_results <- zootaxa %>% 
  inner_join(., papers, by = "journalid")

# print before collecting & check size
# expect 27974 papers as listed in the journalid entry = OK

# collect results

paper_results_local <- papers_results %>% 
  collect()

write_csv(paper_results_local, "data/zootaxa/zootaxa_papers.csv")
save(zootaxa_authors, file = "data/zootaxa/zootaxa_authors.rda")

# Fields of Study ---------------------------------------------------------

# This is an inner join to the joined table above to the fos papers table
# to obtain the fosids for each paper. This provides access to the fos table
# containing the fos descriptions.

fos_results <- inner_join(papers_results, fos_papers, by = "paperid") %>% 
  inner_join(., fos, by = "fosid") %>% 
  collect()

save(fos_results, file = paste0("data/zootaxa/zootaxa_fieldsofstudy.rda"))
write_csv(fos_results, paste0("data/zootaxa/zootaxa_fieldsofstudy.csv"))

# Authors -----------------------------------------------------------------

# From the papers table we join on author affiliations using the paperid to
# access the authorid. We then access the authors table using the authorid.

authors_results <- left_join(papers_results, author_affiliations, by = "paperid") %>% 
  inner_join(authors, by = "authorid") 

# this tends to be a very large table
# check the number of rows before collecting or write to spark table and download 
# with dbfs client

sdf_nrow(authors_results)

# write to spark csv (a set of csvs) to avoid overhead of local collect() with
# spark tables

spark_write_csv(authors_results, "zootaxa_authors_results_csv")

# download from the dbfs file system using the dbfs client

# authorid and cols beginning authors_ are from the authors table
# cols not beginning authors are from the join table
# uses purrr::map_df and data.table::fread (try vroom::vroom())

# throws seven warnings with fixes from fread. 

zootaxa_authors <- list.files("zootaxa_authors_results_csv", pattern = "*.csv", full.names = TRUE) %>% 
  map_df(~data.table::fread(.)) %>% 
  select(paperid, 
         authorid, 
         affiliationid, 
         authorsequencenumber, 
         originalauthor, 
         originalaffiliation, 
         starts_with("authors_"))

# save the file

save(zootaxa_authors, file = "data/zootaxa/zootaxa_authors.rda", compress = "xz")
write_csv(zootaxa_authors, "data/zootaxa/zootaxa_authors.csv")
gzip("data/zootaxa/zootaxa_authors.csv")


# Affiliations ------------------------------------------------------------

# note that affiliation table data is often incomplete. Additional results
# can be identified by looking at the original affiliation col but requires
# additional steps not covered here. 

affiliation_results <- left_join(papers_results, author_affiliations, by = "paperid") %>% 
  inner_join(affiliations, by = "affiliationid")

spark_write_csv(affiliation_results, "affiliation_results_csv")
spark_write_table(affiliation_results, "affiliation_results_tbl")

# Read the spark csvs back in. Small number of warnings with fixes

zootaxa_affiliations <- list.files("zootaxa_affiliation_results_csv", pattern = "*.csv", full.names = TRUE) %>% 
  map_df(~data.table::fread(.))

# save the file

save(zootaxa_affiliations, file = "data/zootaxa/zootaxa_affiliations.rda")
write_csv(zootaxa_affiliations, "data/zootaxa/zootaxa_affiliations.csv")
R.utils::gzip("data/zootaxa/zootaxa_affiliations.csv")
