from sys import argv
from os.path import exists

script, from_file, to_file = argv
#input2 = open(from_file)
#indata = open(from_file).read()
#output = open(to_file, 'w')
#output.write(indata)

#this is a one line version of EX17. It opens the file 'to_file' ready to write, then opens and writes from 'from_file'
open(to_file,'w').write(open(from_file))


#output.close()
#input2.close()