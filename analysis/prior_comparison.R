library(tidyverse)
library(np)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("helpers.r")
theme_set(theme_bw(18))

# load the smoothed one-step number task priors and binned histogram priors and plot alongside 4step
gan = read.csv("../data/priors_gan_smoothed.csv") %>%
  gather(State,Proportion,-Item) %>%
  mutate(State=as.numeric(as.character(gsub("X","",State))),Type = "OneStepNumberTaskProportion")

binned = read.csv("../../data/priors_binnedhistogram_smoothed.csv") %>%
  gather(State,Proportion,-Item) %>%
  mutate(State=as.numeric(as.character(gsub("X","",State))),Type = "BinnedHistogramProportion")

fourstep = read.csv("../data/priors_fourstep_smoothed.csv") %>%
  gather(State,Proportion,-Item) %>%
  mutate(State=as.numeric(as.character(gsub("X","",State))),Type = "OneStepNumberTaskProportion")

allpriors = gpriors %>%
  bind_rows(gan) %>%
  bind_rows(binned)

ggplot(allpriors,aes(State,y=Proportion,color=Type)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
# ggsave(file="../graphs/allpriors.pdf",width=17,height=14)