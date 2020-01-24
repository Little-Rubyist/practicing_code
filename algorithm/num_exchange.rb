#数字を入れ替えるやつ
def num_exchange(int1, int2)
  int1 = int1 + int2
  int2 = int1 - int2
  int1 = int1 - int2

  p "引数1：#{int1}, 引数2：#{int2}"
end

num_exchange(5, 4)
