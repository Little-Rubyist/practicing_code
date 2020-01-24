# 練習問題を個人的に貰って解いてたもの
def alphabet_checker(sentence)
  table = Hash.new(0)
  sentence.upcase!
  sentence.scan(/./) { |m| table[m] += 1 }

  string = "A".."Z"
  string.each do |alphabet|
    arr = table.assoc(alphabet)
    if arr == nil
      arr = [alphabet, 0]
    end
    puts "#{alphabet}:#{arr[1]}"
  end
end

alphabet_checker("Ruby is the best programming language.")