library(tidyverse)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
theme_set(theme_bw(18))

# load helper functions
source("../../helpers.r")

# load color-blind and bw-friendly color palette
cbbPalette <- c("#000000", "#009E73", "#e79f00", "#9ad0f3", "#0072B2", "#D55E00", "#CC79A7", "#F0E442")

# load data
r = read_csv("../data/comprehension_gan.csv")
r$PriorExpectationProportion = r$PriorExpectation/15

# historgram of by-participant responses
p=ggplot(r, aes(x=response,fill=quantifier)) +
  geom_histogram(position="dodge") +
  facet_wrap(~workerid)
ggsave("../graphs/by-subject-variation.pdf",width=25,height=25)

agr = r %>%
  group_by(PriorExpectationProportion,quantifier,Item) %>%
  summarise(ProportionResponse = mean(ProportionResponse), CILow=ci.low(ProportionResponse),CIHigh=ci.high(ProportionResponse)) %>%
  ungroup() %>%
  mutate(YMin=ProportionResponse-CILow,YMax=ProportionResponse+CIHigh)
agr = agr %>%
  rename(Quantifier=quantifier) %>%
  mutate(Quantifier = fct_recode(Quantifier, some="Some", all="All", none="None"))
  mutate(quantifier = fct_relevel(quantifier,"some","all","none","short_filler"))

min(agr[agr$quantifier == "Some",]$ProportionResponse)
max(agr[agr$quantifier == "Some",]$ProportionResponse)

# plot mean responses by item and quantifier as a function of prior expectation
ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse, color=Quantifier)) +
  geom_point() +
#  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_color_manual(values=cbbPalette) +
  scale_y_continuous(breaks=seq(0,1,0.1),name="Posterior expected proportion of  objects") +
  scale_x_continuous(breaks=seq(0,1,0.1),name="Prior expected proportion of  objects")  
ggsave(file="../graphs/mean_responses.pdf",width=7.5,height=5.5)


# plot participant responses separately depending on whether they are literal "all" and "none" responders (defined as giving on average > .85 proportion on "all" trials and  <.15 proportion on "none" trials). we don't exclude the non-literal subjects because they help us get noise estimates
all = aggregate(ProportionResponse~workerid, data=r[r$quantifier == "All",], FUN=mean)
nrow(all)
head(all)
sort(all$ProportionResponse)
row.names(all) = all$workerid

none = aggregate(ProportionResponse~workerid, data=r[r$quantifier == "None",], FUN=mean)
nrow(none)
head(none)
sort(none$ProportionResponse)
row.names(none) = none$workerid

r$LiteralAll = (all[as.character(r$workerid),]$ProportionResponse > .85)
r$LiteralNone = (none[as.character(r$workerid),]$ProportionResponse < .15)
r$Literal = r$LiteralAll & r$LiteralNone

agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item + Literal,data=r,FUN=mean)

ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~Literal)
