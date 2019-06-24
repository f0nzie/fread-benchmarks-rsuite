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
rscripts <- c("`utils::read.csv` + `base::rbind`",
             "`data.table::fread` + `rbindlist`",
             "`readr::read_csv` + `purrr:map_dfr`",
             "`data.table::fread` from `grep`",
             "`readr::read_csv`+ `pipe()` from `grep`",
             "`data.table::fread` from `awk`"
)

outDir <- file.path(rprojroot::find_rstudio_root_file(), "results")
out_files <- list.files(outDir, pattern = "*.txt", full.names = TRUE)

get_results_df <- function() {
    do.call(rbind,
    lapply(out_files, function(file) {
        x <- readLines(file)
        # print(x)
        mem_kb <- as.numeric(gsub(".*\\b(\\d+).*", "\\1",
                                  x[grep("Maximum resident", x)]))
        mem_mb <- mem_kb / 1024; mem_gb <- mem_mb / 1024

        real_row <- grep("^real", x); user_row <- grep("^user", x)
        real <- as.numeric(unlist(regmatches(x[real_row],
                                             gregexpr('?[0-9,.]+', x[real_row]))))
        user <- as.numeric(unlist(regmatches(x[user_row],
                                             gregexpr('?[0-9,.]+', x[user_row]))))
        real_secs <- real[1] * 60 + real[2]
        user_secs <- user[1] * 60 + user[2]

        data.frame(result_file = basename(file), rscript = x[1], mem_gb,
                   real_m = real[1], real_s = real[2], real_secs,
                   user_m = user[1], user_s = user[2], user_secs,
                   test_secs = (real_secs + user_secs) / 2,
                   avg_secs = (real_secs + user_secs) / 2 / 10,
                   stringsAsFactors = FALSE)
    })
    )
}

suppressPackageStartupMessages({
    library(dplyr)
})

get_results_summary <- function(col_names) {
    get_results_df() %>%
        arrange(-mem_gb) %>%
        mutate(id = as.numeric(substr(basename(rscript), 1, 2))) %>%
        mutate(description = rscripts[id]) %>%
        # select(script, description, mem_gb, avg_secs)
        select(col_names)
}

get_results_summary(col_names = c("description", "mem_gb", "avg_secs"))
