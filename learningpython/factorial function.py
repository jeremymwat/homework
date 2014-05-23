
# returns the factorial of the argument "number"
def factorial(number):
    product = 1
    for i in range(number):
        product = product * (i+1)
    return product


user_input = int(input("enter non negative integer"))
factorial_of_user_input = factorial(user_input)
print(factorial_of_user_input)
