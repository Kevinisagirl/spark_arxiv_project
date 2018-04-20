import os
import tarfile
import shutil
import re
import csv
import gzip

reT = re.compile(r'\.tex$')

directory = os.fsencode("1801")

try:
    os.mkdir('outdir')
except:
    shutil.rmtree('outdir')
    os.mkdir('outdir')

file_name_dict ={}

i = 0

for filename in os.listdir(directory):
    i += 1
    if i % 100 == 0:
        print(i)
    if filename.endswith(b".gz"):
        location = directory + b"/" + filename
        filename = filename.decode('utf-8')[:-3]
        try:
            t = tarfile.open(location, 'r')
            file_name_dict[filename] = [m.name for m in t.getmembers()]
            t.extractall('outdir', members=[m for m in t.getmembers() if reT.search(m.name)])
        except:
            outfilename = 'outdir/' + filename+".tex"
            file_name_dict[filename] = []
            with gzip.open(location.decode('utf-8'), 'rb') as f_in:
                with open(outfilename, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)

outfile = open("original_contents_of_gz_files.csv", 'w')
for key in file_name_dict:
    outstring = key + ","
    for filenames in file_name_dict[key]:
        outstring = outstring + filenames + ","
    outstring = outstring[:-1] + "\n"
    outfile.write(outstring)
outfile.close()
    

