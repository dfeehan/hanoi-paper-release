FROM rocker/verse:4.0.2

# copy working files over
COPY . /home/rstudio/hanoi-paper-release

# install dependencies described in DESCRIPTION file
RUN Rscript -e "remotes::install_github('dfeehan/surveybootstrap@9ba432c')"
RUN Rscript -e "remotes::install_github('dfeehan/networkreporting@27acedc')"
RUN Rscript -e "remotes::install_github('dfeehan/nrsimulatr@f539c54')"

RUN Rscript -e "devtools::install_deps('/home/rstudio/hanoi-paper-release')"

RUN touch /home/rstudio/hanoi-paper-release/.here

RUN chown -R rstudio /home/rstudio





