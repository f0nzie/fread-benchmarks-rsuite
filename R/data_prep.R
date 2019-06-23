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


# destDir <- path.expand("~/dataexpo") # if you choose your home folder
# otherwise, use rprojroot
destDir <- file.path(rprojroot::find_rstudio_root_file(), "dataexpo")
years <- 2000:2008
baseUrl <- "http://stat-computing.org/dataexpo/2009"

bz2Names <- file.path(destDir, paste0(years, ".csv.bz2"))
dlUrls   <- file.path(baseUrl, paste0(years, ".csv.bz2"))

if (!dir.exists(destDir)) {
  dir.create(destDir, recursive = TRUE)
}

# download files
mapply(download.file, dlUrls, bz2Names)

# extract
system(paste0(
  "cd ", destDir, "; ",
  "bzip2 -d -k ", paste(bz2Names, collapse = " ")
))
