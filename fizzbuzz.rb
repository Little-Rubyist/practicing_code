=begin
(1..100).each do |n|
  if n%15 == 0
    puts "Fizz Buzz"
  elsif n%5 == 0
    puts "Buzz"
  elsif n%3 == 0
    puts "Fizz"
  else
    puts n
  end
end
=end

def fizzbuzz(n)
  return :FizzBuzz if n % 15 == 0
  return :Buzz if n % 5 == 0
  return :Fizz if n % 3 == 0
  n
end

(1..100).map {|n| puts fizzbuzz(n)}