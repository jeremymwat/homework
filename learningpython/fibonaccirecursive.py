# generating the nth term of the fibonacci sequence recursively
def fibonacci(num):
    if num ==0:
        return 0
    elif num ==1:
        return 1
    else:
        return fibonacci(num-1)+fibonacci(num-2)

user_input = int(input("number"))
output = fibonacci(user_input)
print(output)