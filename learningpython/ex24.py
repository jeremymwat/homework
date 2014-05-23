#ex24
print("Let's practice everything")
#demonstrates how \ is used
print("You\'d need to know \'bout escapse with \\ tat do \n newlines and \t tabs.")

poem = """
\t The lovely world
with logic so firmly planted
cannot discern \n the needs of love
nor comprehend passion from intuition
and requires an explanation
\n\t where there is none.
"""

print("----------------")
print(poem)
print("----------------")

five = 10-2+3-6
print("this should be five: {}".format(five))

def secret_formula(started):
    jelly_beans = started*500
    jars = jelly_beans/1000
    crates = jars/100
    return jelly_beans,jars,crates

start_point = 10000
beans,jars,crates = secret_formula(start_point)

print("With a starting point of: {}".format(start_point))
print("We'd have {} beans, {} jars, and {} crates.".format(beans,jars,crates))

#start_point = start_point/10



print(secret_formula(start_point))

#the * 'unpacks' the return, otherwise it is treated like one object
print("We'd have {} beans, {} jars, and {} crates.".format(*secret_formula(start_point)))