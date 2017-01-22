# install packages
install.packages('ggplot2')
install.packages("data.table")
install.packages("stargazer")
install.packages('car')

# load libraries
library(stargazer)
library(ggplot2)
library(data.table)
library(car)

# change working directory to directory containing script
setwd('F:/Projects/Courses/uvt/RLang/Teza/repository/data_analysis')

# Change locales to US because data in CSV is stored in 
# USA format and R takes by default local format
Sys.setlocale(locale='us')

# Declare custom class which knows how to parse date time from CSV file
setClass('git_date')
setAs("character","git_date", function(from) strptime(from, "  %a %b %e %H:%M:%S %Y %z"))

# Load csv file
dataset <- read.csv('commit_log.csv', colClasses = c('factor', 'factor', 'factor', 'git_date', 'factor', 'integer', 'integer'))
attach(dataset)

# Create summary and splitt it in two parts for better layout output
stats.summary <- summary(dataset)
stats.summary[,1:3]
stats.summary[,4:7]

# Get entries where date parsing failed
subset(dataset, is.na(date))

# Compute number of unique authors and commits
stats.unique.authors <- unique(dataset$author)
stats.unique.commits <- unique(dataset$id)

length((unique(dataset$author)))
length(unique(dataset$id))

# Plot Authors, Added lines, Removed lines
qplot(factor(author), data = dataset, geom = "bar", xlab = "Authors")
qplot(factor(added), data = dataset, geom = "bar", xlab = "Number of added lines in a file")
qplot(factor(removed), data = dataset, geom = "bar", xlab = "Number of removed lines in a file")

# Find top contributors and plot them
stats.authors_freq <- as.data.frame(table(dataset$author))
colnames(stats.authors_freq) <- c("Author", "Freq")
stats.top_authors <- subset(stats.authors_freq, Freq >= mean(stats.authors_freq$Freq))
ggplot(data = stats.top_authors, aes(x=Author, y=Freq)) + geom_histogram(stat = "identity")

# Find most frequent number of added lines and plot them
stats.added_freq <- as.data.frame(table(dataset$added))
colnames(stats.added_freq) <- c("Added", "Freq")
stats.top_adds <- subset(stats.added_freq, Freq > mean(dataset$added))
ggplot(data = stats.top_adds, aes(x=Added, y=Freq)) + geom_histogram(stat = "identity")

# Find most frequent number of removed lines and plot them
stats.removed_freq <- as.data.frame(table(dataset$removed))
colnames(stats.removed_freq) <- c("Removed", "Freq")
stats.top_removes <- subset(stats.removed_freq, Freq > mean(dataset$removed))
ggplot(data = stats.top_removes, aes(x=Removed, y=Freq)) + geom_histogram(stat = "identity")

# Plot Authors activity durring repository life time
qplot(author, date, data=dataset, geom="boxplot", fill=author) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

qplot(factor(date$hour), data = dataset, geom = "bar", xlab = "Hours")
qplot(author, date$hour, data=dataset, geom="boxplot", fill=author, ylab = 'Hours', xlab = ) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# ========= Testing hypotheses =====================

# Perform kruskal test to find out if hours depends on author
kruskal.test(date$hour ~ author, data=dataset)

# Wilcox test to find out if Mark Seemann and Enrico Campidoglio works in same  hours
msn = dataset$date[dataset$author == 'Mark Seemann']
enc = dataset$date[dataset$author == 'Enrico Campidoglio']

wilcox.test(msn$hour, enc$hour)

#----- Logistic regression

accuracy <- function(predictions, answers){
  sum((predictions==answers)/(length(answers)))
}

# Remove entires where date is NA and add hour, wday and is_owner columns to dataset 
dataset.valid_date = subset(dataset, !is.na(dataset$date))
dataset.valid_date$hour = dataset.valid_date$date$hour
dataset.valid_date$wday = dataset.valid_date$date$wday
dataset.valid_date$is_owner =  with(dataset.valid_date, author == 'Mark Seemann')

# Calculate probability of randomly choosing the owner
nrow(dataset.valid_date[dataset.valid_date$is_owner == TRUE, ]) /nrow(dataset.valid_date)

# Split dataset in Training (80%) and Testing (20%) sets 
ntrain <- round(nrow(dataset.valid_date)*4/5)
train <- sample(1:nrow(dataset.valid_date), ntrain)
training <- dataset.valid_date[train,]
testing <- dataset.valid_date[-train,]

model <- glm(is_owner~date$hour, data=training, family=binomial(logit))
model <- glm(is_owner~date$hour + date$year, data=training, family=binomial(logit))
model <- glm(is_owner~date$hour+date$wday+date$year+added+removed, data=training, family=binomial(logit))

summary(model)

# Calculate accuracy for training set
predictions <- round(predict(model, training, type="response"))
predictions <- ifelse(predictions == 1, TRUE, FALSE)
accuracy(predictions, training$is_owner)

# Calculate accuracy for testing set
predictions <- round(predict(model, testing, type="response"))
predictions <- ifelse(predictions == 1, TRUE, FALSE)
accuracy(predictions, testing$is_owner)

#------------ K-Means -----------
km = kmeans(dataset.valid_date[,c("hour")],centers = 4, nstart = 20)
km$centers
plot(dataset.valid_date$hour, col = km$cluster)
points(km$centers, cex = 1.5, pch = 11, col = c(1:4))







