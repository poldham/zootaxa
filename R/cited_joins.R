# start with journalid

zootaxa <- journals %>% 
  filter(journalid == 171471881)

# join to papers table by journal id

papers_results <- zootaxa %>% 
  inner_join(., papers, by = "journalid")

# get the paperids
zootaxa_paperid <- papers_results %>% 
  select(paperid)

# join to the references table by paperid, 
# then pass the paperreferencid to the papers table as the paperid
# to get the referenced papers

zootaxa_cited <- inner_join(zootaxa_paperid, references, by = "paperid") %>% 
  inner_join(papers, by = c("paperreferenceid" = "paperid"))

# count the rows before collecting
sdf_nrow(zootaxa_cited) # 155,854

spark_write_csv(zootaxa_cited, "zootaxa_cited_csv")

# use the dbfs client in terminal to download the csv files

# dbfs cp -r dbfs:/zootaxa_cited_csv ./zootaxa_cited_csv

# read in to R (spark_disconnect from the cluster, then run R/spark_local_setup.R)

zootaxa_cited_papers <- spark_read_csv(sc, path = "/Users/colinbarnes/zootaxa/zootaxa_cited_csv") %>% 
  collect()

# Attempt to match DOIs

raw_cited_dois <- read_csv("data/raw_cited/raw_cited_dois.csv")

# how many have a doi

zootaxa_cited_papers %>% 
  drop_na(doi) %>% 
  nrow() # 95122

# how many match to an input DOI in uppercase
zootaxa_cited_papers %>% 
  drop_na(doi) %>% 
  mutate(doi_match = .$doi %in% raw_cited_dois$doi_upper) %>% 
  filter(doi_match == TRUE) %>% 
  nrow() # 41,888


zootaxa_cited_papers %>% write_tsv(., "data/cited/zootaxa_cited_papers.tsv")
R.utils::gzip("data/cited/zootaxa_cited_papers.tsv")


