library(tidyverse)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
theme_set(theme_bw(18))
source("../../helpers.r")

# load data
r = read_csv("../data/comprehension_gan.csv")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

# positive effect of PriorExpectation on response for just "some" data
m = lmer(response ~ PriorExpectation + (1+PriorExpectation|workerid) + (1|Item), data=some,REML = F)
summary(m)

m.0 = lmer(response ~ (1+PriorExpectation|workerid) + (1|Item), data=some,REML = F)
summary(m.0)
  
anova(m.0,m) 

r$cPriorExpectation = r$PriorExpectation - mean(r$PriorExpectation)

# effect of PriorExpectation on interpretation of all quantifiers 
m = lmer(response ~ cPriorExpectation*quantifier + (1+quantifier+cPriorExpectation|workerid) + (1+quantifier|Item), data=r, REML=F)
summary(m)

# simple effects
m.simple = lmer(response ~ quantifier*cPriorExpectation - cPriorExpectation + (1+quantifier+cPriorExpectation|workerid) + (1+quantifier|Item), data=r, REML=F)
summary(m.simple)




