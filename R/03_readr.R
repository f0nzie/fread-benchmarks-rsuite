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
  library(purrr)
  library(magrittr)
})

dataDir <- path.expand("./dataexpo")
dataFiles <- dir(dataDir, pattern = "csv$", full.names = TRUE)

# rbind_rows won't coerce, prefedine
col_types <- readr::cols(
  .default = col_double(),
  UniqueCarrier = col_character(),
  TailNum = col_character(),
  Origin = col_character(),
  Dest = col_character(),
  CancellationCode = col_character(),
  CarrierDelay = col_double(),
  WeatherDelay = col_double(),
  NASDelay = col_double(),
  SecurityDelay = col_double(),
  LateAircraftDelay = col_double()
)

df <- dataFiles %>%
  purrr::map_dfr(
    readr::read_csv,
    col_types = col_types,
    progress = FALSE
  )
