# Script to be executed with cronR. 
# Write to RDS MySQL database. table name: cron_test with fields: id, date_as_char. id is auto incremented write only to date_as_char

library(DBI)
#1. open connection
conf <- config::get(file = "./scheduling-rscripts/config.yml")

write_db <- function(query) {
  con <- dbConnect(
    drv = RMariaDB::MariaDB(),
    dbname = conf$dbname,
    username = conf$username,
    password = conf$password,
    host = conf$host,
    port = conf$port
  )
  on.exit(dbDisconnect(con), add = TRUE)
  dbExecute(con, query)
}
date_now <- as.character(Sys.time())
write_db(paste0("insert into cron_test (date_as_char) values ('", date_now, "');"))
