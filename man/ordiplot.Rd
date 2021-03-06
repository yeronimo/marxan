% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/MarxanResults.R, R/MarxanSolved.R, R/generics.R
\name{ordiplot.MarxanResults}
\alias{ordiplot}
\alias{ordiplot.MarxanResults}
\alias{ordiplot.MarxanSolved}
\title{Ordination plot of Marxan solutions}
\usage{
\method{ordiplot}{MarxanResults}(x, type = "mds", var = "selections",
  nbest = 1, ..., force_reset = FALSE)

\method{ordiplot}{MarxanSolved}(x, type = "mds", var = "selections",
  nbest = 1, ..., force_reset = FALSE)

ordiplot(x, ...)
}
\arguments{
\item{x}{"MarxanResults" or "MarxanSolved" object.}

\item{type}{"character" use 'mds' or 'pca' for analysis?}

\item{var}{"character" should solutions be compared based on selections ('selections'), or the amount held ('amountheld'), number of occurances ('occheld'), or whether the targets have been met for each species ('targetsmet')?}

\item{nbest}{"integer" color the n best solutions in "red"}

\item{...}{arguments to \code{\link[vegan]{monoMDS}}, \code{\link[stats]{prcomp}}, \code{\link{mds.MarxanResults}}, and \code{\link{pca.MarxanResults}}. For instance, to use euclidean distances, use dist='euclidean'.}

\item{force_reset}{"logical" should analysis be rerun even if it is stored in the cache?}
}
\value{
"prcomp" or "monoMDS" object.
}
\description{
This function makes an ordination plot to visualise the differences between solutions using dimension reduction techniques (ie. NMDS or PCA).
Numbers indicate solution ids. The size of the number on your screen indicates relative solution quality ('score').
Distance matrices and results from multivariate analyses are cached to permit rapid display.
}
\seealso{
\code{\link{MarxanSolved-class}}, \code{\link{marxan}}.
}

