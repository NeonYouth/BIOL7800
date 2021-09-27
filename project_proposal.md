---
output:
  pdf_document: default
  html_document: default
---
# Predicting Potential Viral-hosts Using Host Ecological Trait Data
## Nevyn Neal
## BIOL 7800 - Data Science - Final Project Proposal
### September 26, 2021


## Project Overview
In this project, I will combine host-virus interaction data from the world's largest database of host-virus associations, [VIRION](https://github.com/viralemergence/virion), with the life-history data of numerous hosts contained within the ecological trait datasets of the *traitdataform* [R package.](https://github.com/EcologicalTraitData/traitdataform) This package contains ~20 unique life-history traits for each of >5000 host species. 

With this combined dataset of host-virus associations and life-history traits of each host species, I will develop a series of statistical and machine-learning models to predict the host species that can be infected by a given virus. 

## Background and Motivation
The SARS-CoV-2 virus demonstrated the innumerable benefits of predicting the possible host-species that are likely to be infected by a particular virus well before cross-species transmission events occur. As such, there have been several tools developed in the past 2 years to establish and improve the accuracy of these predictions. One notable example of this kind of predictive tool is described in Wardeh et al., 2021, in which they developed a method to identify host species that were most likely to be sources of novel coronaviruses. They represented existing host-conoronavirus associations with a bipartite graph, and used the graph-learning algorithm, DeepWalk, in addition to >4000 coronavirus genome sequences to predict host species in the most immediate danger of developing novel coronaviruses. Wardeh et al., 2021 is representative of most studies, in which genetic data is used as the basis of their host-virus association predictions, however, this data may not always be immediately available following the discovery of a novel host species or viral species. Instead, the ecological trait data available for a large number of hosts, along with existing host-virus association data could be used to develop predictive models with the same output. If this data cannot be used to predict potential hosts as accurately as ones based on genomic data, they could perhaps be combined to supplement existing predictive models and improve their accuracy.

## Analysis
The ultimate goal of this project is to develop a working model to predict potential host species of a given virus with the highest accuracy possible. This entails training several models (starting with logistric regression models, and eventually deep learning models like DeepWalk) using different combinations ecological traits as inputs. As a result, I will have answered the following questions:

- Which traits from the ecological trait dataset provide the most predictive power?
- Which models are most effective in predicting potential hosts for a given virus?
- Are these models accurate enough to stand alone, or is genomic data necessary for predicting potential hosts?


