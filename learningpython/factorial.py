number = int(input("enter a non-negative number you wish to take the factorial of: "))

product = 1
for i in range(number):
    product = product * (i+1)

print(product)