library(tidyverse)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
theme_set(theme_bw(18))

# load data from round 1
r1 = read_tsv("../data/sinking_marbles1.tsv") %>%
  select(workerid, rt, effect, cause,language,age,gender,other_gender,quantifier, object_level, response, object,num_objects,slide_number_in_experiment,enjoyment,asses,comments)

# load data from round 2
r2 = read_csv("../data/sinking_marbles2.csv") %>%
  select(workerid, rt, effect, cause,language,age,gender,other_gender,quantifier, object_level, response, object,num_objects,slide_number_in_experiment,enjoyment,asses,comments)
r2$workerid = r2$workerid + 120

# load smoothed prior data
prior = read_csv("../../../data/priors_gan_smoothed.csv") %>%
  gather(Number,Probability,-Item) %>%
  mutate(Number = as.numeric(Number)) %>%
  group_by(Item) %>%
  summarise(PriorExpectation = sum(Number*Probability))

# merge datasets
r = rbind(r1,r2)
r$trial = r$slide_number_in_experiment - 2
r$Item = as.factor(paste(r$effect,r$object))
r$ProportionResponse = r$response/r$num_objects

r = r %>%
  left_join(prior)

# write to file
write_csv(r, "../data/comprehension_gan.csv")
write_csv(r, "../../../data/comprehension_gan.csv")

# write reduced version to file for bda
bda = r %>%
  rename(subject="workerid",item="Item",utterance="quantifier") %>%
  mutate(measure="comp_state") %>%
  select(subject,item,utterance,response,measure)
write_csv(r, "../../../data/comprehension_gan_bda.csv")

##################

ggplot(aes(x=rt), data=r) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,20000))

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram(stat="count")

ggplot(aes(x=quantifier), data=r) +
  geom_histogram()

unique(r$comments)


