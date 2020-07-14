# script for accessing the papers from the 
# raw cited dataset

cited_raw <- tbl(sc, "raw_cited_dois_csv")

cited_raw_results <- cited_raw %>% 
  inner_join(., papers, by = c("doi_upper" = "doi"))

sdf_nrow(cited_raw_results) # check count 125,978 of 137,542 dois (11,564 not found)

# csv version had import issues
# save to table

spark_write_table(cited_raw_results, "cited_raw_results_tbl")

# download from the cluster
#dbfs cp -r dbfs:/cited_raw_results_tbl ./cited_raw_results_tbl

# read in to R (first spark_disconnect(sc) from the cluster, then run R/spark_local_setup.R)
raw_cited_papers <- spark_read_parquet(sc, path = "/Users/colinbarnes/zootaxa/cited_raw_results_tbl") %>% 
  collect()

write_tsv(raw_cited_papers, "data/raw_cited/raw_cited_papers.tsv")
R.utils::gzip("data/raw_cited/raw_cited_papers.tsv")