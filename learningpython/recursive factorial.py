#
# returns the factorial of the argument "number"
def factorial(number):
    if number <=1:      #base case
        return  1
    else:
        return number*factorial(number-1)

user_input = int(input("enter non negative integer"))
factorial_of_user_input = factorial(user_input)
print(factorial_of_user_input)
