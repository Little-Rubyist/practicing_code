# +++*****+--*++*+-+++
# +3*5+1-2*1+2*1+1-1+3
# のように計算するやつ

def symbol_math(n) plus = n.count("+")
ten = n.count("*") * 10
minus = n.count("-")
p plus + ten - minus
end

symbol_math("+++*+++*****+--*")
