=begin
a,b,c = true,true,false

p a or b && c
p (a or b) && c
# &&が先に評価されるが（）のほうが優先される
# or,|| は左辺が偽なら右辺を評価
# and,&& は左辺が真なら右辺を評価

if n > 1 and n < f
  puts "素数じゃないです"
elsif
puts "素数です"
end
=end

def math(n, f, g)
  while n <= f
    if f%n == 0
      puts "#{n}でわりきれます。"
    end
    if n == 1 || n == f
      g = true
    elsif n > 1 && n > f
      g = false
    end
    n += 1
  end
  p g
end
puts math(1,4,1)