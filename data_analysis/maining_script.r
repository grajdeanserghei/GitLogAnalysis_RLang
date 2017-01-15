install.packages('ggplot2')
install.packages("data.table")
install.packages("stargazer")

library(stargazer)


setwd('f:/Projects/Courses/uvt/RLang/Teza/')

Sys.setlocale(locale='us')

setClass('git_date')
setAs("character","git_date", function(from) strptime(from, "  %a %b %e %H:%M:%S %Y %z"))

dataset <- read.csv('commit_log.csv', colClasses = c('factor', 'factor', 'factor', 'git_date', 'factor', 'integer', 'integer'))
attach(dataset)

stats.summary <- summary(dataset)
stats.summary[,1:3]
stats.summary[,4:7]

subset(dataset, is.na(date))

stats.unique.authors <- unique(dataset$author)
stats.unique.commits <- unique(dataset$id)

length((unique(dataset$author)))
length(unique(dataset$id))

library(ggplot2)
library(data.table)

qplot(factor(author), data = dataset, geom = "bar", xlab = "Authors")
qplot(factor(added), data = dataset, geom = "bar", xlab = "Number of added lines in a file")
qplot(factor(removed), data = dataset, geom = "bar", xlab = "Number of removed lines in a file")

stats.authors_freq <- as.data.frame(table(dataset$author))
colnames(stats.authors_freq) <- c("Author", "Freq")
stats.top_authors <- subset(stats.authors_freq, Freq >= mean(stats.authors_freq$Freq))
ggplot(data = stats.top_authors, aes(x=Author, y=Freq)) + geom_histogram(stat = "identity")

stats.added_freq <- as.data.frame(table(dataset$added))
colnames(stats.added_freq) <- c("Added", "Freq")
stats.top_adds <- subset(stats.added_freq, Freq > mean(dataset$added))
ggplot(data = stats.top_adds, aes(x=Added, y=Freq)) + geom_histogram(stat = "identity")

stats.removed_freq <- as.data.frame(table(dataset$removed))
colnames(stats.removed_freq) <- c("Removed", "Freq")
stats.top_removes <- subset(stats.removed_freq, Freq > mean(dataset$removed))
ggplot(data = stats.top_removes, aes(x=Removed, y=Freq)) + geom_histogram(stat = "identity")


by(dataset$date, dataset$author, summary)
qplot(author, date, data=dataset, geom="boxplot", fill=author) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

qplot(added, data=dataset, geom="density", fill=author) + theme(axis.text.x = element_text(angle = 90, hjust = 1))



