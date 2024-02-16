library(parallel)
library(jsonlite)

numCores <- min(detectCores(), 7)
cl <- makeCluster(numCores)


files <- paste0("data/Video_Games/json_", 1:7, ".json.gz")

logger <- function(message) {
  writeLines(message, file('debug.log', open = 'a'), useBytes = TRUE)
}

read_and_parse_json_gz <- function(file_path) {
  logger(sprintf("Start Processing File %s ...", basename(file_path)))
  parsed_lines <- list()
  con <- gzfile(file_path, "r")
  
  line_counter <- 0
  while(TRUE) {
    line <- readLines(con, n = 1, warn = FALSE)
    if (length(line) == 0) {
      break
    }
    parsed_lines[[length(parsed_lines) + 1]] <- jsonlite::fromJSON(line)
    line_counter <- line_counter + 1
    
    if(line_counter %% 100000 == 0) {
      logger(sprintf("File %s: Processed %d lines", basename(file_path), line_counter))
    }
  }
  
  close(con)
  logger(sprintf("Completed Processing File %s", basename(file_path)))
  
  return(parsed_lines)
}

clusterExport(cl, varlist = c("logger"), envir = environment())

start_time <- Sys.time()
results <- parLapply(cl, files, read_and_parse_json_gz)

stopCluster(cl)
end_time <- Sys.time()

sprintf("Cost %s min", end_time - start_time)

