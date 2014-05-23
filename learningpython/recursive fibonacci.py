def fibonacci(number):
    if number == 0:
        return 0
    elif number == 1:
        return 1
    else:
         return fibonacci(number-1)+fibonacci(number-2)

user_input = int(input("enter non negative integer"))
nth_fibonacci = fibonacci(user_input)
print(nth_fibonacci)