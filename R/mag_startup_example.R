# Microsoft Academic Graph Tables Setup

# This is an example script

# This file assumes that you have a copy of Microsoft Academic Graph
# loaded onto a Databricks Spark cluster and that the MAG tables are 
# available in Spark format in the databricks warehouse.

# To get Microsoft Academic Graph on Azure follow the instructions here: 
# https://docs.microsoft.com/en-us/academic-services/graph/get-started-setup-provisioning

# When setting up to receive MAG and Databricks it is a very good idea to set up storage
# and databricks in the same country/region to avoid data transfer charges.
 
# To set up on Databricks go here: 
# https://docs.microsoft.com/en-us/academic-services/graph/get-started-setup-databricks

# For instructions on importing a file onto Databricks go here: https://docs.databricks.com/data/data.html
# Note that Databricks provides very helpful jupyter import scripts

# The script also assumes that you have followed the instructions to 
# set up a local connection in RStudio to connect to the cluster remotely
# as described here: https://docs.databricks.com/dev-tools/databricks-connect.html

# Setup Connection and Load Libraries -------------------------------------

#install.packages("tidyverse")
#install.packages("sparklyr")

library(sparklyr)
library(tidyverse)

# point to your version of Java that matches the cluster (e.g. 8 for Databricks Runtime 6.5)
# fill in your own user path for your configuration

Sys.setenv(JAVA_HOME="user/.jenv/versions/1.8.0.202")

# point to pyspark path
sc <- spark_connect(method = "databricks", spark_home = "user/anaconda3/lib/python3.7/site-packages/pyspark")

# Connect to MAG Spark Tables ---------------------------------------------------

# see the MAG schema for details: 
# https://docs.microsoft.com/en-us/academic-services/graph/reference-data-schema

# In this case files were imported without headers requiring rename when sourcing

authors <- tbl(sc, "authors_2020_tbl") %>% 
  rename(authorid = "_c0",
         authors_rankno = "_c1",
         authors_normalizedname = "_c2",
         authors_displayname = "_c3",
         authors_lastknownaffiliationid = "_c4",
         authors_papercount = "_c5",
         authors_paperfamilycount = "_c6",
         authors_citationcount = "_c7",
         authors_createdate = "_c8")

affiliations <- tbl(sc, "affiliations_2020_tbl") %>% 
  rename(affiliationid = "_c0", 
         affiliation_rankno = "_c1", 
         affiliation_normalizedname = "_c2", 
         affiliation_displayname = "_c3",
         affiliation_gridid = "_c4",
         affiliation_officialpage = "_c5",
         affiliation_wikipage = "_c6",
         affiliation_papercount = "_c7",
         affiliation_paperfamilycount = "_c8",
         affiliation_citationcount = "_c9",
         affiliation_latitude= "_c10",
         affiliation_longitude = "_c11",
         affiliation_createddate = "_c12")

# the table below includes the original affiliations data
# this table provides the link to/from the papers table
# to the affiliation and authors tables

author_affiliations <- tbl(sc, "author_affiliations_2020_tbl") %>% 
  rename(paperid = "_c0", 
         authorid = "_c1", 
         affiliationid = "_c2", 
         authorsequencenumber = "_c3",
         originalauthor = "_c4",
         originalaffiliation = "_c5")

# note that grid id and lat and lon are now built into the table
# additional imports and processing are needed to join onto a release
# of GRID (Global Research Identifier Database)

# Fields of Study

fos <- tbl(sc, "fos_2020_tbl") %>%
  rename(fosid = "_c0", 
         fos_rank = "_c1",
         fos_normalizedname = "_c2",
         fos_displayname = "_c3",
         fos_maintype = "_c4",
         fos_level = "_c5",
         fos_papercount = "_c6",
         fos_paperfamilycount = "_c7",
         fos_citationcount = "_c8",
         fos_createddate = "_c9")

# link table from papers to fos table
fos_papers <- tbl(sc, "fos_papers_2020_tbl") %>%
  rename(paperid = "_c0", 
         fosid = "_c1", 
         score = "_c2")

# Papers

papers <- tbl(sc, "papers_2020_tbl") %>% 
  rename(paperid = "_c0", 
         paper_rankno = "_c1", 
         doi = "_c2",
         doctype = "_c3",
         papertitle = "_c4",
         originaltitle = "_c5",
         booktitle = "_c6",
         year = "_c7",
         date = "_c8",
         publisher = "_c9",
         journalid = "_c10",
         conferenceseriesid = "_c11",
         conferanceinstanceid = "_c12",
         volume = "_c13",
         issue = "_c14",
         firstpage = "_c15",
         lastpage = "_c16",
         referencecount = "_c17",
         paper_citationcount = "_c18",
         estimatedcitation = "_c19",
         originalvenue = "_c20",
         paper_familyid = "_c21",
         paper_createddate = "_c22")

# papers extended
# for patents, putbmen and pubmed central ids

paperextended <- tbl(sc, "paper_extended_attributes_2020_tbl") %>% 
  rename(paperid = "_c0", 
         type = "_c1", 
         note = "_c2")

# See the schema for details.
# filter on the type field
# Note that pubmed and pmc are both numeric (not PMC123)
# This means that matches can become confused. To solve that 
# as a first step filter them to separate 
# vectors before matching.

# type 1 = patentid
# type 2 = pubmedid
# type 3 = pmcid

# Journals

journals <- tbl(sc, "journals_2020_tbl") %>% 
  rename(journalid = "_c0", 
         journal_rank = "_c1",
         journal_normalizedname = "_c2",
         journal_displayname = "_c3",
         journal_issn = "_c4",
         journal_publisher = "_c5",
         journal_webpage = "_c6",
         journal_papercount = "_c7",
         journal_paperfamilycount = "_c8",
         journal_citationcount = "_c9",
         journal_createddate = "_c10")

# Citation Context (for Citing papers)

citation <- tbl(sc, "citation_2020_tbl") %>% 
  rename(paperid = "_c0",
          paperreferenceid = "c1",
          citationconotext = "c2")

# Paper References (for Cited papers)

references <- tbl(sc, "references_2020_tbl") %>% 
  rename(paperid = "_c0",
         paperreferenceid = "c1")

# Abstracts (inverted index)

abstract1 <- nlp <- tbl(sc, "abstracts1_2020_tbl") %>% 
  rename(paperid = "_c0", 
         indexedabstract = "_c1")

abstract2 <- nlp <- tbl(sc, "abstracts2_2020_tbl") %>% 
  rename(paperid = "_c0", 
         indexedabstract = "_c1")
