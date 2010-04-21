 fun fib n = (if n < 2
              then 1
              else fib(n-1) + fib(n-2))
 fib 34

#   # Just for fun a faster way to fib
#   # fib c is in b
#   # fib (c-1) is in a
# fun fib_iter n c a b = (if n < c | n = c
# 		    then b
#                     else fib_iter n (c+1) b (a+b))
# 
# fun fast_fib n = (if n < 2
# 	      then 1
# 	      else fib_iter n 1 1 1)
# 
# fast_fib 34
