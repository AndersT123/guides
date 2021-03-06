# Script writing to task folder
cmd <- cronR::cron_rscript(paste0(here::here(),"/scheduling-rscripts/add-time2.R"))
cmd2 <- glue::glue("cd '{here::here()}' && ")
cmd3 <- paste0(cmd2,cmd)

cronR::cron_add(cmd3, frequency = "minutely", id = "portable")


## Script writing to database:
cmd <- cronR::cron_rscript(paste0(here::here(),"/scheduling-rscripts/cron-db.R"))
cmd2 <- glue::glue("cd '{here::here()}' && ")
cmd3 <- paste0(cmd2,cmd)

cronR::cron_add(cmd3, frequency = "minutely", id = "portable")
