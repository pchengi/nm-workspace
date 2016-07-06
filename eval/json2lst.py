import sys 

import json

arr = json.loads(open(sys.argv[1]).read())

for n in arr:
    print n

