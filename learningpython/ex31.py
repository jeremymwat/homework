#ex31

print('You enter a dark room with two doors. Do you go through door #1 or door #2?')

door = input('>')

if door == "1":
    print("THere's a giant bear here eating a cheesecake. What do you do?")
    print('1. Take the cake.')
    print('2. Scream at the bear.')
    bear = input(">")
    if bear == "1":
        print('The bear eats your face off. Good job!')
    if bear == "2":
        print('The bear eats your legs off. Good job!')
    else:
        print("Well {} is probably better. Bear runs away.".format(bear))

elif door == "2":
    print ("You stare into the endless abyss at Cthulhu's retina.")
    print("1. Blueberries.")
    print("2. Yellow jacket clothespins.")
    print("3. Understanding revolvers yelling melodies.")

    insanity = input('>')

    if insanity == "1" or insanity == '2':
        print("Your mind is destroyed.")
    else:
        print("You suck.")

else:
    print('You stumble around and fall on a knife and die. Good job!')
