# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return("R")
  }
  if (grepl("darwin", R.version$os)) {
    base <- gsub("~\\+~", " ", base) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()


########################################################

suppressPackageStartupMessages({
  library(data.table)
})

dataDir <- path.expand("./dataexpo")
dataFiles <- dir(dataDir, pattern = "csv$", full.names = TRUE)

# All flights by American Airlines
command <- sprintf(
  "grep --text ',AA,' %s",
  paste(dataFiles, collapse = " ")
)
# "grep --text ',AA,' ./dataexpo/2000.csv ./dataexpo/2001.csv
#                     ./dataexpo/2002.csv ./dataexpo/2003.csv
#                     ./dataexpo/2004.csv ./dataexpo/2005.csv
#                     ./dataexpo/2006.csv ./dataexpo/2007.csv ./dataexpo/2008.csv"

dt <- data.table::fread(cmd = command)
