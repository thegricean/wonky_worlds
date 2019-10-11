setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/")
source("rscripts/helpers.r")

load("data/r.RData")
load("data/priors.RData")
nrow(nums)
summary(nums)

# plot empirical vs smoothed best guesses
pr = priors %>% gather(PriorType,Probability,EmpiricalProportion:SmoothedProportion)
head(pr)
ggplot(pr, aes(x=State,y=Probability,color=PriorType,group=PriorType)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/smoothed.vs.empirical.pdf",width=24,height=18)

## plot individual items best guesses with expectation
exps = priors %>% 
  group_by(Item) %>%
  summarise(expectation=sum(as.numeric(as.character(State))*SmoothedProportion))
exps = as.data.frame(exps)
row.names(exps) = exps$Item

priors$Expectation = exps[as.character(priors$Item),]$expectation
priors$It = factor(x=as.character(priors$Item),levels=unique(priors[order(priors[,c("Expectation")]),]$Item))
exps$It = factor(x=exps$Item, levels=levels(priors$It))

p=ggplot(priors, aes(x=State, y=SmoothedProportion, group=1)) +
  geom_point() +
  geom_line() +
  geom_vline(data=exps,aes(xintercept=expectation+1),color="red",size=1) +
  facet_wrap(~It)
ggsave(p,file="graphs/dists_with_expvalue.pdf",width=20,height=15)

# plot selected items to use as tracking test items in bayesian model comparison
items = droplevels(subset(priors, Item %in% c("stuck to the wall baseballs","sank balloons","fell down shelves","popped eggs","landed flat pancakes","sank marbles","melted ice cubes")))
it_exps = droplevels(subset(exps, Item %in% levels(items$Item)))

ggplot(items, aes(x=State, y=SmoothedProportion, group=1)) +
  geom_point() +
  geom_line() +
  geom_vline(data=it_exps,aes(xintercept=expectation+1),color="red",size=1) +
  geom_text(data=it_exps,x=7,y=.5,aes(label=as.character(round(expectation,1)))) +
  facet_wrap(~It)
ggsave(file="graphs/dists_with_expvalue_selected.pdf",width=8,height=5)

# plot original smoothed vs current smoothed vs slider best guesses
priors$NumberTask = priors$OriginalSmoothedProportion
priors$FourStepNumberTask = priors$SmoothedProportion
priors$BinnedHistogram = priors$SliderPrior
pr = priors %>% gather(PriorType,Probability,NumberTask:BinnedHistogram)
head(pr)
ggplot(pr, aes(x=State,y=Probability,color=PriorType,group=PriorType)) +
  geom_point() +
  geom_errorbar(aes(ymin=SliderPriorYMin,ymax=SliderPriorYMax)) +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/original.vs.current.smoothed.priors.pdf",width=24,height=18)
ggsave(file="graphs/priors.png",width=24,height=18)


subs = droplevels(subset(pr, Item %in% c("sank marbles") & PriorType == "NumberTask"))
nrow(subs)
sum(as.numeric(as.character(subs$State))*subs$Probability)

ggplot(subs, aes(x=State,y=Probability,group=1)) +
  geom_point() +
  geom_line() +
  geom_vline(xintercept=14.85,color="darkred",size=1.5)
ggsave("graphs/mxprag-mean.png",width=7)

ggplot(subs, aes(x=State,y=Probability,group=1)) +
  geom_point() +
  geom_line() +
  geom_vline(xintercept=16,color="darkred",size=1.5,linetype="dashed")+
  geom_hline(yintercept=.65,color="darkred",size=1.5)
ggsave("graphs/mxprag-allstate.png",width=7)

# histogram of trial types
ggplot(r,aes(x=Item)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# subject variability
r$Half = as.factor(ifelse(r$trial < 8, 1, 2))
ggplot(r,aes(x=responsetype,y=response,color=Half)) +
  geom_point() +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=20,height=20)

# weird people (hardly any variance in responses)
#badresponders = c("0","16")#,"6","13","16")

# r = droplevels(subset(r, ! workerid %in% badresponders))
# nrow(tmp)
# nrow(r)

nums = droplevels(subset(r, responsetype != "confidence"))

agr = aggregate(response ~ responsetype + Item, FUN=mean, data=nums)
agr$CILow = aggregate(response ~ responsetype + Item, FUN=ci.low, data=nums)$response
agr$CIHigh = aggregate(response ~ responsetype + Item, FUN=ci.high, data=nums)$response
agr$YMin = agr$response - agr$CILow
agr$YMax = agr$response + agr$CIHigh

ggplot(agr, aes(x=responsetype, y=response)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~Item) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave("graphs/means.pdf",width=20,height=18)

# as histograms
ggplot(nums, aes(x=response,fill=responsetype)) +
  geom_histogram(alpha=.5,position="identity") +
  facet_wrap(~Item,scales="free_y")
ggsave("graphs/histograms.pdf",width=24,height=18)

# as densities
ggplot(nums, aes(x=response,fill=responsetype)) +
  geom_density(alpha=.5) +
  facet_wrap(~Item,scales="free_y")
ggsave("graphs/densities.pdf",width=24,height=18)

# as probability dists
t = as.data.frame(prop.table(table(nums$response, nums$responsetype, nums$Item),mar=c(2,3)))
head(t)
colnames(t) = c("State","ResponseType","Item","Proportion")
ggplot(t, aes(x=State,y=Proportion,fill=ResponseType)) +
  geom_bar(alpha=.5,stat="identity",position="identity") +
  facet_wrap(~Item,scales="free_y")
ggsave("graphs/prob_histograms.pdf",width=24,height=18)

# dists of only best guesses
t = as.data.frame(prop.table(table(nums[nums$responsetype == "best_guess",]$response, nums[nums$responsetype == "best_guess",]$Item),mar=c(2)))
head(t)
colnames(t) = c("State","Item","Proportion")
ggplot(t, aes(x=State,y=Proportion)) +
  geom_bar(stat="identity",position="identity") +
  facet_wrap(~Item,scales="free_y")
ggsave("graphs/prob_histograms_bestguesses.pdf",width=24,height=18)

# plot confidence
confidence = droplevels(subset(r, responsetype == "confidence"))
nrow(confidence)
head(confidence)
agr = aggregate(response ~ Item, data=confidence, FUN="mean")
agr$CILow = aggregate(response ~ Item, FUN=ci.low, data=confidence)$response
agr$CIHigh = aggregate(response ~ Item, FUN=ci.high, data=confidence)$response
agr$YMin = agr$response - agr$CILow
agr$YMax = agr$response + agr$CIHigh
agr = agr[order(agr[,c("response")]),]
write.table(agr, file="data/confidence.txt", row.names=F, quote=F, sep="\t")
agr$It = factor(x=as.character(agr$Item),levels=as.character(agr$Item))

ggplot(agr, aes(x=It, y=response)) +
  geom_bar(stat="identity",fill="gray60",color="black") +
  geom_errorbar(aes(ymin=YMin, ymax=YMax),width=.25) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1,size=8))
