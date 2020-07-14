# Zootaxa Journal Data in Microsoft Academic Graph

This repository contains a set of data tables for the Zootaxa journal extracted from Microsoft Academic Graph (21 May 2020 release). The repository arises from wider work by Roderic Page [https://doi.org/10.6084/m9.figshare.c.5054372.v3](https://doi.org/10.6084/m9.figshare.c.5054372.v3) to explore citations of Zootaxa publications. 

Four sets of data are provided in the data folder. Tables can be joined using the [MAG schema](https://docs.microsoft.com/en-us/academic-services/graph/reference-data-schema). The main join field in most cases is the `paperid`. 

Examples of joins used to create the datasets are provided in the `R` folder using the `tidyverse` and `sparklyr`.

### Zootaxa (27,974 publications)

Metadata for papers published in Zootaxa and available in Microsoft Academic Graph as of May 2020. A quick Tableau workbook containing this data is available on [Tableau Public](https://public.tableau.com/profile/poldham#!/vizhome/Zootaxa/Overview). Larger files are gzipped. Click on a link to download.

- [zootaxa_papers](https://github.com/poldham/zootaxa/raw/master/data/zootaxa/zootaxa_papers.csv) (titles, doi, paperid etc)
-  [zootaxa_authors](https://github.com/poldham/zootaxa/raw/master/data/zootaxa/zootaxa_authors.csv.gz) (author names linked to paper id and affiliationid)
- [zootaxa_affiliations](https://github.com/poldham/zootaxa/raw/master/data/zootaxa/zootaxa_affiliations.csv.gz) (author affiliations linked to authorids, normally incomplete data)
- [zootaxa_fieldsofstudy](https://github.com/poldham/zootaxa/raw/master/data/zootaxa/zootaxa_fieldsofstudy.csv.gz) (MAG labels describing the field of study of individual papers based on a combination of author keywords and machine learning)

### Cited papers (155,854 publications)

This includes all publications recorded as cited references for Zootaxa in Microsoft Academic Graph. 

[zootaxa_cited_papers](https://github.com/poldham/zootaxa/raw/master/data/cited/zootaxa_cited_papers.tsv.gz)

### Citing (TBD)

Pending

### Raw Cited (125,798 papers of 137,542 dois in the `Zootaxa literature cited dataset`)

This set includes all publications (papers and references) on the Zootaxa site as extracted by Roderic Page in the [Zootaxa literature cited](https://figshare.com/collections/Zootaxa_literature_cited/5054372/3) dataset [https://doi.org/10.6084/m9.figshare.c.5054372.v3](https://doi.org/10.6084/m9.figshare.c.5054372.v3). That dataset is expected to be noisy. 

Matching between the raw cited data and MAG was performed using the DOI field with the DOI converted to upper case. The guid field is preserved as the unique identifier. 

[raw_cited_papers](https://github.com/poldham/zootaxa/raw/master/data/raw_cited/raw_cited_papers.tsv.gz)

### Microsoft Academic Graph

[Microsoft Academic](https://aka.ms/msracad) makes MAG available under a permissive [Open Data Commons Attribution Licence (ODC-By) v.1.0](https://opendatacommons.org/licenses/by/1-0/). The data in this repository is from the weekly MAG release MAG-2020-05-21. If using data from this repo in a publication or report please cite the following:

Arnab Sinha, Zhihong Shen, Yang Song, Hao Ma, Darrin Eide, Bo-June (Paul) Hsu, and Kuansan Wang. 2015. An Overview of Microsoft Academic Service (MA) and Applications. In Proceedings of the 24th International Conference on World Wide Web (WWW '15 Companion). ACM, New York, NY, USA, 243-246, doi: [10.1145/2740908.2742839](https://dl.acm.org/doi/10.1145/2740908.2742839)

K. Wang et al., “A Review of Microsoft Academic Services for Science of Science Studies”, Frontiers in Big Data, 2019, doi: [10.3389/FDATA.2019.00045](https://www.frontiersin.org/articles/10.3389/fdata.2019.00045/full)




