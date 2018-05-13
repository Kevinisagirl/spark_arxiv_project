#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 13 11:32:39 2018

@author: Michael
"""

import pandas as pd
import re

df = pd.read_csv("data (3).csv")
df1 = df
df1 = df1.dropna(axis=0, how='any')


def get_em(email):
    return email.rsplit('.', 1)[-1]

df1['email'] = df1['email'].apply(lambda x: get_em(x))
df1 = df1.drop(columns = 'Unnamed: 0')

line = pd.DataFrame({'email': 'dean', 'age': 45, 'sex': 'male'}, index=[0])

world = pd.read_csv("data.csv")
world1= world['Code'].str.lower()
world = world.drop(columns = 'Code')
world2 = pd.concat([world, world1], axis=1)


world2.loc[-1] = ['USA', 'edu']
world2.index = world2.index + 1
world2.sort_index(inplace=True) 

df1.rename(columns={'email':'Code'}, inplace=True)

world2.loc[world2['Name'] == "Russian Federation", 'Name'] = "Russia"
world2.loc[world2['Name'] == "Korea, Republic of", 'Name'] = "South Korea"
world2.loc[world2['Name'] == "Viet Nam", 'Name'] = "Vietnam"


df4 = pd.merge(df1,world2, on = "Code")
df4.to_csv("emails.country.csv")

