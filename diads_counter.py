iFile = open("countries_diads.csv", "r+")
next(iFile)
adict = {}
for line in iFile:
    splt = line[:-1].replace('"', '').split(",")
    diad = splt[1].split(",")[0] + ", " + splt[2].split(",")[0]
    if diad not in adict:
        adict[diad] = 1
    else:
        adict[diad] += 1

oFile = open("countries_pairs_counts.csv", "w+")
oFile.write("country1, country2, count\n")
for key in adict:
    outstring = key + "," + str(adict[key]) + "\n"
    oFile.write(outstring)

