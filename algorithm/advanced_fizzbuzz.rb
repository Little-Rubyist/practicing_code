# fizzbuzzの発展形
# ある会社のテストで出た問題の回答コード
def include_by(data)
  data.to_s.include? '3'
end

def advanced_fizzbuzz(argv)
  argv.each_index do |i|
    if /\d*[^a-zA-Z０-９\-\+]/ === argv[i]
      data = argv[i].to_i
    else
      next puts 'invalid'
    end
    if data < 1000 && data % 3 == 0 && include_by(data)
      puts 'dumb'
    elsif data < 1000 && data % 3 == 0
      puts 'idiot'
    elsif data < 1000 && include_by(data)
      puts 'stupid'
    elsif data < 1000
      puts 'smart'
    else
      puts 'invalid'
    end

  end
end

advanced_fizzbuzz(gets)
