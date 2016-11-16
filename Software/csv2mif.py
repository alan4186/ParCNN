#!/usr/bin/python

# takes in a two column csv file and outputs a mif
# example
"""
addresses base 16,data base10
0,ff
1,fe
2,fd
.
.
.

"""

import sys
import csv
import network_params

print sys.argv
if len(sys.argv) != 3:
  raise TypeError(sys.argv,"there must be 2 arguments: the source csv file and the output file")

inFile = sys.argv[1]
outFile = sys.argv[2]


def hexStr(decStr):
    h = hex(int(decStr))
    h = h.split('x')[-1]
    return h

def hexFill(decStr):
    h = hexStr(decStr)
    while len(h) < 4:
        h = '0' + h
    return h

print "Reading " + inFile + " as the source csv file"
with open(outFile, 'w') as of:
    print "Overiting "+ outFile + " if it exists"
    header = "WIDTH = 24;\nDEPTH=1024;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n"
    of.write(header)

with open(inFile, 'r') as csvfile:
    csvreader = csv.reader(csvfile, delimiter=',',quotechar='|')
    headers = next(csvreader)
    for row in csvreader:
        # assume no headers
        with open(outFile,'a') as of:
            hexData = (row[1])
            #line = row[0] + "\t:\t" + hexFill(int(hexData,16)) + ";\n"
            line = row[0] + "\t:\t" + hexFill(row[1]) + ";\n"
            of.write(line)

with open(outFile,'a') as of:
    of.write("END;")

print "\n\nDone!"

