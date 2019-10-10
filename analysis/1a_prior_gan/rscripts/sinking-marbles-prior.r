library(tidyverse)
library(Hmisc)
library(MuMIn)
library(np)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# smoothing function
getSmoothedProbability = function(d) {
   smooth = (npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)/sum(npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)
   return (smooth/sum(smooth))
}

# load data from round 1
r1 = read_tsv("../data/sinking_marbles1.tsv") %>%
  select(workerid, rt, effect, cause, object_level, response, object)

# load data from round 2
r2 = read_csv("../data/sinking_marbles2.csv") %>%
  select(workerid, rt, effect, cause, object_level, response, object)
r2$workerid = r2$workerid + 60

# merge the two datasets
r = rbind(r1,r2)
r$Item = as.factor(paste(r$effect,r$object))

# write the merged datasets to file 
write_csv(r %>% select(workerid,Item,response), "../data/priors_gan.csv")

## plot subject variability
p = ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~workerid)
ggsave(file="../graphs/subject_variability.pdf",width=20,height=15)

# how many judgments per item
min(table(r$Item))
max(table(r$Item))
t = as.data.frame(table(r$Item))
t[order(t[,c("Freq")]),]

## plot individual items
r$Item = as.factor(paste(r$effect,r$object))
p=ggplot(r, aes(x=response)) +
  geom_histogram(stat="count") +
  facet_wrap(~Item)
ggsave(file="../graphs/item_variability.pdf",width=20,height=15)

# get smoothed priors for model 
smoothed = r %>%
  group_by(Item) %>%
  nest() %>%
  mutate(SmoothedProportion = map(data,getSmoothedProbability)) %>%
  select(-data) %>%
  unnest() %>%
  mutate(State = rep(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),length(unique(Item))))

ggplot(smoothed, aes(x=State,y=SmoothedProportion)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)

smoothed_spread = smoothed %>%
  spread(State,SmoothedProportion)
write_csv(smoothed_spread,"../data/priors_gan_smoothed.csv")

# get empirical unsmoothed priors
priors = as.data.frame(prop.table(table(r$Item,r$response),mar=c(1)))
colnames(priors) = c("Item","State","EmpiricalProportion")
priors = priors %>% 
  mutate(State = as.numeric(as.character(State))) %>%
  left_join(smoothed,by=c("Item","State"))
head(priors)

gpriors = priors %>%
  gather(Type,Proportion,-Item,-State) 

ggplot(gpriors,aes(State,y=Proportion,color=Type)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="../graphs/empirical-smoothed.pdf",width=15,height=13)
