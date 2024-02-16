library(jsonlite)


read_and_parse_json_gz <- function(file_path) {
  print(sprintf("Start Processing File %s ...", basename(file_path)))
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
      print(sprintf("File %s: Processed %d lines", basename(file_path), line_counter))
    }
  }
  
  close(con)
  print(sprintf("Completed Processing File %s", basename(file_path)))
  
  return(parsed_lines)
}

start_time <- Sys.time()
read_and_parse_json_gz("data/Video_Games.json.gz")
end_time <- Sys.time()

print(sprintf("Cost %s min", end_time - start_time))