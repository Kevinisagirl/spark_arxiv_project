#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May  9 13:19:35 2018

@author: Michael
"""

from pyspark import SparkContext

import os
import re
import io
import csv

def main():

    def get_email(file):
        f = io.open(file, mode="r", encoding="utf-8")
        a = []
        for line in f:
            if re.findall(r"(\S+)@(\S+)", line):
                a.append(line)
        return clean_list(a)
     
      
    def clean_list(x):
        for i in range(len(x)):
                x[i] = x[i].replace(u'\xa0',u' ')
                x[i] = x[i].replace(u'\n','')
        return x

    def one_list(lists):
      results = []
      for numbers in lists:
        for number in numbers:
          results.append(number)
      return results
    
    total_list = []
        #indir = '/Akamai_scratch/arxiv/outdir3'
    indir = '/Users/Michael/Desktop/test'
    for root, dirs, filenames in os.walk(indir):
        for f in filenames:
            total_list.append(get_email(f))
    
    with open('emails.csv','w', newline="") as file:
        cw = csv.writer(file)
        cw.writerows(r+[""] for r in total_list)
        
        
        wr = csv.writer(file, quoting=csv.QUOTE_ALL)
        wr.writerow(total_list)

    
if __name__ == '__main__':   main()