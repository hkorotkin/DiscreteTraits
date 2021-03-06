#You can use code you wrote for the correlation exercise here.
source("DiscreteFunctions.R")
source("CorrelationFunctions.R") # this isn't working?
tree <- get_study_tree("pg_2346","tree4944")
plot(tree,cex=0.3)
discrete.data <- as.matrix(read.csv(file="/Users/Hailee/Desktop/taxa.csv", stringsAsFactors=FALSE,row.names=NULL))#death to factors.
discrete.data2 <- as.matrix(read.csv(file="/Users/Hailee/Desktop/taxa.csv", stringsAsFactors=FALSE,row.names=1))#death to factors.

latitude<- rnorm(128,mean=89,sd=0.5)
height<-rnorm(128,mean=2,sd=0.5)
continuous.data<-cbind(latitude,height)
rownames(continuous.data)<-tree$tip.label


cleaned.continuous <- CleanData(tree, continuous.data)
cleaned.discrete <- CleanData(tree,discrete.data2)
VisualizeData(tree, cleaned.continuous)

VisualizeData(tree, cleaned.discrete)

#First, let's use parsimony to look at ancestral states
cleaned.discrete.phyDat <- phyDat(cleaned.discrete$data[,"saprotrophic"], type="USER",levels=c(0,1)) #phyDat is a data format used by phangorn
anc.p <- ancestral.pars(tree, cleaned.discrete.phyDat)
plotAnc(tree, anc.p, 1, cex.pie=0.3, cex=0.4)


#Do you see any uncertainty? What does that meean for parsimony?

#now plot the likelihood reconstruction
anc.ml <- ancestral.pml(pml(tree, cleaned.discrete.phyDat), type="ml")
plotAnc(tree, anc.ml, 1, cex.pie=0.3, cex=0.4)

#How does this differ from parsimony? 
#Why does it differ from parsimony?
#What does uncertainty mean?

#How many changes are there in your trait under parsimony? 
parsimony.score <-parsimony(tree,cleaned.discrete.phyDat)
print(parsimony.score)

#Can you estimate the number of changes under a likelihood-based model? 

#Well, we could look at branches where the reconstructed state changed from one end to the other. But that's not really a great approach: at best, it will underestimate the number of changes (we could have a change on a branch, then a change back, for example). A better approach is to use stochastic character mapping.

new.discrete<-as.vector(discrete.data2)
names(new.discrete)<-row.names(discrete.data2)

estimated.histories <- make.simmap(tree, new.discrete, model="ARD", nsim=5)

#always look to see if it seems reasonable
plotSimmap(estimated.histories, fsize=.3)

counts <- countSimmap(estimated.histories)
print(counts)

#Depending on your biological question, investigate additional approaches:
#  As in the correlation week, where hypotheses were examined by constraining rate matrices, one can constrain rates to examine hypotheses. corHMM, ape, and other packages have ways to address this.
#  Rates change over time, and this could be relevant to a biological question: have rates sped up post KT, for example. Look at the models in geiger for ways to do this.
#  You might observe rates for one trait but it could be affected by some other trait: you only evolve wings once on land, for example. corHMM can help investigate this.