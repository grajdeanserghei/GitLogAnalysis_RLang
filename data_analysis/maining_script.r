install.packages('ggplot2')
install.packages("data.table")
install.packages("stargazer")
install.packages('car')

library(stargazer)
library(ggplot2)
library(data.table)
library(car)

setwd('F:/Projects/Courses/uvt/RLang/Teza/repository/data_analysis')

Sys.setlocale(locale='us')

setClass('git_date')
setAs("character","git_date", function(from) strptime(from, "  %a %b %e %H:%M:%S %Y %z"))

dataset <- read.csv('commit_log.csv', colClasses = c('factor', 'factor', 'factor', 'git_date', 'factor', 'integer', 'integer'))
attach(dataset)

stats.summary <- summary(dataset)
stats.summary[,1:3]
stats.summary[,4:7]


subset(dataset, is.na(date))

subset(dataset, is.na(date))

stats.unique.authors <- unique(dataset$author)
stats.unique.commits <- unique(dataset$id)

length((unique(dataset$author)))
length(unique(dataset$id))



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


# by(dataset$date, dataset$author, summary)
qplot(author, date, data=dataset, geom="boxplot", fill=author) + theme(axis.text.x = element_text(angle = 90, hjust = 1))


# qplot(added, data=dataset, geom="density", fill=author) + theme(axis.text.x = element_text(angle = 90, hjust = 1))


qplot(factor(date$hour), data = dataset, geom = "bar", xlab = "Hours")
qplot(author, date$hour, data=dataset, geom="boxplot", fill=author, ylab = 'Hours', xlab = ) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

kruskal.test(date$hour ~ author, data=dataset)

#----- Logistic regression

accuracy <- function(predictions, answers){
  sum((predictions==answers)/(length(answers)))
}



dataset.valid_date = subset(dataset, !is.na(dataset$date))
dataset.valid_date$hour = dataset.valid_date$date$hour
dataset.valid_date$wday = dataset.valid_date$date$wday
dataset.valid_date$is_owner =  with(dataset.valid_date, author == 'Mark Seemann')

nrow(dataset.valid_date[dataset.valid_date$is_owner == TRUE, ]) /nrow(dataset.valid_date)

ntrain <- round(nrow(dataset.valid_date)*4/5)
train <- sample(1:nrow(dataset.valid_date), ntrain)
training <- dataset.valid_date[train,]
testing <- dataset.valid_date[-train,]

model <- glm(is_owner~date$hour, data=training, family=binomial(logit))
model <- glm(is_owner~date$hour + date$year, data=training, family=binomial(logit))

model <- glm(is_owner~date$hour+date$wday+date$year+added+removed, data=training, family=binomial(logit))
summary(model)


predictions <- round(predict(model, training, type="response"))
predictions <- ifelse(predictions == 1, TRUE, FALSE)
accuracy(predictions, training$is_owner)

predictions <- round(predict(model, testing, type="response"))
predictions <- ifelse(predictions == 1, TRUE, FALSE)
accuracy(predictions, testing$is_owner)



#-----------------------


install.packages("e1071")
library(e1071)

index <- 1:nrow(dataset.valid_date)
testindex <- sample(index, trunc(length(index)/3))
testset <- dataset.valid_date[testindex,]
trainset <- dataset.valid_date[-testindex,]
svm.model <- svm(author ~ date$hour, data = trainset, cost = 100, gamma = 1)
svm.pred <- predict(svm.model, testset[, -1])
summary(table(pred = svm.pred, true = testset[,1]))






confint(model)




km = kmeans(dataset.valid_date[,c("hour")],centers = 4, nstart = 20)
km$centers
plot(dataset.valid_date$hour, col = km$cluster)
points(km$centers, cex = 1.5, pch = 11, col = c(1:4))


km = kmeans(dataset.valid_date[,c("hour", "wday")],centers = 14, nstart = 20)
km$centers

plot(dataset.valid_date$hour, dataset.valid_date$wday, pch = km$cluster)





PID <- dataset.valid_date
ntrain <- round(nrow(PID)*4/5)
train <- sample(1:nrow(PID), ntrain)
training <- PID[train,]
testing <- PID[-train,]




length(PID$is_owner)
length(predictions)





#----------------------------


stats.authors.mark_seemann = subset(dataset, author == 'Mark Seemann')  
stats.authors.mikkel_christensen = subset(dataset, author == 'Mikkel Christensen')  
wilcox.test(as.numeric(stats.authors.mark_seemann$date$hour), as.numeric(stats.authors.mikkel_christensen$date$hour))



qplot(date, data=stats.authors.mark_seemann)

msn = dataset$date[dataset$author == 'Mark Seemann']
enc = dataset$date[dataset$author == 'Enrico Campidoglio']

wilcox.test(msn$hour, enc$hour)
kruskal.test(date$hour ~ author, data=dataset)
kruskal.test(author ~ date$hour, data=dataset)
kruskal.test(author ~ date$year, data=dataset)


summary(msn$hour)
summary(enc$hour)

summary(dataset$date$hour)

qplot(factor(date$wday), data = dataset, geom = "bar", xlab = "Week day")
qplot(factor(date$yday), data = dataset, geom = "bar", xlab = "year day")
qplot(factor(date$year), data = dataset, geom = "bar", xlab = "year")







