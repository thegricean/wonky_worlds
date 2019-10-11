library(tidyverse)
library(np)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("../../helpers.r")
theme_set(theme_bw(18))

getSmoothedProbability = function(d) {
  smooth = (npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)/sum(npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)
  return (smooth/sum(smooth))
}


# load data from round 1
r1 = read_csv("../data/sinking_marbles1.csv")

# load data from round 2
r2 = read_csv("../data/sinking_marbles2.csv")
r2$workerid = r2$workerid + 60

# merge the two datasets
r = rbind(r1,r2)
r$Item = as.factor(paste(r$effect,r$object))
r$trial = r$slide_number_in_experiment - 2
r$Item = as.factor(paste(r$effect,r$object))

# dataset with metadata
r = r %>%
  select(assignmentid,workerid, rt, cause, effect,language,age,gender, response, object,num_objects,trial,enjoyment,asses,comments,Answer.time_in_minutes,responsetype,Item)

# reduce dataset to bare bones
r = r %>% 
  select(workerid,Item,responsetype,response)

# exclude people who didn't understand task; exclude trials with reversed intervals
spr = r %>% 
  select(responsetype,response,Item,workerid) %>%
  spread(responsetype,response) 

spr$interval = as.numeric(as.character(spr$ci_high)) - as.numeric(as.character(spr$ci_low))
summary(spr)

# are there cases where people reversed low and high ci value?
spr[spr$interval < 0,]

# exclude these 10 trials, and also exclude subject 109 who reversed on 7 trials
r = droplevels(subset(r, workerid != 109))
r = droplevels(subset(r, workerid != 50 | Item != "dissolved oreos"))
r = droplevels(subset(r, workerid != 12 | Item != "melted pencils"))
r = droplevels(subset(r, workerid != 103 | Item != "popped eggs"))
nrow(r)/7200 # 7128 cases left, ie 1% exclusions

# write the merged datasets to file 
write_csv(r, "../data/priors_fourstep.csv")

# get smoothed priors for model 
smoothed = r %>%
  filter(responsetype == "best_guess") %>%
  select(Item,response) %>%
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

# write data for bayesian data analysis
smoothed_spread = smoothed %>%
  spread(State,SmoothedProportion)
write.csv(smoothed_spread,file="../data/priors_fourstep_smoothed.csv",row.names=F,quote=F)
write.csv(smoothed_spread,file="../../../data/priors_fourstep_smoothed.csv",row.names=F,quote=F)

# get empirical unsmoothed priors
bg = r %>% filter(responsetype == "best_guess")
priors = as.data.frame(prop.table(table(bg$Item,bg$response),mar=c(1)))
colnames(priors) = c("Item","State","EmpiricalProportion4Step")
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
ggsave(file="../graphs/empirical-smoothed.pdf",width=22,height=17)
