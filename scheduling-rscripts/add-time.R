
file_name <- paste0(here::here(), "/scheduling-rscripts/auto-test.txt")

if(!file.exists(file_name)) file.create(file_name)

write.table(Sys.time(), file = file_name, append = TRUE, row.names = FALSE, col.names = FALSE)
