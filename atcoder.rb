# atcoderの練習問題を解いてたもの（途中かも）
def most_frequent_words_in(phrase)
  phrase.downcase!
  words = phrase.split.uniq
  most_frequent_word = ''
  words.each do |word|
    if most_frequent_word.empty?
      most_frequent_word = word
      next
    end
    if phrase.scan(most_frequent_word).size < phrase.scan(word).size
      most_frequent_word = word
    end
  end
  most_frequent_word
end
