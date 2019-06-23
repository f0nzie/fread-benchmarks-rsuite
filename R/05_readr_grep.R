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
  library(readr)
})

dataDir <- path.expand("./dataexpo")
dataFiles <- dir(dataDir, pattern = "csv$", full.names = TRUE)

# All flights by American Airlines
command <- sprintf(
  "grep --text ',AA,' %s",
  paste(dataFiles, collapse = " ")
)

# default would convert first row of `grep` output into column names
col_names <- FALSE

# default would determine some cols wrongly as logical and
# convert all the values, pre-define explicitly
col_types <- readr::cols(
  col_character(), # this is for the file name returned by `grep`
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_character(),
  col_integer(),
  col_character(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_character(),
  col_character(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_character(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_integer()
)

df <- readr::read_csv(
  file = pipe(command),
  col_types = col_types,
  col_names = col_names
)
