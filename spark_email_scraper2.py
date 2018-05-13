import os

import sys

from pyspark import SparkContext, SparkConf

import re

if __name__ == "__main__":

    indir = '/Akamai_scratch/arxiv/outdir3/'
    

    # create Spark context with Spark configuration
    conf = SparkConf().setAppName("Scrape Emails")
    sc = SparkContext(conf=conf)
    all_files = sc.wholeTextFiles(indir + "1801*.tex").map(lambda file: file)
    all_files = all_files.map(lambda line: (re.findall(r"(\S+)@(\S+)", line[1])))
    

    all_files.saveAsTextFile("/Akamai_scratch/_team_joe_/output_test.csv")