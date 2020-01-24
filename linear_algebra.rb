require 'Matrix'
matrix_a = [[3, 4, 4],
]

matrix_b = [[2],
            [5],
            [2],]


row_1 = matrix_a[0].count
row_2 = matrix_b[0].count
# 行、横

begin
  matrix_a.each {|item|
    if not row_1 == item.count
      p "row_1 is not matrix"
      exit
    end
  }
ensure
  matrix_b.each {|item|
    if not row_2 == item.count
      p "row_2 is not matrix"
      exit
    end
  }
end

p "行列として成り立っています"

column_1 = matrix_a.count
column_2 = matrix_b.count
# 列、縦

if row_1 == row_2 && column_1 == column_2
  p "計算が可能です"
elsif (row_1 == 1 && column_2 == 1 && column_1 == row_2)\
or (row_2 == 1 && column_1 == 1 && column_2 == row_1)
  p "内積及び乗法が可能です"
elsif row_1 == column_2 || row_2 == column_1
  p "乗法が可能です"
else
  p "計算はできません"
end

if row_1 == row_2 && column_1 == column_2
# 加法
  plus = Marshal.load(Marshal.dump(matrix_a))
  plus.each_with_index {|item, index|
    item.each_with_index {|subitem, subindex|
      plus[index][subindex] += matrix_b[index][subindex]
    }
  }
  p "加法の結果は#{plus}です"

# 減法
subtraction = Marshal.load(Marshal.dump(matrix_a))
subtraction.each_with_index {|item, index|
  item.each_with_index {|subitem, subindex|
    subtraction[index][subindex] -= matrix_b[index][subindex]
  }
}

p "減法の結果は#{subtraction}です"
# 逆の場合はmatrix_aとmatrix_bを交換する => p matrix_b

end

# トレース
if row_1 == column_1 || row_2 == column_2
trace = 0
  matrix_a.each_with_index {|item, index|
    item.each_with_index {|subitem, subindex|
      if index == subindex
        trace += matrix_a[index][subindex]
      end
    }
  }
  p "トレースの結果は#{trace}です"
end

# 内積
if (row_1 == 1 && column_2 == 1 && column_1 == row_2)\
or (row_2 == 1 && column_1 == 1 && column_2 == row_1)
  inner_product = 0
  matrix_a.each_with_index {|item, index|
    item.each_with_index {|subitem, subindex|
      inner_product += matrix_a[0][subindex] * matrix_b[subindex][0]
    }
  }
  p "内積の結果は#{inner_product}です"
end

# 乗法 <- 行列の乗法は癖があって当時出来なかったです