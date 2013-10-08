# -*- coding: utf-8 -*-

import requests, re
from bs4 import BeautifulSoup
import pandas as pd

def read_table(url):
   soup = BeautifulSoup(requests.get(url).content)
   return soup.find(lambda tag:tag.name == 'table')

def parse_table(url):
   table = read_table(url)
   return [[td.get_text(strip=True)
            if td.find("a") is None 
            else url + td.find("a")["href"] 
            for td in tr.find_all("td") if td.get_text(strip=True) is not u""] 
            for tr in table.find_all("tr")]

def parse_statement(url):
    soup = BeautifulSoup(requests.get(url).content)
    statements = [statement.text.strip() for statement in soup.findAll('p')]
    try:
        start = statements.index(u'Last Statement:')
    except:
        start = 0
    statements = [statements[i] for i in range(0, len(statements)) if i > start]
    return u''.join(statements)

columns = ['execution', 'offender_information', 'last_statement', 'last_name',
           'first_name', 'tdcj_number', 'age', 'date', 'race', 'county']
data = parse_table('http://www.tdcj.state.tx.us/death_row/dr_executed_offenders.html')
del data[0]
data = pd.DataFrame(data, columns = columns)
data.ix[:, (1,2)] = data.ix[:, (1,2)].applymap(lambda x: re.sub('dr_executed_offenders.html', '', x))
data['statement_text'] = data['last_statement'].map(lambda x: parse_statement(x))
data.to_csv('statement_data.csv', index=False, encoding='utf-8')

data = parse_table('https://www.tsl.state.tx.us/ref/abouttx/popcnty2010-11.html')
pd.DataFrame(data).to_csv('population_data.csv', index=False, encoding='utf-8')
