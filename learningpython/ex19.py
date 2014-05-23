#ex19

def cheese_and_crackers(cheese_count, box_of_crackers):
    print("You have {} cheeses!".format(cheese_count))
    print("you have {} boxes of crackers!".format(box_of_crackers))
    print("\n")

print("We can just give the function numbers directly:")
cheese_and_crackers(20,30)

print("OR we can use variables from our script:")
amount_of_cheese = 10
amount_of_crackers = 50

cheese_and_crackers(amount_of_cheese,amount_of_crackers)

print("we can even do math inside too:")
cheese_and_crackers(10 + 20, 6 + 5)

print("And we can combine variables and math")
cheese_and_crackers(amount_of_cheese + 100, amount_of_crackers + 1000)