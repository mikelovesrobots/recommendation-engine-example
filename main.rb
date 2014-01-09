require 'json'

class ArticleRepository
  def initialize
    @article_paths = ArticlesFinder.new.paths
  end

  def articles
    @article_paths.collect do |path|
      ArticleReader.new(path).read
    end
  end
end

class ArticlesFinder
  FILE_TYPE = "json"

  def initialize
    @paths = Dir["**/*.#{FILE_TYPE}"]
  end

  def paths
    @paths
  end
end

class ArticleReader
  def initialize(path)
    @path = path
  end

  def read
    json = JSON[plain_text]
    if json["summary"] and json["summary"]["text"]
      json["summary"]["text"]
    else
      ''
    end
  end

  private

  def plain_text
    file = File.open(@path, "rb")
    string = file.read
    file.close
    string
  end
end

class WordFrequencizer
  def initialize(articles=[])
    @word_frequency = {}
    injest_sentences(articles)
  end

  def [](word)
    key = word_to_key(word)
    @word_frequency[key] || 0
  end

  def injest_sentences(sentences)
    sentences.each do |sentence|
      injest_sentence(sentence)
    end
  end

  def injest_sentence(sentence)
    sentence.words.each do |word|
      injest_word(word)
    end
  end

  def injest_word(word)
    key = word_to_key(word)
    @word_frequency[key] ||= 0
    @word_frequency[key] += 1
  end

  def word_to_key(word)
    word.downcase
  end
end

class WordSearcher
  def initialize(sentences)
    @sentences = sentences
  end

  def search(word, results_count = 10)
    @sentences.select do |sentence|
      sentence[word]
    end[0..results_count]
  end
end

class LeastCommonWordSorter
  def initialize(word_frequency_chart)
    @word_frequency_chart = word_frequency_chart
  end

  def [](sentence)
    sentence.words.collect(&:downcase).uniq.sort_by { |word| @word_frequency_chart[word] }
  end
end

class String
  def words
    split(/\W+/)
  end
end

class Reporter
  def initialize(content, least_common_words, results)
    @content = content
    @least_common_words = least_common_words
    @results = results
  end

  def print
    puts "Content phrase: " + @content
    puts "Least common words: "
    @least_common_words.each do |word|
      puts "  #{word}"
    end

    puts "Results: "
    @results.each_with_index do |result, index|
      puts "  #{index}. #{result}\n\n"
    end
  end
end

class RecommendationBuilder
  RESULTS_TO_TAKE_FROM_EACH_SEARCH = 2
  SEARCHES_TO_PERFORM = 3
  IDEAL_RECOMMENDATIONS_COUNT = 5

  def initialize(word_searcher)
    @word_searcher = word_searcher
  end

  def recommend(least_common_words)
    search_results = (0..SEARCHES_TO_PERFORM).collect do |i|
      search_term = least_common_words[i]
      @word_searcher.search(least_common_words[i], RESULTS_TO_TAKE_FROM_EACH_SEARCH).collect do |result|
        "[#{search_term}] #{result}"
      end
    end.flatten.compact[0...IDEAL_RECOMMENDATIONS_COUNT]
  end
end

content = STDIN.read

articles = ArticleRepository.new.articles
word_frequency_chart = WordFrequencizer.new(articles)
word_searcher = WordSearcher.new(articles)
least_common_words_in_search = LeastCommonWordSorter.new(word_frequency_chart)[content]
results = RecommendationBuilder.new(word_searcher).recommend(least_common_words_in_search)

Reporter.new(content, least_common_words_in_search, results).print

