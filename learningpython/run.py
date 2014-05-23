#picks the argv module from sys. argv stores the variables in order that they will be given when the program is run.

from sys import argv

#this assigns the variables to the arguments that the user will pass when he runs the program. Script is always first, there is really only one argument
script, filename = argv

#this opens the file *filename* and assigns it to varialbe txt
txt = open(filename)

#this prints some text with the .format command
print("We are going to erase {}".format(filename))
print("If you do not want that, hit CTRL-C (^C).")
print("If you do want that, hit RETURN.")

input("?")

print("Opening the file...")
target = open(filename, 'w')

print("Truncating the file. Goodbye!")
target.truncate()

print("Now I'm going to ask you for three lines.")

line1 = input("Line 1: ")
line2 = input("Line 2: ")
line3 = input("Line 3: ")

print("I am going to write these to the file")

target.write(line1)
target.write("\n")
target.write(line2)
target.write("\n")
target.write(line3)
target.write("\n")

print("and finally we close it.")
target.close()