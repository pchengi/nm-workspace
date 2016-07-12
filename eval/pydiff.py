import sys, json

f1 = open(sys.argv[1])
f2 = open(sys.argv[2])



j1 = json.loads(f1.read())


j2 = json.loads(f2.read())

for l1, l2 in zip(j1["links"], j2["links"]):

    
