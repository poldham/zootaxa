# use to read in spark tables
# without running out of memory
# change version as needed

library(sparklyr)
conf <- NULL
conf$`sparklyr.cores.local` <- 4
conf$`sparklyr.shell.driver-memory` <- "8G"
conf$spark.memory.fraction <- 0.9

sc <- spark_connect(master = "local",
                    version = "2.4.0",
                    config = conf)