ggsave("graphs/confidence_by_item.pdf",width=15,height=8)

ggplot(confidence, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~workerid)
ggsave("graphs/confidence_by_subject.pdf",width=25,height=20)

ggplot(confidence, aes(x=response,fill=gender.1)) + 
  geom_density(alpha=.3)
ggsave("graphs/confidence_by_gender.pdf")



# plot interval size as a function of mean best guess
summary(r)
spr = r %>% 
  select(responsetype,response,Item,workerid,gender.1) %>%
  spread(responsetype,response)
summary(spr)
spr$interval = spr$ci_high - spr$ci_low

library(lmerTest)
m = lmer(confidence ~ gender.1 + poly(interval,2) + poly(best_guess,2) +  (1|workerid) + (1|Item), data=spr)
summary(m)

agr = aggregate(best_guess ~ Item, data=spr, FUN=mean)
agr$CIHigh = aggregate(best_guess ~ Item, data=spr, FUN=ci.high)$best_guess
agr$CILow = aggregate(best_guess ~ Item, data=spr, FUN=ci.low)$best_guess
agr$YMin = agr$best_guess - agr$CILow
agr$YMax = agr$best_guess + agr$CIHigh
agr$IntervalSize = aggregate(interval ~ Item, data=spr, FUN=mean)$interval
agr$ICIHigh = aggregate(interval ~ Item, data=spr, FUN=ci.high)$interval
agr$ICILow = aggregate(interval ~ Item, data=spr, FUN=ci.low)$interval
agr$IYMin = agr$IntervalSize - agr$ICILow
agr$IYMax = agr$IntervalSize + agr$ICIHigh

ggplot(agr, aes(x=best_guess,y=IntervalSize)) +
  geom_point() +
  geom_smooth() +
  geom_errorbar(aes(ymin=IYMin,ymax=IYMax)) +
  geom_errorbarh(aes(xmin=YMin,xmax=YMax)) +
  geom_text(aes(label=Item,y=IntervalSize-.2),color="red",size=2)
ggsave("graphs/intervalsize_by_expectation.pdf")

# plot expected value as a function of confidence
numconf = r %>%
  filter(responsetype %in% c("confidence","best_guess")) %>%
  select(responsetype,response,Item,workerid) %>%
  spread(responsetype,response) %>%
  group_by(Item) %>%
  summarise(mean.best_guess = mean(best_guess), mean.confidence=mean(confidence),min.c = ci.low(confidence), max.c = ci.high(confidence), min.r = ci.low(best_guess), max.r = ci.high(best_guess))

ggplot(numconf, aes(x=mean.best_guess,y=mean.confidence)) +
  geom_point() +
  geom_smooth() #+
#  geom_errorbar(aes(ymin=mean.confidence-min.c,ymax=mean.confidence+max.c)) +
#  geom_errorbarh(aes(xmin=mean.best_guess-min.r,xmax=mean.best_guess+max.r))  
#  geom_text(aes(label=Item))
ggsave("graphs/confidence_by_expvalue.pdf")

