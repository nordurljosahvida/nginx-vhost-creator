#!/usr/bin/python

import fileinput
import os
import re

def transform(match):
    return os.getenv(match.group(1)) # replace the "capture" to omit $

for line in fileinput.input(): # reads from stdin or from a file in argv
#   print re.sub('\$(\w+)', transform, line), # comma to omit newline
    print re.sub('\$(var_\w+)', transform, line), # comma to omit newline
