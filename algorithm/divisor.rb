#いくつで割り切れるか
def divisor(n, f) while n <= f
                    if f % n == 0
                      puts "#{n}でわりきれます。"
                    end
                    n += 1
                  end
end

puts divisor(1, 4)
# 八桁で重め？
