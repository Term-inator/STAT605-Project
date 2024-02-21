library(parallel)
library(jsonlite)
library(dplyr)
library(purrr)


logger <- function(message) {
  writeLines(message, file('debug.log', open = 'a'), useBytes = TRUE)
}

read_file <- function(file_path, to_data.frame = TRUE) {
  """
  Read data from one file
  @param file_path
  @param to_data.frame: covert the result(list) to data.frame
  @example
  meta_file <- 'data/meta_Video_Games.json.gz'
  meta_data <- read_file(meta_file)
  """
  logger(sprintf("Start Processing File %s ..., to_data.frame: %s", basename(file_path), to_data.frame))
  con <- gzfile(file_path, "r")
  parsed_lines <- list()
  
  line_counter <- 0
  while(TRUE) {
    line <- readLines(con, n = 1, warn = FALSE)
    if (length(line) == 0) {
      break
    }
    parsed_lines[[length(parsed_lines) + 1]] <- jsonlite::fromJSON(line, simplifyVector = FALSE)
    line_counter <- line_counter + 1
    
    if(line_counter %% 100000 == 0) {
      logger(sprintf("File %s: Processed %d lines", basename(file_path), line_counter))
    }
  }
  
  close(con)
  
  if (to_data.frame) {
    result <- dplyr::bind_rows(lapply(parsed_lines, function(x) as.data.frame(t(x), stringsAsFactors = FALSE)))
  }
  else {
    result <- parsed_lines
  }
  
  logger(sprintf("Completed Processing File %s", basename(file_path)))
  
  return(result)
}

read_files <- function (files, to_data.frame = TRUE, merge = FALSE) {
  """
  Read data from multiple files in parellel
  @param files: a vector of file path
  @param to_data.frame: covert the result(list) to data.frame
  @param merge: merge results from these files
  @example
  review_files <- paste0('data/Video_Games/json_', 1:8, '.json.gz')
  review_data <- read_files(review_files)
  """
  num_cores <- min(c(detectCores(), length(files), 8))
  cl <- makeCluster(num_cores)
  clusterExport(cl, varlist = c("logger", "read_file"), envir = environment())
  
  params_list <- lapply(files, function(file) {
    list(file_path=file, to_data.frame = to_data.frame)
  })
  
  start_time <- Sys.time()
  results <- clusterApplyLB(cl, params_list, function(params) {
    read_file(params$file_path, params$to_data.frame)
  })

  stopCluster(cl)
  end_time <- Sys.time()
  print(sprintf("Cost %s min", end_time - start_time))
  
  if (!merge) {
    return(results)
  }
  
  start_time <- Sys.time()
  if (to_data.frame) {
    parsed_data <- bind_rows(results)
  }
  else {
    parsed_data <- flatten(results)
  }
  end_time <- Sys.time()
  
  print(sprintf("Merge %s min", end_time - start_time))
  
  return(parsed_data)
}

