#ex33

x = eval(input("How big of a range would you like to make?"))
y = eval(input("How would you like to increment it?"))

def make_a_range(itlen,inclen):
    i = 0
    numbers = []

    for i in range(itlen):
        print('At the top i is {}'.format(i))
        numbers.append(i)

#        i = i + inclen
        print('Numbers now: ', numbers)
        print('at the bottom i is {}'.format(i))

    print('The numbers: ')

    for num in numbers:
        print(num)

if x <= 0 or y <= 0:
    print("Nice try.")
else:
    make_a_range(x,y)
