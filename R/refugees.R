# Make sur you installed tm and SnowballC libs
# R.version : 3.2.2
library("tm")
library("SnowballC")
source('sentiment.R')

computeSentiment <- function(country, countryCode){
  # Compute files names
  file <- paste('tweets-', countryCode, '.csv', sep = "")
  posFile <- paste(country, '-positive-words.txt', sep = "")
  negFile <- paste(country, '-negative-words.txt', sep = "")
  
  
  # Loads tweets
  # Make sure tweets.csv is in your current working directory
  # Text is in tweets$text 
  tweets <- read.csv(file, header = TRUE, sep = ",")
  
  # Loads positive and negative words
  pos <- scan(posFile, what = "character", comment.char = ";")
  neg <- scan(negFile, what = "character", comment.char = ";")
  
  
  # Create TM objects to work with
  corpus <- VCorpus(VectorSource(tweets$text))
  
  # TM preparation : lower casing, removing stopwords,...
  data <- tm_map(corpus, stripWhitespace)
  data <- tm_map(data, content_transformer(tolower))
  data <- tm_map(data, removeWords, stopwords(country))
  data <- tm_map(data, removePunctuation)
  #data <- tm_map(data, stemDocument)
  
  # Gets a list of prepared tweets
  dataframe <- data.frame(text=unlist(sapply(data, `[`, "content")), stringsAsFactors=F)
  dataframe <- subset(dataframe, text != "")
  
  # Applies sentimentt analysis
  scores <- score.sentiment(dataframe$text, pos, neg)
  
  # if you want and histogram
  # histogram <- hist(sentiment$score, xlab = "Sentiment")
  
  return(list("sentiment"=scores, "dataframe"=dataframe))
}

computeFrequentTerms <- function(dataframe, count){
  allTweets <- paste(dataframe$text, collapse = '')
  oneCorpus <- VCorpus(VectorSource(c(allTweets)))
  dtm <- DocumentTermMatrix(oneCorpus)
  
  return(findFreqTerms(dtm, count))
}

england <- computeSentiment('english', 'en')
hist(england$sentiment$score, xlab = "Sentiment")
enMean <- mean(england$sentiment$score)
enSd <- sd(england$sentiment$score)
enFreqWords <- computeFrequentTerms(england$dataframe, 70)

france <- computeSentiment('french', 'fr')
hist(france$sentiment$score, xlab = "Sentiment")
frMean <- mean(france$sentiment$score)
frSd <- sd(france$sentiment$score)
frFreqWords <- computeFrequentTerms(france$dataframe, 200)

germany <- computeSentiment('german', 'de')
hist(germany$sentiment$score, xlab = "Sentiment")
deMean <- mean(germany$sentiment$score)
deSd <- sd(germany$sentiment$score)
deFreqWords <- computeFrequentTerms(germany$dataframe, 50)