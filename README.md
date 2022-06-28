# Hanoi paper code

This directory has the code needed to replicate the results in the Hanoi
network tie survey paper.


* `code/` - has the code used in the analysis
* `data/` - [will be created by a script] has the survey data used in the analysis
            (NOTE: because of its size, the data are not included in the git repo; they will be downloaded by the script 00-run-all.r)
* `out/`  - [will be created by a script] where the results of the scripts get saved (this is also not included in the git repo; it gets created by the scripts)

## DATA

The script, `00-run-all.r` will download the data you need for you.
(And you can look at that script if you want to donwload the data yourself.)

## CODE

These scripts were run on a 2020 Macbook Pro with 8 cores and 64 GB of memory.
Because of the large number of bootstrap resamples, some of the files take time to run.
We try to give a rough sense for expected runtime below by providing estimated runtimes
for files that take longer than 5 minutes.

* `00-run-all.R` - this file downloads the data and runs all of the scripts
* `11_fb100_prep.Rmd` - this file prepares the fb100 data


## DOCKER

It is likely that you have different versions of R and specific R packages than we did
when we wrote our code.  Thus, we recommend using Docker to replicate our results.
Using Docker will ensure that you have exactly the same computing environment that we did
when we conducted our analyses.

To use Docker

1. [Install Docker Desktop](https://www.docker.com/get-started) (if you don't already have it)
1. Clone this repository
1. Be sure that your current working directory is the one that you downloaded the repository into. It's probably called `hanoi-paper-release/`
1. Build the docker image.
        `docker build --rm -t hanoi-replication .`
   This step will likely take a little time, as Docker builds your image (including installing various R packages)
1. Run the docker image
        `docker run -d --rm -p 8888:8787 -e PASSWORD=pass --name hanoi hanoi-replication`
1. Open a web browser and point it to localhost:8888
1. Log onto Rstudio with username 'rstudio' and password 'pass'
1. Open the file `hanoi-paper-release/code/00-run-all.r`
1. Running the file should replicate everything. 
