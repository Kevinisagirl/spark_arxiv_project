from pyspark import SparkContext

import os


def main():

    indir = '/Akamai_scratch/arxiv/outdir3'
    for root, dirs, filenames in os.walk(indir):
        for f in filenames:
            sc = SparkContext(appName='SparkWordCount')
            input_file = sc.textFile(os.path.join(root, f))
            counts = input_file.flatMap(lambda line: line.split()).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)
            counts.saveAsTextFile('/Akamai_scratch/_team_joe_/' + f + '.wordcount.csv')
            sc.stop()
if __name__ == '__main__':   main()