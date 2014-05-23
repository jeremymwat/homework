#ex20

#imports the ability to put in arguments in the command line
from sys import argv

#names the variables that will be called from user input on the command line
script, input_file = argv
#defines the function Print_all with one argument
def print_all(f):
    #opens and then prints the file as defined by the argument 'f'
    print(f.read())

#defines function rewind with argument 'f'
def rewind(f):
    #uses seek method to go to the position '0' in the file
    f.seek(0)


def print_a_line(line_count, f):
    print(line_count, f.readline())

current_file = open(input_file)

print("First let's print the whole file:\n")

print_all(current_file)

print("now let's rewind, kind of like a tape")

rewind(current_file)

print("Let's print three lines:")

current_line = 1
print_a_line(current_line, current_file)

current_line = current_line + 1
print_a_line(current_line, current_file)

current_line = current_line + 1
print_a_line(current_line, current_file)