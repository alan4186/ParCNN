#!/usr/bin/python

import sys
import csv
from cStringIO import StringIO
from intelhex import IntelHex16bit

print sys.argv
if len(sys.argv) < 2:
  raise TypeError(sys.argv,"Missing input file(s)")

inFiles = sys.argv[1:]


def hexStr(decStr):
    h = hex(int(decStr))
    h = h.split('x')[-1]
    return h
   
    
def datatype(row):
    data = int(row[data_start_col])
    # convert data to hex
    data = hexStr(data)
    if len(data) > 4:
        raise ValueError(data, "The Data value at address " +row[addressCol] + " must be 16 bits")
    while len(data) < 4:
        data = '0' + data
    data = (data[0:2])[::-1] + (data[2:4])[::-1]
    data = data[::-1]
    return hex(int(data,16))

    return hex(int("0000",16))


for f in inFiles:
    outFile = f.split('.')[0] + ".hex"
    print "Reading " + f + " as the source csv file"

    with open(outFile, 'w') as dummy:
        print "Overiting "+ outFile + " if it exists"

    with open(inFile, 'r') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=',',quotechar='|')
        headers = next(csvreader)
        q = 0
        ih = IntelHex16bit()
        for row in csvreader:
            # assume no headers
            hexData = switch[row[typeCol]](row)
            ih[q] = int( hexData,16)
            q = q + 1
    sio = StringIO()
    ih.write_hex_file(sio)
    hexString = sio.getvalue()
    sio.close()

    with open(outFile,'w') as of:
        of.write(hexString)

print "\n\nDone!"

