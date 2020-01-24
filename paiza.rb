# 知人の説明の為にpaizaの問題を解説したもの
# N日分
days = gets.to_i # 日数
max = []
min = []
ans = []
days.times do |day|
  day += 1 # 可読性のために値を1つ上げて日数と値を同じにする
  stock = gets.split.map(&:to_i)
  max << stock[2] # 最大株価の値をまとめる
  min << stock[3] # 最小株価の値をまとめる
  if day == 1
    ans << stock[0] #一日目のときに入れる
  end
  if day == days
    ans << stock[1] # 最終日のときに入れる
  end
end
ans << max.sort![-1] # 順番を並べ替えて一番大きい物（最後に入ってる）を入れる
ans << min.sort![0] #順番を並べ替えて一番小さい物（一番最初）を入れる

p ans


