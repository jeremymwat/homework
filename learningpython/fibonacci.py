fibbegin = int(input("How many fibonacci numbers would you like to see?"))

fib1=0
fib2=1
print(0)
print(1)
for i in range(fibbegin-2):

   fibp = fib1+fib2
   fib1 = fib2
   fib2 = fibp
   print(fibp)
