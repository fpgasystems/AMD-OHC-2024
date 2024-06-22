
import os
import sys
import json

# Python code to
# demonstrate readlines()
arg1 = sys.argv[1]
 
# writing to file
f = open(arg1 + '.xdc', 'r')
f_static = open(arg1 + 'static.xdc', 'w')
f_shell = open(arg1 + 'shell.xdc', 'w')
filedata = f.read()
f.close()

for line in filedata.splitlines():
    if line.find('set_property PACKAGE_PIN') : 
        f_shell.write(line + '\n')
    elif line.find('set_property IOSTANDARD') :
        f_static.write(line + '\n')

f_static.close()
f_shell.close()