con <- file("run_all.log")
sink(con, append=TRUE, split=TRUE)

fb100_url <- "https://archive.org/download/oxford-2005-facebook-matrix/facebook100.zip"
survey_url <- "https://www.dennisfeehan.org/assets/hanoi-survey.zip"

root.dir <- "hanoi-paper-release"
code.dir <- file.path(root.dir, 'code') 

###########
## create directories
out.dir <- file.path(root.dir, 'out')
sim.out.dir <- file.path(out.dir, 'sim')
survey.out.dir <- file.path(out.dir, 'survey')

rdknownprobe.out.dir <- file.path(sim.out.dir, 'rdknownprobe')
rdestprobe.out.dir <- file.path(sim.out.dir, 'rdestprobe')

raw.data.dir <- file.path(root.dir, 'raw-data')
fb100.dir <- file.path(raw.data.dir, "fb100")

data.dir <- file.path(root.dir, 'data')
sim.data.dir <- file.path(data.dir, 'sim')
svy.data.dir <- file.path(data.dir, 'survey')

dir.create(out.dir, showWarnings=FALSE)
dir.create(sim.out.dir, showWarnings=FALSE)
dir.create(survey.out.dir, showWarnings=FALSE)
dir.create(rdknownprobe.out.dir, showWarnings=FALSE)
dir.create(rdestprobe.out.dir, showWarnings=FALSE)

dir.create(data.dir, showWarnings=FALSE)
dir.create(sim.data.dir, showWarnings=FALSE)
dir.create(svy.data.dir, showWarnings=FALSE)

dir.create(raw.data.dir, showWarnings=FALSE)
dir.create(fb100.dir, showWarnings=FALSE)

###################
## download the fb100 data from the Internet Archive
httr::GET(url = fb100_url,
          httr::write_disk(file.path(fb100.dir, 'facebook100.zip'),
                           overwrite = TRUE))

## unzip the fb100 data
unzip(file.path(fb100.dir, "facebook100.zip"),
      exdir=file.path(fb100.dir))

###################
## download the survey data 
httr::GET(url = survey_url,
          httr::write_disk(file.path(data.dir, 'survey.zip'),
                           overwrite = TRUE))

## unzip the survey data
unzip(file.path(data.dir, "survey.zip"),
      exdir=file.path(data.dir))

## Run all of the scripts
rmd_files <- list.files(path=code.dir, pattern=".Rmd")

for (cur_file in rmd_files) {
  cat("================================\n")
  tictoc::tic(glue::glue("Running {cur_file}"))
  cat("Running ", cur_file, "\n")
  rmarkdown::render(file.path(code.dir, cur_file))
  tictoc::toc()
  cat("================================\n")
}

sink()
