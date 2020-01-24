#フィボナッチ
$phi = (1 + Math.sqrt(5)) / 2

def fib(n) if n.is_a? Integer
             p ($phi ** n - (-$phi) ** -n) / Math.sqrt(5)
           else p "Don't use argument string."
           end

end

fib(8)