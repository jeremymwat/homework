#ex21

def add(a, b):
    print("adding {} + {}".format(a,b))
    return a + b

def subtract(a, b):
    print("subtracting {} - {}".format(a,b))
    return a - b

def multiply(a, b):
    print("multiplyin {} * {}".format(a,b))
    return a * b

def divide(a, b):
    print("Dividing {} / {}".format(a,b))
    return a / b

print('lets do some math with just functions!')

age = add(30, 5)
height = subtract(78,4)
weight = multiply(90,2)
iq = divide(100,2)

print('Age:{}, height:{}, weight:{}, IQ:{}'.format(age,height,weight,iq))

#puzzle for EC
print("Here is a puzzle")

what = add(age, subtract(height, multiply(weight, divide(iq,2))))

print(what)
