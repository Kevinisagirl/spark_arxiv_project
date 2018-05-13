#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 12 12:02:39 2018

@author: stephanierivera
"""

import pandas as pd
import numpy as np
from string import punctuation 


df = pd.read_csv("/Users/stephanierivera/Downloads/emailIndex.csv", header= None)
new_df = df.T


new_df['email'] = new_df[0].str.split(',').str.get(0)
new_df['article'] = new_df[0].str.split(',').str.get(1)

# playing around
new_df_1 = new_df[0][0]
new_df_2 = new_df[0]


# if you want to keep splitting on the comma for many emails
# downside is you end up with a lot of null columns
full_df = new_df[0].str.split(',', expand=True)





#split_it = new_df.split(',')

#diff = new_df_1.str.split(',', expand=True)

#final = new_df[0][1].apply(pd.Series)

new_df1 = new_df.drop(new_df.columns[0], axis=1)



new_df1 = new_df.drop(new_df.columns[0], axis=1)

new_df1['email'] = new_df1['email'].str[2:-1]

new_df1['article'] = new_df1['article'].str[:-1]

new_df1['email'] = new_df1['email'].str.rstrip(punctuation)

#new_df1.to_csv("/Users/stephanierivera/Desktop/writeto/data.csv")

new_df1['article']= pd.to_numeric(new_df1.article, errors='coerce')

new_df1['email'] = np.where(new_df1['article'].isnull(), new_df1['article'],new_df1['email'])

new_df1.to_csv("/Users/stephanierivera/Desktop/writeto/data.csv")

#remove anything that is not either 2 or 3 charlen after a period 



#print(new_df1[new_df1['article'].isnull()])

#print(type(new_df1['article'][4]))




