
word_cloud <- function(data_history_raw) {
  data_history_raw = data_history_raw

  text_data <- data_history_raw$Measure
  # Generate word frequencies
  word_freq <- table(text_data)
  
  # Generate word cloud with adjustments for better visualization
  wordcloud(names(word_freq), freq = word_freq, scale=c(2, 0.5), min.freq = 2,
            random.order = TRUE, rot.per = 0.35, colors = brewer.pal(8, "Dark2"),
            max.words = Inf, random.color = TRUE)  # Adjust minimum font size
}

